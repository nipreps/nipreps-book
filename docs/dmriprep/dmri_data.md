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

# Introduction to dMRI Data

```{code-cell} python
:tags: [hide-cell]

import warnings
warnings.filterwarnings("ignore")
```

Diffusion imaging probes the random, microscopic motion of water protons by using MRI sequences that are sensitive to the geometry and environmental organization surrounding these protons.
This is a popular technique for studying the white matter of the brain.
The diffusion within biological structures, such as the brain, are often restricted due to barriers (eg. cell membranes), resulting in a preferred direction of diffusion (anisotropy).
A typical dMRI scan will acquire multiple volumes that are sensitive to different diffusion directions.

[NiBabel](https://nipy.org/nibabel/) is a Python package for reading and writing neuroimaging data.
To learn more about how NiBabel handles NIfTIs, check out the [Working with NIfTI images](https://nipy.org/nibabel/nifti_images.html) page of the NiBabel documentation.

```{code-cell} python
import nibabel as nib
```

First, use the `load()` function to create a NiBabel image object from a NIfTI file.
We'll load in an example dMRI file from the `data` folder.

```{code-cell} python
dwi = "../../data/sub-01_dwi.nii.gz"

dwi_img = nib.load(dwi)
```

Loading in a NIfTI file with `NiBabel` gives us a special type of data object which encodes all the information in the file.
Each bit of information is called an **attribute** in Python's terminology.
To see all of these attributes, type `dwi_img.` followed by <kbd>Tab</kbd>.
There are three main attributes that we'll discuss today:

### 1. [Header](https://nipy.org/nibabel/nibabel_images.html#the-image-header): contains metadata about the image, such as image dimensions, data type, etc.

```{code-cell} python
dwi_hdr = dwi_img.header
print(dwi_hdr)
```

### 2. Data

As you've seen above, the header contains useful information that gives us information about the properties (metadata) associated with the dMRI data we've loaded in.
Now we'll move in to loading the actual *image data itself*.
We can achieve this by using the `get_fdata()` method.

```{code-cell} python
dwi_data = dwi_img.get_fdata()
dwi_data
```

What type of data is this exactly? We can determine this by calling the `type()` function on `dwi_data`.

```{code-cell} python
type(dwi_data)
```

The data is a multidimensional **array** representing the image data.

How many dimensions are in the `dwi_data` array?

```{code-cell} python
dwi_data.ndim
```

As expected, the data contains 4 dimensions (*i, j, k* and gradient number).

How big is each dimension?

```{code-cell} python
dwi_data.shape
```

This tells us that the image is 128, 128, 66

Lets plot each volume.

```{code-cell} python
%matplotlib inline

from nilearn import image
from nilearn.plotting import plot_epi

for img in image.iter_img(dwi_data):
    plot_epi(img, display_mode="z", cut_coords=(30, 53, 75), cmap="gray")
```

One of the first things we do before image registration is brain extraction, separating any non-brain material from brain tissue.
This is done so that our algorithms aren't biased or distracted by whatever is in non-brain material and we don't spend extra time analyzing things we don't care about

INSERT brain masking section here.

### 3. [Affine](https://nipy.org/nibabel/coordinate_systems.html): tells the position of the image array data in a reference space

The final important piece of metadata associated with an image file is the **affine matrix**.
Below is the affine matrix for our data.

```{code-cell} python
dwi_affine = dwi_img.affine
dwi_affine
```

To explain this concept, recall that we referred to coordinates in our data as *(i,j,k)* coordinates such that:

* i is the first dimension of `dwi_data`
* j is the second dimension of `dwi_data`
* k is the third dimension of `dwi_data`

Although this tells us how to access our data in terms of voxels in a 3D volume, it doesn't tell us much about the actual dimensions in our data (centimetres, right or left, up or down, back or front).
The affine matrix allows us to translate between *voxel coordinates* in (i,j,k) and *world space coordinates* in (left/right,bottom/top,back/front).
An important thing to note is that in reality in which order you have:

* left/right
* bottom/top
* back/front

Depends on how you've constructed the affine matrix, but for the data we're dealing with it always refers to:

* Right
* Anterior
* Superior

Applying the affine matrix is done through using a *linear map* (matrix multiplication) on voxel coordinates (defined in `dwi_data`).

## Diffusion gradient schemes

In addition to the acquired diffusion images, two files are collected as part of the diffusion dataset.
These files correspond to the gradient amplitude (b-values) and directions (b-vectors) of the diffusion measurement and are named with the extensions `.bval` and `.bvec` respectively.

```{code-cell} python
bvec = "../../data/sub-01_dwi.bvec"
bval = "../../data/sub-01_dwi.bval"
```

The b-value is the diffusion-sensitizing factor, and reflects both the timing & strength of the gradients (measured in s/mm^2) used to acquire the diffusion-weighted images.

```{code-cell} python
!cat ../../data/sub-01_dwi.bval
```

The b-vector corresponds to the direction of the diffusion sensitivity. Each row corresponds to a value in the i, j, or k axis. The numbers are combined column-wise to get an [i j k] coordinate per DWI volume.

```{code-cell} python
!cat ../../data/sub-01_dwi.bvec
```

Together these two files define the dMRI measurement as a set of gradient directions and corresponding amplitudes.

In our example data, we see that 2 b-values were chosen for this scanning sequence.
The first few images were acquired with a b-value of 0 and are typically referred to as b=0 images.
In these images, no diffusion gradient is applied.
These images don't hold any diffusion information and are used as a reference (for head motion correction or brain masking) since they aren't subject to the same types of scanner artifacts that affect diffusion-weighted images.

All of the remaining images have a b-value of 1000 and have a diffusion gradient associated with them.
Diffusion that exhibits directionality in the same direction as the gradient results in a loss of signal.
With further processing, the acquired images can provide measurements which are related to the microscopic changes and estimate white matter trajectories.

```{figure} ../images/dMRI-signal-movie.mp4
```

We'll use some functions from [Dipy](https://dipy.org), a Python package for pre-processing and analyzing diffusion data.
After reading the `.bval` and `.bvec` files with the `read_bvals_bvecs()` function, we get both in a numpy array. Notice that the `.bvec` file has been transposed so that the i, j, and k-components are in column format.

```{code-cell} python
from dipy.io import read_bvals_bvecs

gt_bvals, gt_bvecs = read_bvals_bvecs(bval, bvec)
gt_bvecs
```

Below is a plot of all of the diffusion directions that we've acquired.

```{code-cell} python
import matplotlib.pyplot as plt

fig = plt.figure()
ax = fig.add_subplot(111, projection="3d")
ax.scatter(gt_bvecs.T[0], gt_bvecs.T[1], gt_bvecs.T[2])
plt.show()
```

It is important to note that in this format, the diffusion gradients are provided with respect to the image axes, not in real or scanner coordinates. Simply reformatting the image from sagittal to axial will effectively rotate the b-vectors, since this operation changes the image axes. Thus, a particular bvals/bvecs pair is only valid for the particular image that it corresponds to.

The diffusion gradient is critical for later analyzing the data

In dMRIPrep, the `DiffusionGradientTable` class is used to read in the `.bvec` and `.bval` files, perform further sanity checks and make any corrections if needed.

```{code-cell} python
from dmriprep.utils.vectors import DiffusionGradientTable

gtab = DiffusionGradientTable(dwi_file=dwi, bvecs=bvec, bvals=bval)
```

Inspired by MRtrix3 and proposed in the [BIDS spec](https://github.com/bids-standard/bids-specification/issues/349), dMRIPrep also creates an optional `.tsv` file where the diffusion gradients are reported in scanner coordinates as opposed to image coordinates.
The [i j k] values reported earlier are recalculated in [R A S].

```{code-cell} python
gtab.gradients[0:20]
```

We can write out this `.tsv` to a file.

## DWI Data Object

Managing all of our files in one place.

```{code-cell} python
from emc import dmri

?dmri.DWI
```