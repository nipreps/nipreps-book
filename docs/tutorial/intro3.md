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

# Code

```{code-cell} python
:tags: [hide-cell]

import warnings
warnings.filterwarnings("ignore")
```

## Step 2: Planning ahead
Once you get the 👍 from the project maintainers, you are ready to begin your contribution!

First, you should accurately define the problem:

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

- A *b=0* reference - this is a 3D file resulting from a varyingly sophisticated average across the *b=0* volumes in the dataset.
- Orientation matrix in "RAS+B" format. This means that b-vectors are given in "scanner" coordinates (as opposed to "voxel" coordinates) and must have unit-norm. An additional column provides the sensitization intensity value (*b* value) in *s/mm^2*.
- *high-b* DWI data (4D file) - in other words, the original DWI dataset after extracting the *b=0* volumes out.
- A boolean indicating whether this is single-shell, multi-shell or non-shelled (e.g., Cartesian sampling such as DSI) dataset.
- DWI prediction model specification (model name + parameters)
- Image registration framework specification (including parameters)

Outputs

- List of affine matrices estimated by algorithm, which collapse the distortion from both sources.
- List of rigid-body transformation matrices decomposed from the latter, representing the estimated head-motion parameters.
- List of the residuals of the previous decomposition, representing the affine distortions attributed to eddy-currents.
- A new DWI file (4D) resampling the data via the estimated affine matrices.
- New orientation matrix in "RAS+B" format, after rotation by the rigid-body motions estimated.

What this idea doesn't cover:

- Conversion into RAS+B format of the gradient matrix.
- Generation of average *b=0* reference.
- Calculation of Framewise-Displacement or any other data quality estimation.

**Nonfunctional requirements**: briefly anticipate further requirements that are important, but do not alter the goal of the project.

- Memory fingerprint: DWIs can be large, and storing them in memory (and subsequent derivatives thereof) can be cumbersome, or even prohibitive.
- Parallelism: simulation and registration are CPU-intensive processes - for the runtime to be in a manageable scale, we'll need to leverage parallelism.

**Sketch out an API (Application Programming Interface)**: Plan how the new software will expose the implementation downstream.
Assuming our DWI data is encapsulated in an object (holding not just the data array, but also metadata such as the gradient table)
pointed at by the variable `data`, and assuming we have a list of rigid-body transform matrices to initialize the algorithm (`mats`),
a potential API would have a `.fit()` and `.predict()` members which run the algorithm (the former) and generate an EM-corrected
DWI (the latter):

```{code-cell} python
from emc import EddyMotionEstimator

estimator = EddyMotionEstimator()
estimator.fit(data, init=mats)

corrected = estimator.predict(data)
```

## Step 3: Data structures
How you feed in data into your algorithm will impose constraints that might completely hinder the implementation of nonfunctional requirements down the line.
Therefore, a careful plan must also be thought out for the data structures we are going to handle.

In this case, we want to create a Python data structure that encapsulates our DWI information (in other words, most of the *Inputs* identified in the previous step).
DWI data are usually large in size, so we will use HDF5 internally to store data into hard-disk while enjoying an easy interface with random access to memory.
After the two previous units of this tutorial, we should have a good picture of the problem by now.
Let's sketch out our new data object:

```{code-block} python
import numpy as np
from pathlib import Path

class DWI:
    """Data representation structure for dMRI data."""

    dataobj = attr.ib(default=None, repr=_data_repr)
    """A numpy ndarray object for the data array, without *b=0* volumes."""
    affine = attr.ib(default=None, repr=_data_repr)
    """Best affine for RAS-to-voxel conversion of coordinates (NIfTI header)."""
    brainmask = attr.ib(default=None, repr=_data_repr)
    """A boolean ndarray object containing a corresponding brainmask."""
    bzero = attr.ib(default=None, repr=_data_repr)
    """
    A *b=0* reference map, preferably obtained by some smart averaging.
    If the :math:`B_0` fieldmap is set, this *b=0* reference map should also
    be unwarped.
    """
    gradients = attr.ib(default=None, repr=_data_repr)
    """A 2D numpy array of the gradient table in RAS+B format."""
    em_affines = attr.ib(default=None)
    """
    List of :obj:`nitransforms.linear.Affine` objects that bring
    DWIs (i.e., no b=0) into alignment.
    """
    fieldmap = attr.ib(default=None, repr=_data_repr)
    """A 3D displacements field to unwarp susceptibility distortions."""
    _filepath = attr.ib(default=Path(mkdtemp()) / "em_cache.h5", repr=False)
    """A path to an HDF5 file to store the whole dataset."""@attr.s(slots=True)


    def to_filename(filename):
        """Write an HDF5 file to disk."""
        raise NotImplementedError

    @classmethod
    def from_filename(cls, filename):
        """Reads an HDF5 file from disk."""
        raise NotImplementedError
```

---

SHOW TRADITIONAL WAY OF WRITING CLASS

```{code-cell} python
import numpy as np
from pathlib import Path


class DWI:
    """Data representation structure for dMRI data."""

    __slots__ = [
        "_dataobj",
        "_affine",
        "_brainmask",
        "_bzero",
        "_gradients",
        "_em_affines",
        "_fieldmap",
        "_filepath",
    ]

    def __init__(
       self,
       dataobj=None,
       affine=None,
       brainmask=None,
       bzero=None,
       gradients=None,
       em_affines=None,
       fieldmap=None,
       filepath=Path(mkdtemp()) / "em_cache.h5"
    ):
    """
    Parameters
    ----------

    dataobj = attr.ib(default=None, repr=_data_repr)
        A numpy ndarray object for the data array, without *b=0* volumes.
    affine = attr.ib(default=None, repr=_data_repr)
        Best affine for RAS-to-voxel conversion of coordinates (NIfTI header).
    brainmask = attr.ib(default=None, repr=_data_repr)
        A boolean ndarray object containing a corresponding brainmask.
    bzero = attr.ib(default=None, repr=_data_repr)
        A *b=0* reference map, preferably obtained by some smart averaging.
        If the :math:`B_0` fieldmap is set, this *b=0* reference map should also
        be unwarped.
    gradients = attr.ib(default=None, repr=_data_repr)
        A 2D numpy array of the gradient table in RAS+B format.
    em_affines = attr.ib(default=None)
        List of :obj:`nitransforms.linear.Affine` objects that bring
        DWIs (i.e., no b=0) into alignment.
    fieldmap = attr.ib(default=None, repr=_data_repr)
        A 3D displacements field to unwarp susceptibility distortions.
    _filepath = attr.ib(default=Path(mkdtemp()) / "em_cache.h5", repr=False)
        A path to an HDF5 file to store the whole dataset.

    """

    self._dataobj = dataobj


    def to_filename(filename):
        """Write an HDF5 file to disk."""
        raise NotImplementedError

    @classmethod
    def from_filename(cls, filename):
        """Reads an HDF5 file from disk."""
        raise NotImplementedError

```

DISCUSS HDF5 - same file format as MINC


## Step 4: NiTransforms

NiTransforms was born as a small side project with a vision of completing NiBabel. NiBabel is pretty comprehensive with working with different imaging file formats.

## Step 5: Registration targets

Using dipy to predict registration target in logo method

