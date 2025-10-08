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

# Putting everything together

```{code-cell} python
:tags: [remove-cell]

import sys
import warnings
from pathlib import Path

warnings.filterwarnings("ignore")

repo_root = next(
    (
        directory
        for directory in (Path.cwd().resolve(), *Path.cwd().resolve().parents)
        if (directory / "pixi.toml").exists() or (directory / ".git").exists()
    ),
    Path.cwd().resolve(),
)
if str(repo_root) not in sys.path:
    sys.path.insert(0, str(repo_root))

from nifreeze.utils.iterators import random_iterator
from tutorial_data import load_tutorial_dmri_dataset

DATA_PATH = load_tutorial_dmri_dataset()
```

Once we have finalized the main components of the solution, it is time for integration.
We now want to iterate over all the *LOGO* partitions of the dataset, generate a synthetic reference through the model of choice, and finally estimate the misalignment between the left-out gradient and the synthetic reference.
This solution, must also abide by the API we have envisioned.

```{code-cell} python
from nifreeze.data.dmri import DWI

dmri_dataset = DWI.from_filename(DATA_PATH)
dmri_dataset.dataobj = dmri_dataset.dataobj[..., :32]
dmri_dataset.gradients = dmri_dataset.gradients[..., :32]
```

```{admonition} Exercise
Complete the code snipet below to integrate the different components into the final solution to the dMRI head-motion problem.
```

```python
class Estimator:
    """Estimates rigid-body head-motion and distortions derived from eddy-currents."""

    @staticmethod
    def fit(
        dwdata,
        *,
        n_iter=1,
        align_kwargs=None,
        model="b0",
        **kwargs,
    ):
        r"""
        Estimate head-motion and Eddy currents.

        <please write a descriptive documentation of the function here>

        """
        align_kwargs = align_kwargs or {}

        for i_iter in range(1, n_iter + 1):
            for i in random_iterator(len(dwdata)):
                # run a original-to-synthetic affine registration
                with TemporaryDirectory() as tmpdir:
                    # Factory creates the appropriate model and pipes arguments
                    dwmodel = ...

                    # generate a synthetic dw volume for the test gradient
                    predicted = dwmodel.fit_predict(i)

                    # Write arrays in memory to harddisk as NIfTI files
                    tmpdir = Path(tmpdir)
                    moving = tmpdir / "moving.nii.gz"
                    fixed = tmpdir / "fixed.nii.gz"
                    _to_nifti(data_test[0], moving)
                    _to_nifti(predicted, fixed)

                    # Prepare ANTs' antsRegistration via NiPype
                    registration = Registration(
                        fixed_image=str(fixed.absolute()),
                        moving_image=str(moving.absolute()),
                        **align_kwargs,
                    )

                    # execute ants command line
                    result = registration.run(cwd=str(tmpdir)).outputs

                    # read output transform
                    xform = nt.io.itk.ITKLinearTransform.from_filename(
                        result.forward_transforms[0]
                    )

                # update
                dwdata.set_transform(i, xform)

        return dwdata.em_affines
```

**Solution**

```{code-cell} python
:tags: [hide-cell]

class EddyMotionEstimator:
    """Estimates rigid-body head-motion and distortions derived from eddy-currents."""

    @staticmethod
    def fit(
        dwdata,
        *,
        n_iter=1,
        align_kwargs=None,
        model="b0",
        **kwargs,
    ):
        r"""
        Estimate head-motion and Eddy currents.

        Parameters
        ----------
        dwdata : :obj:`~nifreeze.data.dmri.DWI`
            The target DWI dataset, represented by this tool's internal
            type. The object is used in-place, and will contain the estimated
            parameters in its ``em_affines`` property, as well as the rotated
            *b*-vectors within its ``gradients`` property.
        n_iter : :obj:`int`
            Number of iterations this particular model is going to be repeated.
        align_kwargs : :obj:`dict`
            Parameters to configure the image registration process.
        model : :obj:`str`
            Selects the diffusion model that will generate the registration target
            corresponding to each gradient map.
            See :obj:`~nifreeze.model.base.ModelFactory` for allowed models (and corresponding
            keywords).

        Return
        ------
        affines : :obj:`list` of :obj:`numpy.ndarray`
            A list of :math:`4 \times 4` affine matrices encoding the estimated
            parameters of the deformations caused by head-motion and eddy-currents.

        """
        align_kwargs = align_kwargs or {}

        for i_iter in range(1, n_iter + 1):
            for i in random_iterator(len(dwdata)):
                # run a original-to-synthetic affine registration
                with TemporaryDirectory() as tmpdir:
                    # Factory creates the appropriate model and pipes arguments
                    dwmodel = ModelFactory.init(
                        dataset=dwdata, model=model, **kwargs
                    )

                    # generate a synthetic dw volume for the test gradient
                    dwmodel.fit_predict(i)

                    # Write arrays in memory to harddisk as NIfTI files
                    tmpdir = Path(tmpdir)
                    moving = tmpdir / "moving.nii.gz"
                    fixed = tmpdir / "fixed.nii.gz"
                    _to_nifti(data_test[0], moving)
                    _to_nifti(predicted, fixed)

                    # Prepare ANTs' antsRegistration via NiPype
                    registration = Registration(
                        fixed_image=str(fixed.absolute()),
                        moving_image=str(moving.absolute()),
                        **align_kwargs,
                    )

                    # execute ants command line
                    result = registration.run(cwd=str(tmpdir)).outputs

                    # read output transform
                    xform = nt.io.itk.ITKLinearTransform.from_filename(
                        result.forward_transforms[0]
                    )

                # update
                dwdata.set_transform(i, xform)

        return dwdata.em_affines
```

The above code allows us to use our estimator as follows:

```python
estimated_affines = Estimator.fit(dmri_dataset, model="b0")
```

## What's next? - Testing!

Once we have our first implementation functional, we should think of some unit-tests for our code.

```{admonition} Exercise
Write a unit test for the `TrivialB0Model`.
This test would just make sure that, regardless of the particular partition of the input dataset, a *b=0* map is always returned.
```

**Solution**: in this solution, we are using `pytest` to integrate the test into a higher-level test suite.

```{code-cell} python
:tags: [hide-cell]

import numpy as np
import pytest

from nifreeze.data.splitting import lovo_split

@pytest.mark.parametrize("split_index", list(range(30)))
def test_TrivialB0Model(split_index, dmri_dataset):
    model = TrivialB0Model(
        dmri_dataset.gradients,
        S0=dmri_dataset.bzero,
    )
    data_train, data_test = lovo_split(split_index)
    model.fit(data_train[0])
    predicted = model.predict(data_test[1])

    assert np.all(dmri_dataset.bzero == predicted)
```

## And after testing? - Validation!

Once we have a sufficient portion of our code *covered* by unit-tests, then we would add some *integration* tests that give us confidence that our bullet-proof individual components also work together.
Only after we have both steps secure, we can run benchmarks and evaluations from which we learn whether our solution works, and characterize its limitations.

The main strategy to validate this software would entail finding/acquiring a special dataset where motion is not present or extremely low, in which we *introduce* a known head-motion pattern with which we are going to challenge our estimator.
Some ideas to achieve this are:

- a dataset acquired with special sequences that can do prospective motion correction, or
- a dataset that has been acquired under very controlled settings, with an extremely collaborative participant who was also wearing a personalized mold, or
- a fully synthetic dataset such as the Fiber Box, or
- a fully synthetic dataset containing a repeated *b=0* image (this evaluation would be limited to work with the `TrivialB0Model`, for instance).

***Please head to [the GitHub repository](https://github.com/nipreps/EddyMotionCorrection) and share your ideas with us! We are welcoming new contributors!***
