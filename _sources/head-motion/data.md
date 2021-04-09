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

# Introduction to dMRI data

```{code-cell} python
:tags: [hide-cell]

import warnings
warnings.filterwarnings("ignore")


def _data_repr(value):
    if value is None:
        return "None"
    return f"<{'x'.join(str(v) for v in value.shape)} ({value.dtype})>"

```

Diffusion imaging probes the random, microscopic motion of water protons by using MRI sequences that are sensitive to the geometry and environmental organization surrounding these protons.
This is a popular technique for studying the white matter of the brain.
The diffusion within biological structures, such as the brain, are often restricted due to barriers (eg. cell membranes), resulting in a preferred direction of diffusion (anisotropy).
A typical dMRI scan will acquire multiple volumes (or ***angular samples***), each sensitive to a particular ***diffusion direction***.
These *diffusion directions* (or ***orientations***) are a fundamental piece of metadata to interpret dMRI data, as models need to know the exact orientation of each angular sample.

```{admonition} Main elements of a dMRI dataset
- A 4D data array, where the last dimension encodes the reconstructed **diffusion direction *maps***.
- Tabular data or a 2D array, listing the **diffusion directions** and the encoding gradient strength.
```

In summary, dMRI involves ***complex data types*** that, as programmers, we want to access, query and manipulate with ease.

## Python and object oriented programming

Python is an [object oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming) language, which represent and encapsulate data types and corresponding behaviors into programming structures called *objects*.

Therefore, let's leverage Python to create *objects* that contain dMRI data.
In Python, *objects* can be specified by defining a class with name `DWI`.
To simplify class creation, we'll use the magic of a Python library called [`attrs`](https://www.attrs.org/en/stable/).

```{code-cell} python
"""Representing data in hard-disk and memory."""
import attr


@attr.s(slots=True)
class DWI:
    """Data representation structure for dMRI data."""

    dataobj = attr.ib(default=None, repr=_data_repr)
    """A numpy ndarray object for the data array, without *b=0* volumes."""
    brainmask = attr.ib(default=None, repr=_data_repr)
    """A boolean ndarray object containing a corresponding brainmask."""
    bzero = attr.ib(default=None, repr=_data_repr)
    """A *b=0* reference map, preferably obtained by some smart averaging."""
    gradients = attr.ib(default=None, repr=_data_repr)
    """A 2D numpy array of the gradient table in RAS+B format."""
    em_affines = attr.ib(default=None)
    """
    List of :obj:`nitransforms.linear.Affine` objects that bring
    DWIs (i.e., no b=0) into alignment.
    """

    def __len__(self):
        """Obtain the number of high-*b* orientations."""
        return self.gradients.shape[-1]

```

This first code implements several *attributes* and the first *behavior* - the `__len__` *method*.
The `__len__` method is special in Python, as it will be executed when we call the built-in function `len()` on our object.
Let's test this memory structure with some *simulated* data:

```{code-cell} python
# NumPy is a fundamental Python library
import numpy as np

# Let's create a new DWI object, with only gradient information that is random
dmri_dataset = DWI(gradients=np.random.normal(size=(4, 109)))

# Let's call Python's built-in len() function
print(len(dmri_dataset))
```

For simplicity, we will be using the full implementation from our [`emc` (EddyMotionCorrection) package](https://github.com/nipreps/EddyMotionCorrection/blob/57c518929146b23cc9534ab0b2d024aa136e25f8/emc/dmri.py)
