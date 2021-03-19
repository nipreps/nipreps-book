---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
kernelspec:
  display_name: Python 3
  language: python
  name: python3
---

# Contributing to *dMRIPrep* - the case of head-motion and eddy-currents estimation

```{code-cell} python
:tags: [hide-cell]

import warnings
warnings.filterwarnings("ignore")

All *NiPreps* are open to the community feedback and contribution.
Contributing to seemingly big projects (*dMRIPrep* is, in reality, pretty small) can feel scary at first.

## Step 0: check the contributing guidelines
Before contributing to an open-source initiative, your first move *should* be checking how and whether the project is seeking feedback from the outside.
Typically, that is stated in the `CONTRIBUTING.md` file of the project or similar solution (e.g., all [*NiPreps* share contributing guidelines](https://nipreps.org/community/)).

## Step 1: preparing a proposal for a new feature, some documentation, or a bugfix
Impromptu contributions are typically difficult to absorb by projects involving several developers and/or with many users.
For this reason, please first browse through the project's repository home page (https://github.com/nipreps/dmriprep).
There are two locations where you'll find details about ongoing and future work.
The [existing and past pull-requests tab](https://github.com/nipreps/dmriprep/pulls) will give you an idea of what new features/bugfixes are currently in progress, and you can also check the requirements to get a pull-request accepted by looking at closed (and "merged") pull-requests.
Next to that tab, you'll typically find [the issue tracker tab](https://github.com/nipreps/dmriprep/issues/).
There, you should check that the feature you have in mind is not already in the works.
Opening a new issue requesting feedback and gauging the interest in a particular new idea is generally very welcome.

Head to https://nipreps.org/community/features/ to learn more about the process of proposing a new feature.

## Step 2: plan ahead
Once you get the thumbs-up from the maintainers, it is time to sort out your contribution.

In this book we will show how to integrate a new algorithm into *dMRIPrep*.
First you should accurately define the problem:

**Problem**: although most dMRI practitioners employ FSL for the estimation and correction of head-motion and eddy-current distortions, the FSL toolbox has restrictions of commercial use. By using FSL's eddy implementation, *dMRIPrep* inherits those restrictions.
Therefore, a fully-open implementation of *dMRIPrep* would require eliminating FSL as a dependency.
In this case, we will provide our own implementation of an algorithm for head-motion and eddy-current-derived distortions.

**The proposed solution**: we will design a model-based algorithm for the realignment of dMRI data.
This is based on an idea first proposed by [Ben-Amitay et al.](https://pubmed.ncbi.nlm.nih.gov/22183784/) and implemented as the SHORELine algorithm in [qsiprep](https://qsiprep.readthedocs.io/en/latest/). 
The idea works as follows:

  1. Leave one DWI (diffusion weighted image) orientation out.
  2. Using the rest of the dataset, impute the excluded orientation using a diffusion model.
     Because it was generated based on the remainder of the data, the simulated volume will be
     free of head-motion and eddy-current spatial distortions.
  3. Run a volumetric registration algorithm between the imputed volume and the original volume.
  4. Iterate over the whole dataset until convergence.


**Identify an I/O (inputs/outputs) specification**: briefly anticipate what are the inputs to your new algorithm and the expected outcomes.

Inputs

  * A *b=0* reference - this is a 3D file resulting from a varyingly sophisticated average across the *b=0* volumes in the dataset.
  * Orientation matrix in "RAS+B" format. This means that b-vectors are given in "scanner" coordinates (as opposed to "voxel" coordinates) and must have unit-norm. An additional column provides the sensitization intensity value (*b* value) in *s/mm^2*.
  * *high-b* DWI data (4D file) - in other words, the original DWI dataset after extracting the *b=0* volumes out.
  * A boolean indicating whether this is single-shell, multi-shell or non-shelled (e.g., Cartesian sampling such as DSI) dataset.
  * DWI prediction model specification (model name + parameters)
  * Image registration framework specification (including parameters)

Outputs

  * List of affine matrices estimated by algorithm, which collapse the distortion from both sources.
  * List of rigid-body transformation matrices decomposed from the latter, representing the estimated head-motion parameters.
  * List of the residuals of the previous decomposition, representing the affine distortions attributed to eddy-currents.
  * A new DWI file (4D) resampling the data via the estimated affine matrices.
  * New orientation matrix in "RAS+B" format, after rotation by the rigid-body motions estimated.

What this idea doesn't cover:

  * Conversion into RAS+B format of the gradient matrix.
  * Generation of average *b=0* reference.
  * Calculation of Framewise-Displacement or any other data quality estimation.

**Nonfunctional requirements**: briefly anticipate further requirements that are important, but do not alter the goal of the project.

  * Memory fingerprint: DWIs can be large, and storing them in memory (and subsequent derivatives thereof) can be cumbersome, or even prohibitive.
  * Parallelism: simulation and registration are CPU-intensive processes - for the runtime to be in a manageable scale, we'll need to leverage parallelism.

**Sketch out an API (application programmer interface)**: Plan how the new software will expose the implementation downstream.
Assuming our DWI data is encapsulated in an object (holding not just the data array, but also metadata such as the gradient table)
pointed at by the variable `data`, and assuming we have a list of rigid-body transform matrices to initialize the algorithm (`mats`),
a potential API would have a `.fit()` and `.predict()` members which run the algorithm (the former) and generate an EM-corrected
DWI (the latter):

```{code-cell} python
from newmodule import EddyMotionEstimation

estimator = EddyMotionEstimation()
estimator.fit(data, init=mats)

corrected = estimator.predict(data)
```

## Step 3: data structures
How you feed in data into your algorithm will impose constraints that might completely hinder the implementation of nonfunctional requirements down the line.
Therefore, a careful plan must also be thought out for the data structures we are going to handle.

In this case, we want to create a Python data structure that encapsulates our DWI information (in other words, most of the *Inputs* identified in the previous step).
DWI data are usually large in size, so we will use HDF5 internally to store data into hard-disk while enjoying an easy interface with random access to memory.
After the two previous units of this tutorial, we should have a good picture of the problem by now.
Let's sketch out our new data object:

```{code-cell} python
"""Representing data in hard-disk and memory."""
import attr
import numpy as np


@attr.s(slots=True)
class DWI:
    """Data representation structure for dMRI data."""

    dataobj = attr.ib(default=None)
    """A numpy ndarray object for the data array, without *b=0* volumes."""
    bzero = attr.ib(default=None)
    """
    A *b=0* reference map, preferably obtained by some smart averaging.
    If the :math:`B_0` fieldmap is set, this *b=0* reference map should also
    be unwarped.
    """
    gradients = attr.ib(default=None)
    """A 2D numpy array of the gradient table in RAS+B format."""
    sampling = attr.ib(default=None)
    """Sampling of q-space: single-, multi-shell or cartesian."""
    affines = attr.ib(default=None)
    """List of linear matrices that bring DWIs (i.e., no b=0) into alignment."""
    fieldmap = attr.ib(default=None)
    """A 3D displacements field to unwarp susceptibility distortions."""

    def to_filename(filename):
        """Write an HDF5 file to disk."""
        raise NotImplementedError

    @classmethod
    def from_filename(cls, filename):
        """Reads an HDF5 file from disk."""
        raise NotImplementedError

```
