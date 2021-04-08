# About dMRIPrep

The pre-processing of dMRI data involves numerous steps to reduce noise, remove artifacts, and standardize the data before fitting a particular model or carrying out tractography.

dMRIPrep is an analysis-agnostic tool that addresses the challenge of robust and reproducible pre-processing for whole-brain dMRI data.

## Development

In his 2019 ISMRM talk [^veraart2019], Jelle Veraart polled the developers of some of the major dMRI analysis software packages.
The goal was to understand how much consensus there was in the field on whether to proceed with certain pre-processing steps.
The poll showed that consensus is within reach.
However, different pre-processing steps have varying levels of support.
Head motion and eddy current correction, detecting outliers and denoising *must* be done.
Susceptibility distortion correction and removing Gibbs-ringing are also good to do but depend on the acquisition parameters.
Finally, for some steps such as correcting for B1 inhomogeneities or signal drift, their importance has not yet been demonstrated.

```{figure} ../images/veraart-2019.png
:name: pre-processing_consensus

Varying levels of support for different dMRI pre-processing steps
```

This information served as a starting point for the development of dMRIPrep.
It also introduced some new questions.
What are the minimal pre-processing steps for dMRI data?
How does the ordering in which the steps are conducted affect the final results?
How do different algorithms for the same method compare?

Below is a figure of the proposed dMRI pre-processing steps dMRIPrep is working towards implementing.
The progress and more detailed discussion can be tracked at this [roadmap](https://nipreps.org/dmriprep/roadmap.html).

```{figure} ../images/figure1.svg
:name: dmriprep_workflow

Proposed dMRI pre-processing workflow
```

```{figure} ../images/contributors.png
:name: contributors
:width: 200px

Current list of contributors to dMRIPrep
```

[^veraart2019]: Image Processing: Possible Guidelines for Standardization & Clinical Applications. https://www.ismrm.org/19/program_files/MIS15.htm
