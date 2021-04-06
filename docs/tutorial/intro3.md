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

```
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

Let's sketch out our new data object.
Below, we have included some boilerplate to get you started.
You'll notice that this Python class may look different from something you might've seen in the past.
We are using the [`attr` package](https://www.attrs.org/en/stable/), which gives us a faster and more concise way of declaring our class attributes.

`__repr__` returns object representation in string format. what is this being used for?

**Exercise 1**

```{code-cell} python
import attr
import numpy as np
from pathlib import Path

def _data_repr(value):
    if value is None:
        return "None"
    return f"<{'x'.join(str(v) for v in value.shape)} ({value.dtype})>"


@attr.s(slots=True)
class DWI:
    """Data representation structure for dMRI data."""

    dataobj = attr.ib(default=None, repr=_data_repr)
    """A numpy ndarray object for the data array, without *b=0* volumes."""
    affine =
    brainmask =
    bzero =
    gradients =
    em_affines =
    fieldmap =
    _filepath =

```

** Solution 1**

```{code-cell} python
:tags: [hide-cell]

import attr
import numpy as np
from pathlib import Path

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
    """A path to an HDF5 file to store the whole dataset."""@attr.s(slots=True)


    def to_filename(filename):
        """Write an HDF5 file to disk."""
        raise NotImplementedError

    @classmethod
    def from_filename(cls, filename):
        """Reads an HDF5 file from disk."""
        raise NotImplementedError
```

Next, we will update our functions to read and write HDF5 files to and from disk.

**Exercise 2**

```{code-cell} python

def to_filename(filename):
    """Write an HDF5 file to disk."""
    raise NotImplementedError

@classmethod
def from_filename(cls, filename):
    """Reads an HDF5 file from disk."""
    raise NotImplementedError

def to_nifti(self, filename):
    """Write a NIfTI 1.0 file to disk."""
    raise NotImplementedError

```

**Solution 2**

```{code-cell} python
:tags: [hide-cell]

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

@classmethod
def from_filename(cls, filename):
    """Read an HDF5 file from disk."""
    with h5py.File(filename, "r") as in_file:
        root = in_file["/0"]
        retval = cls(**{k: v for k, v in root.items()})
    return retval

def to_nifti(self, filename):
    """Write a NIfTI 1.0 file to disk."""
    nii = nb.Nifti1Image(
        self.dataobj,
        self.affine,
        None,
    )
    nii.header.set_xyzt_units("mm")
    nii.to_filename(filename)

```

Next, we'll implement our leave one diffusion orientation out method.

**Exercise 3**

```{code-cell} python
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

```

```{code-cell} python
:tags: [hide-cell]

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

```

**Exercise 4** Loading it all in

```{code-cell} python

def load(filename, gradients_file, b0_file, brainmask_file, fmap_file):
    """Load DWI data."""

```

**Solution 4**

```{code-cell} python
:tags: [hide-cell]

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
## Step 4: Image registration using NiTransforms

NiTransforms was born as a small side project with a vision of completing NiBabel. NiBabel is pretty comprehensive with working with different imaging file formats.

```{figure} ../images/nitransforms.svg
:name: NiTransforms
```

```{code-cell} python

from niworkflows.viz.notebook import display

```

## Step 5: Registration targets

Using dipy to predict registration target in logo method

## Step 6: Rotating gradient directions

## Step 7: Testing

Download IXI inputs from OSF
- denoised dwi
- gradient table
- mask
- b0