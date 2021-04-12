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

# The problem of head-motion in dMRI

```{code-cell} python
:tags: [hide-cell]

import warnings

warnings.filterwarnings("ignore")

from IPython.display import HTML
```

A recurring problem for any MRI acquisition is that image reconstruction and modeling are extremely sensitive to very small changes in the position of the imaged object.
Rigid-body, bulk-motion of the head will degrade every image, even if the experimenters closely followed all the standard operation procedures and carefully prepared the experiment (e.g., setting correctly the head paddings), and even if the participant was experienced with the MR settings and strictly followed indications to avoid any movement outside time windows allocated for rest.
This effect is exacerbated by the length of the acquisition (longer acquisitions will have more motion), and is not limited to humans.
For instance, although rats are typically acquired with head fixations and under sedation, their breathing (especially when assisted) generally causes motion.
Even the vibration of the scanner itself can introduce motion!

```{code-cell} python
HTML("""<video width="640" height="680" loop="yes" muted="yes" autoplay="yes" controls="yes"><source src="../assets/videos/hm-sagittal.mp4" type="video/mp4"/></video>""")
```

## Dimensions of the head-motion problem

These sudden and unavoidable motion of the head (for instance, when the participant swallowed) result in two degrading consequences that confuse the diffusion model through which we will attempt to understand the data:

- **Misalignment between the different angular samplings**, which means that the same *(i, j, k)* voxel in one orientation will not contain a diffusion measurement of exactly the same anatomical location of the rest of the orientations (see [these slides by Dr. A. Yendiki in 2013](http://ftp.nmr.mgh.harvard.edu/pub/docs/TraculaNov2013/tracula.workshop.iv.pdf)).
- **Attenuation** in the recorded intensity of a particular orientation, especially present when the sudden motion occurred during the diffusion-encoding gradient pulse.

While we can address the misalignment, it is really problematic to overcome the attenuation.

## Objective: Implement a head-motion estimation code

This tutorial focuses on the misalignment problem.
We will build from existing software (DIPY for diffusion modeling and ANTs for image registration), as well as commonplace Python libraries (NumPy), a software framework for head-motion estimation in diffusion MRI data.

The algorithmic and theoretical foundations of the method are based on an idea first proposed by [Ben-Amitay et al.](https://pubmed.ncbi.nlm.nih.gov/22183784/) and later implemented in *QSIPREP* (see this [OHBM 2019 poster](https://github.com/mattcieslak/ohbm_shoreline/blob/master/cieslakOHBM2019.pdf)).
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
- Calculation of Framewise-Displacement or any other data quality estimation.
- Outlier removal or correcting intensity dropout

**Nonfunctional requirements**: briefly anticipate further requirements that are important, but do not alter the goal of the project.

- Memory fingerprint: DWIs can be large, and storing them in memory (and subsequent derivatives thereof) can be cumbersome, or even prohibitive.
- Parallelism: simulation and registration are CPU-intensive processes - for the runtime to be in a manageable scale, we'll need to leverage parallelism.

**Sketch out an API (Application Programming Interface)**: Plan how the new software will expose the implementation downstream.
Assuming our DWI data is encapsulated in an object (holding not just the data array, but also metadata such as the gradient table)
pointed at by the variable `data`, and assuming we have a list of rigid-body transform matrices to initialize the algorithm (`mats`),
a potential API would have a `.fit()` and `.predict()` members which run the algorithm (the former) and generate an EM-corrected
DWI (the latter):

```python
from eddymotion import EddyMotionEstimator

estimator = EddyMotionEstimator()
estimator.fit(data, model="DTI")

corrected = estimator.predict(data)
```
