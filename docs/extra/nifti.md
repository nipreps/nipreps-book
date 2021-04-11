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

# The extra mile

## Investigating NIfTI images with *NiBabel*

[NiBabel](https://nipy.org/nibabel/) is a Python package for reading and writing neuroimaging data.
To learn more about how NiBabel handles NIfTIs, check out the [Working with NIfTI images](https://nipy.org/nibabel/nifti_images.html) page of the NiBabel documentation, from which this lesson is adapted from.

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
:tags: [output_scroll]

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

Lets plot the first 10 volumes.

```{code-cell} python
:tags: [output_scroll]

%matplotlib inline

from nilearn import image
from nilearn.plotting import plot_epi

selected_volumes = image.index_img(dwi, slice(0, 10))

for img in image.iter_img(selected_volumes):
    plot_epi(img, display_mode="z", cut_coords=(30, 53, 75), cmap="gray")
```

### 3. [Affine](https://nipy.org/nibabel/coordinate_systems.html): tells the position of the image array data in a reference space

The final important piece of metadata associated with an image file is the **affine matrix**.
Below is the affine matrix for our data.

```{code-cell} python
dwi_affine = dwi_img.affine
dwi_affine
```

To explain this concept, recall that we referred to coordinates in our data as *voxel coordinates (i,j,k)* coordinates such that:

* i is the first dimension of `dwi_data`
* j is the second dimension of `dwi_data`
* k is the third dimension of `dwi_data`

Although this tells us how to access our data in terms of voxels in a 3D volume, it doesn't tell us much about the actual dimensions in our data (centimetres, right or left, up or down, back or front).
The affine matrix allows us to translate between *voxel coordinates* and *world space coordinates* in (left/right,bottom/top,back/front).

An important thing to note is that in reality in which order you have:

* left/right
* bottom/top
* back/front

depends on how the affine matrix is constructed. For the data we're dealing with, it always refers to:

* Right
* Anterior
* Superior

Applying the affine matrix is done through using a *linear map* (matrix multiplication) on the voxel coordinates (defined in `dwi_data`).
