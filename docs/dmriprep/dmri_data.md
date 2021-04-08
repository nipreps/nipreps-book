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
To learn more about how NiBabel handles NIfTIs, check out the [Working with NIfTI images](https://nipy.org/nibabel/nifti_images.html) page of the NiBabel documentation, from which this episode is heavily based.

```{code-cell} python
import nibabel as nib
```

First, use the `load()` function to create a NiBabel image object from a NIfTI file.
We'll load in an example T1w image from the zip file we just downloaded.

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
We can achieve this by using the method called `dwi_img.get_fdata()`.

```{code-cell} python
dwi_data = dwi_img.get_fdata()
dwi_data
```

What type of data is this exactly? We can determine this by calling the `type()` function on `dwi_data`.

```{code-cell} python
type(dwi_data)
```

The data is a multidimensional **array** representing the image data.

Let's index the 3rd to 6th volumes.

```{code-cell} python
selected_volumes = image.index_img(dwi, slice, 3, 7)
```

```{code-cell} python
%matplotlib inline

from nilearn import image
from nilearn.plotting import plot_epi

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

To explain this concept, recall that we referred to coordinates in our data as (x,y,z) coordinates such that:

* x is the first dimension of `dwi_data`
* y is the second dimension of `dwi_data`
* z is the third dimension of `dwi_data`

Although this tells us how to access our data in terms of voxels in a 3D volume, it doesn't tell us much about the actual dimensions in our data (centimetres, right or left, up or down, back or front).
The affine matrix allows us to translate between *voxel coordinates* in (x,y,z) and *world space coordinates* in (left/right,bottom/top,back/front).
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

The b-value is the diffusion-sensitizing factor, and reflects the timing & strength of the gradients (measured in s/mm^2) used to acquire the diffusion-weighted images.

```{code-cell} python
!cat ../../data/sub-01_dwi.bval
```

The b-vector corresponds to the direction of the diffusion sensitivity. Each row corresponds to a value in the x, y, or z axis. The numbers are combined column-wise to get an [x y z] coordinate per DWI volume.

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
After reading the `.bval` and `.bvec` files with the `read_bvals_bvecs()` function, we get both in a numpy array. Notice that the `.bvec` file has been transposed so that the x, y, and z-components are in column format.

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

Because the diffusion gradient is critical for later analyzing the data, dMRIPrep performs several checks to ensure that the information is stored correctly.

### BIDS Validator

At the beginning of the pipeline, the BIDS Validator is run.
This package ensures that the data is BIDS-compliant and also has several dMRI-specific checks summarized below:

- all dMRI scans have a corresponding `.bvec` and `.bval` file
- the files aren't empty and formatted correctly
  - single space delimited
  - only contain numeric values
  - correct number of rows and volume information
  - volume information matches between image, `.bvec` and `.bval` files

### DiffusionGradientTable

In dMRIPrep, the `DiffusionGradientTable` class is used to read in the `.bvec` and `.bval` files, perform further sanity checks and make any corrections if needed.

```{code-cell} python
from dmriprep.utils.vectors import DiffusionGradientTable

dwi = "../../data/sub-02_dwi.nii.gz"
bvec = "../../data/sub-02_dwi.bvec"
bval = "../../data/sub-02_dwi.bval"

gt_bvals, gt_bvecs = read_bvals_bvecs(bval, bvec)

gtab = DiffusionGradientTable(dwi_file=dwi, bvecs=bvec, bvals=bval)
```

Below is a comparison of the `.bvec` and `.bval` files as read originally using `dipy` and after being corrected using `DiffusionGradientTable`.

```{code-cell} python
gt_bvals
```

It looks like this data has 5 unique b-values: 0, 600, 900, 1200 and 1800.
However, the actual values that are reported look slightly different.

```{code-cell} python
from collections import Counter
Counter(sorted(gt_bvals))
```

dMRIPrep does a bit of rounding internally to cluster the b-values into shells.

```{code-cell} python
gtab.bvals
```

```{code-cell} python
gt_bvecs[0:20]
```

It also replaces the b-vecs where a b-value of 0 is expected.

```{code-cell} python
gtab.bvecs[0:20]
```

Inspired by MRtrix3 and proposed in the [BIDS spec](https://github.com/bids-standard/bids-specification/issues/349), dMRIPrep also creates an optional `.tsv` file where the diffusion gradients are reported in scanner coordinates as opposed to image coordinates.
The [x y z] values reported earlier are recalculated in [R A S].

```{code-cell} python
gtab.gradients[0:20]
```

We can write out this `.tsv` to a file.

## DWI Data Object

```{code-cell} python
:tags: [hide-cell]

"""Representing data in hard-disk and memory."""
from pathlib import Path
from collections import namedtuple
from tempfile import mkdtemp
import attr
import numpy as np
import h5py
import nibabel as nb
from nitransforms.linear import Affine


def _data_repr(value):
    if value is None:
        return "None"
    return f"<{'x'.join(str(v) for v in value.shape)} ({value.dtype})>"


@attr.s(slots=True)
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
    """A path to an HDF5 file to store the whole dataset."""

    def __len__(self):
        """Obtain the number of high-*b* orientations."""
        return self.gradients.shape[-1]

    def logo_split(self, index, with_b0=False):
        """
        Produce one fold of LOGO (leave-one-gradient-out).
        Parameters
        ----------
        index : :obj:`int`
            Index of the DWI orientation to be left out in this fold.
        Return
        ------
        (train_data, train_gradients) : :obj:`tuple`
            Training DWI and corresponding gradients.
            Training data/gradients come **from the updated dataset**.
        (test_data, test_gradients) :obj:`tuple`
            Test 3D map (one DWI orientation) and corresponding b-vector/value.
            The test data/gradient come **from the original dataset**.
        """
        if not Path(self._filepath).exists():
            self.to_filename(self._filepath)

        # read original DWI data & b-vector
        with h5py.File(self._filepath, "r") as in_file:
            root = in_file["/0"]
            dwframe = np.asanyarray(root["dataobj"][..., index])
            bframe = np.asanyarray(root["gradients"][..., index])

        # if the size of the mask does not match data, cache is stale
        mask = np.zeros(len(self), dtype=bool)
        mask[index] = True

        train_data = self.dataobj[..., ~mask]
        train_gradients = self.gradients[..., ~mask]

        if with_b0:
            train_data = np.concatenate(
                (np.asanyarray(self.bzero)[..., np.newaxis], train_data),
                axis=-1,
            )
            b0vec = np.zeros((4, 1))
            b0vec[0, 0] = 1
            train_gradients = np.concatenate(
                (b0vec, train_gradients),
                axis=-1,
            )

        return (
            (train_data, train_gradients),
            (dwframe, bframe),
        )

    def set_transform(self, index, affine, order=3):
        """Set an affine, and update data object and gradients."""
        reference = namedtuple("ImageGrid", ("shape", "affine"))(
            shape=self.dataobj.shape[:3], affine=self.affine
        )

        # create a nitransforms object
        if self.fieldmap:
            # compose fieldmap into transform
            raise NotImplementedError
        else:
            xform = Affine(matrix=affine, reference=reference)

        if not Path(self._filepath).exists():
            self.to_filename(self._filepath)

        # read original DWI data & b-vector
        with h5py.File(self._filepath, "r") as in_file:
            root = in_file["/0"]
            dwframe = np.asanyarray(root["dataobj"][..., index])
            bvec = np.asanyarray(root["gradients"][:3, index])

        dwmoving = nb.Nifti1Image(dwframe, self.affine, None)

        # resample and update orientation at index
        self.dataobj[..., index] = np.asanyarray(
            xform.apply(dwmoving, order=order).dataobj,
            dtype=self.dataobj.dtype,
        )

        # invert transform transform b-vector and origin
        r_bvec = (~xform).map([bvec, (0.0, 0.0, 0.0)])
        # Reset b-vector's origin
        new_bvec = r_bvec[1] - r_bvec[0]
        # Normalize and update
        self.gradients[:3, index] = new_bvec / np.linalg.norm(new_bvec)

        # update transform
        if self.em_affines is None:
            self.em_affines = [None] * len(self)

        self.em_affines[index] = xform

    def to_filename(self, filename):
        """Write an HDF5 file to disk."""
        filename = Path(filename)
        if not filename.name.endswith(".h5"):
            filename = filename.parent / f"{filename.name}.h5"

        with h5py.File(filename, "w") as out_file:
            out_file.attrs["Format"] = "EMC/DWI"
            out_file.attrs["Version"] = np.uint16(1)
            root = out_file.create_group("/0")
            root.attrs["Type"] = "dwi"
            for f in attr.fields(self.__class__):
                if f.name.startswith("_"):
                    continue

                value = getattr(self, f.name)
                if value is not None:
                    root.create_dataset(
                        f.name,
                        data=value,
                    )

    def to_nifti(self, filename):
        """Write a NIfTI 1.0 file to disk."""
        nii = nb.Nifti1Image(
            self.dataobj,
            self.affine,
            None,
        )
        nii.header.set_xyzt_units("mm")
        nii.to_filename(filename)

    @classmethod
    def from_filename(cls, filename):
        """Read an HDF5 file from disk."""
        with h5py.File(filename, "r") as in_file:
            root = in_file["/0"]
            retval = cls(**{k: v for k, v in root.items()})
        return retval


def load(
    filename, gradients_file=None, b0_file=None, brainmask_file=None, fmap_file=None
):
    """Load DWI data."""
    filename = Path(filename)
    if filename.name.endswith(".h5"):
        return DWI.from_filename(filename)

    if not gradients_file:
        raise RuntimeError("A gradients file is necessary")

    img = nb.as_closest_canonical(nb.load(filename))
    retval = DWI(
        affine=img.affine,
    )
    grad = np.loadtxt(gradients_file, dtype="float32").T
    gradmsk = grad[-1] > 50
    retval.gradients = grad[..., gradmsk]
    retval.dataobj = img.get_fdata(dtype="float32")[..., gradmsk]

    if b0_file:
        b0img = nb.as_closest_canonical(nb.load(b0_file))
        retval.bzero = np.asanyarray(b0img.dataobj)

    if brainmask_file:
        mask = nb.as_closest_canonical(nb.load(brainmask_file))
        retval.brainmask = np.asanyarray(mask.dataobj)

    if fmap_file:
        fmapimg = nb.as_closest_canonical(nb.load(fmap_file))
        retval.fieldmap = fmapimg.get_fdata(fmapimg, dtype="float32")

    return retval
```