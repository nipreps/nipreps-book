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
from tempfile import mkstemp
from pathlib import Path
import requests

if dmri_dataset._filepath.exists():
    dmri_dataset._filepath.unlink()
url = "https://files.osf.io/v1/resources/8k95s/providers/osfstorage/6070b4c2f6585f03fb6123a2"
datapath = Path(mkstemp(suffix=".h5")[1])
if datapath.stat().st_size == 0:
    datapath.write_bytes(
        requests.get(url, allow_redirects=True).content
    )

dmri_dataset = DWI.from_filename(datapath)
dmri_dataset.dataobj = dmri_dataset.dataobj[..., :32]
dmri_dataset.gradients = dmri_dataset.gradients[..., :32]
datapath.unlink()
```

Once we have finalized the main components of the solution, it is time for integration.
We now want to iterate over all the *LOGO* partitions of the dataset, generate a synthetic reference through the model of choice, and finally estimate the misalignment between the left-out gradient and the synthetic reference.
This solution, must also abide by the API we have envisioned.

```Python
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
        
        <please write a descriptive documentation of the function here>
        
        """
        align_kwargs = align_kwargs or {}

        if dwdata.brainmask is not None:
            kwargs["mask"] = dwdata.brainmask

        kwargs["S0"] = dwdata.bzero

        for i_iter in range(1, n_iter + 1):
            for i in np.arange(len(dwdata)):
                # run a original-to-synthetic affine registration
                with TemporaryDirectory() as tmpdir:
                    # Invoke `dwdata.logo_split()` on an index.
                    data_train, data_test = ...

                    # Factory creates the appropriate model and pipes arguments
                    dwmodel = ...

                    # fit the model
                    

                    # generate a synthetic dw volume for the test gradient
                    predicted = ...

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
        dwdata : :obj:`~eddymotion.dmri.DWI`
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
            See :obj:`~eddymotion.model.ModelFactory` for allowed models (and corresponding
            keywords).
        
        Return
        ------
        affines : :obj:`list` of :obj:`numpy.ndarray`
            A list of :math:`4 \times 4` affine matrices encoding the estimated
            parameters of the deformations caused by head-motion and eddy-currents.
        
        """
        align_kwargs = align_kwargs or {}

        if dwdata.brainmask is not None:
            kwargs["mask"] = dwdata.brainmask

        kwargs["S0"] = dwdata.bzero

        for i_iter in range(1, n_iter + 1):
            for i in np.arange(len(dwdata)):
                # run a original-to-synthetic affine registration
                with TemporaryDirectory() as tmpdir:
                    # Invoke `dwdata.logo_split()` on an index.
                    data_train, data_test = dwdata.logo_split(i, with_b0=True)

                    # Factory creates the appropriate model and pipes arguments
                    dwmodel = ModelFactory.init(
                        gtab=data_train[1], model=model, **kwargs
                    )

                    # fit the model
                    dwmodel.fit(data_train[0])

                    # generate a synthetic dw volume for the test gradient
                    predicted = dwmodel.predict(data_test[1])

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

```{code-cell} python
from eddymotion.estimator import EddyMotionEstimator

estimated_affines = EddyMotionEstimator.fit(dmri_dataset, model="b0")
```

## What's next? - Testing!
Once we have our first implementation functional, we should think of some unit-tests for our code.

**Exercise**: write a unit test for the `TrivialB0Model`.
This test would just make sure that, regardless of the particular partition of the input dataset, a *b=0* map is always returned.

**Solution**: in this solution, we are using `pytest` to integrate the test into a higher-level test suite.
```{code-cell} python
:tags: [hide-cell]

import numpy as np
import pytest

@pytest.mark.parametrize("split_index", list(range(30)))
def test_TrivialB0Model(split_index, dmri_dataset):
	model = TrivialB0Model(
		dmri_dataset.gradients,
		S0=dmri_dataset.bzero,
	)
	data_train, data_test = dmri_dataset.logo_split(split_index)
	model.fit(data_train[0])
	predicted = model.predict(data_test[1])

	assert np.all(dmri_dataset.bzero == predicted)

```

## And after testing? - Validation!

Once we have a sufficient portion of our code *covered* by unit-tests, then we would add some *integration* tests that give us confidence that our bullet-proof individual components also work together.
Only after we have both steps secure, we can run benchmarks and evaluations from which we learn whether our solution works, and characterize its limitations.

The main strategy to validate this software would entail finding/acquiring a special dataset where motion is not present or extremely low, in which we *introduce* a known head-motion pattern with which we are going to challenge our estimator.
Some ideas to achieve this are:
* a dataset acquired with special sequences that can do prospective motion correction, or
* a dataset that has been acquired under very controlled settings, with an extremely collaborative participant who was also wearing a personalized mold, or
* a fully synthetic dataset such as the Fiber Box, or
* a fully synthetic dataset containing a repeated *b=0* image (this evaluation would be limited to work with the `TrivialB0Model`, for instance).

***Please head to https://github.com/nipreps/EddyMotionCorrection and share your ideas with us! We are welcoming new contributors!***

