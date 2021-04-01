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

Diffusion imaging probes the random, microscopic motion of water protons by employing MRI sequences which are sensitive to the geometry and environmental organization surrounding the water protons.
This is a popular technique for studying the white matter of the brain.
The diffusion within biological structures, such as the brain, are often restricted due to barriers (eg. cell membranes), resulting in a preferred direction of diffusion (anisotropy).
A typical dMRI scan will acquire multiple volumes that are sensitive to a particular diffusion direction.

## Diffusion Gradient Schemes

In addition to the acquired diffusion images, two files are collected as part of the diffusion dataset.
These files correspond to the gradient amplitude (b-values) and directions (b-vectors) of the diffusion measurement and are named with the extensions `.bval` and `.bvec` respectively.

```{code-cell} python
dwi = "../../data/sub-01_dwi.nii.gz"
bvec = "../../data/sub-01_dwi.bvec"
bval = "../../data/sub-01_dwi.bval"
```

The b-value is the diffusion-sensitizing factor, and reflects the timing & strength of the gradients (measured in s/mm2) used to acquire the diffusion-weighted images.

```{code-cell} python
!cat ../../data/sub-01_dwi.bval
```

The b-vector corresponds to the direction of the diffusion sensitivity. Each row corresponds to a value in the x, y, or z axis. The numbers are combined column-wise to get an [x y z] coordinate per DWI volume. 

```{code-cell} python
!cat ../../data/sub-01_dwi.bvec
```

Together these two files define the dMRI measurement as a set of gradient directions and corresponding amplitudes.

In the example data above, we see that 2 b-values were chosen for this scanning sequence.
The first few images were acquired with a b-value of 0 and are typically referred to as b=0 images.
In these images, no diffusion gradient is applied.
These images don't hold any diffusion information and are used as a reference (head motion correction) since they aren't subject to the same types of scanner artifacts that affect diffusion-weighted images.

All of the remaining images have a b-value of 1000 and have a diffusion gradient associated with them.
Diffusion that exhibits directionality in the same direction as the gradient result in a loss of signal.
With further processing, the acquired images can provide measurements which are related to the microscopic changes and estimate white matter trajectories.

```{code-cell} python
%matplotlib inline

from nilearn import image
from nilearn.plotting import plot_epi

selected_volumes = image.index_img(dwi, slice(3, 7))

for img in image.iter_img(selected_volumes):
    plot_epi(img, display_mode="z", cut_coords=(30, 53, 75), cmap="gray")
```

After reading the `.bval` and `.bvec` files with the `read_bvals_bvecs()` function, we get both in a numpy array. Notice that the `.bvec` file has been transposed so that the x, y, and z-components are in column format.

```{code-cell} python
from dipy.io import read_bvals_bvecs

gt_bvals, gt_bvecs = read_bvals_bvecs(bval, bvec)
gt_bvecs
```

```{code-cell} python
import matplotlib.pyplot as plt

fig = plt.figure()
ax = fig.add_subplot(111, projection="3d")
ax.scatter(gt_bvecs.T[0], gt_bvecs.T[1], gt_bvecs.T[2])
plt.show()
```

It is important to note that in this format, the diffusion gradients are provided with respect to the image axes, not in real or scanner coordinates. Simply reformatting the image from sagittal to axial will effectively rotate the b-vectors, since this operation changes the image axes. Thus, a particular bvals/bvecs pair is only valid for the particular image that it corresponds to.

## Diffusion Gradient Operations

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

Why is this important?

Below is an example of how improperly encoded bvecs can affect tractography.
![incorrect_bvecs](../images/incorrect_bvecs.png)

`MRtrix3` has actually created a handy tool called `dwigradcheck` to confirm whether the diffusion gradient table is oriented correctly.

```
$ dwigradcheck -fslgrad ../../data/sub-02_dwi.bvec ../../data/sub-02_dwi.bval ../../data/sub-02_dwi.nii.gz

> Mean length     Axis flipped    Axis permutations    Axis basis
52.41         none                (0, 1, 2)           image
51.68         none                (0, 1, 2)           scanner
32.70            1                (0, 1, 2)           image
32.25            1                (0, 1, 2)           scanner
31.23            0                (0, 2, 1)           scanner
30.97            2                (0, 1, 2)           scanner
30.82            0                (0, 2, 1)           image
29.41            2                (0, 1, 2)           image
29.31         none                (0, 2, 1)           image
28.61         none                (1, 0, 2)           image
28.57            2                (1, 0, 2)           scanner
28.46         none                (0, 2, 1)           scanner
28.41         none                (2, 1, 0)           scanner
28.40         none                (1, 0, 2)           scanner
28.14            0                (0, 1, 2)           scanner
28.04         none                (2, 1, 0)           image
27.92            1                (2, 1, 0)           image
27.80            1                (2, 1, 0)           scanner
27.71            2                (1, 0, 2)           image
27.54            0                (0, 1, 2)           image
23.43            1                (0, 2, 1)           image
22.86            1                (0, 2, 1)           scanner
21.55            2                (0, 2, 1)           scanner
21.44            0                (1, 2, 0)           scanner
21.35            2                (0, 2, 1)           image
21.03            1                (1, 0, 2)           image
20.88            0                (1, 0, 2)           image
20.87            1                (1, 2, 0)           image
20.80            0                (2, 0, 1)           scanner
20.74            0                (1, 0, 2)           scanner
20.41            2                (2, 0, 1)           scanner
20.38            1                (1, 0, 2)           scanner
20.25            0                (2, 1, 0)           image
20.24            0                (1, 2, 0)           image
20.21            1                (1, 2, 0)           scanner
20.15            1                (2, 0, 1)           image
20.13            2                (1, 2, 0)           scanner
20.11            2                (2, 0, 1)           image
20.04            1                (2, 0, 1)           scanner
19.94            0                (2, 0, 1)           image
19.87         none                (2, 0, 1)           scanner
19.86         none                (2, 0, 1)           image
19.83            2                (2, 1, 0)           scanner
19.72            2                (1, 2, 0)           image
19.59         none                (1, 2, 0)           image
19.49            0                (2, 1, 0)           scanner
19.45            2                (2, 1, 0)           image
19.43         none                (1, 2, 0)           scanner
```
