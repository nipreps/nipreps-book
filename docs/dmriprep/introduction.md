# About dMRIPrep

The pre-processing of dMRI data involves numerous steps to reduce noise, remove artifacts, and standardize the data before fitting a particular model or carrying out tractography.

Generally, researchers create ad-hoc pre-processing workflows for each dataset, building upon a large inventory of available tools.
The complexity of these workflows has snowballed with rapid advances in acquisition parameters and processing steps.

dMRIPrep is an analysis-agnostic tool that addresses the challenge of robust and reproducible pre-processing for whole-brain dMRI data.

## The problem of methodological variability and the need for standardized pre-processing

The development and fast adoption of fMRIPrep [^esteban2019] have revealed that neuroscientists need tools that simplify their research workflow, provide visual reports and checkpoints, and engender trust in the tool itself.

In Botvinik et al., 2020 [^botvinik2020], 70 independent teams were tasked with analyzing the same fMRI dataset and testing 9 hypothesis.
The study demonstrated the huge amount of variability in analytic approaches as *no two teams* chose identical workflows.
One encouraging finding was that 48% of teams chose to pre-process the data using fMRIPrep.

A similar predicament exists in the field of dMRI analysis.
There has been a lot of effort in recent years to compare the influence of various pre-processing steps on tractography and structural connectivity [^oldham2020] [^schilling2019] and harmonize different datasets [^tax2019].
All of this points to a need for creating a standardized pipeline for pre-processing dMRI data that will reduce methodological variability and enable comparisons between different datasets and downstream analysis decisions.

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

## Key Features

There are several other dMRI pre-processing pipelines being developed.
Below are some of dMRIPrep's key features.

### 1. Part of the NiPreps organization

```{image} ../images/sashimi.jpg
:name: sashimi
:width: 200px
:align: right
```

NiPreps are a collection of tools that work as an extension of the scanner in that they minimally pre-process the data and make them "safe to consume" for analysis - kinda like *sashimi*!

NiPreps pipelines are also:
- robust to different datasets
- easy to use (containerized software environment that can be run with single command)
- reproducible
- "glass box" architecture (all code/decisions visible on GitHub)
- regularly maintained

```{figure} ../images/nipreps-chart.svg
:name: nipreps_chart

Pipelines maintained by the NiPreps community
```

### 2. Automated workflows based on BIDS configuration

dMRIPrep only imposes a single constraint on the input dataset - being compliant with BIDS (Brain Imaging Data Structure).
BIDS enables consistency in how neuroimaging data is structured and ensures that the necessary metadata is complete.
This also minimizes human intervention in running the pipeline as it is able to adapt to the unique features of the input data and make decisions about whether a particular processing step is appropriate or not.

- head motion correction algorithm based on shell sampling
  - FSL eddy or Sparse Fascicle Model (SFM) for single-shell
  - 3D-SHORE for multi-shell/Cartesian grid
- distortion correction strategy based on input fieldmap
- parsing phase encoding direction and total readout time for applying distortion correction
- shell distribution - algorithms that require information redundancy cannot be applied to sparse sampling schemes

### 3. Quality control reportlets

```{figure} ../images/dwi_reportlet.gif
:name: reportlet
```

### 4. Continuous integration and deployment

```{tabbed} unittest
Checks whether a function or class method behaves as expected.

![unittest](../images/unittest.png)

```

```{tabbed} doctest
Also checks whether code behaves as expected and serves as an example for how to use the code.

![doctest1](../images/doctest1.png)

![doctest2](../images/doctest2.png)

```

```{tabbed} integration test
Checks the behaviour of a system (multiple pieces of code).
Can also be used to determine whether the system is behaving suboptimally.

![integration_test](../images/integration_test.png)

```

```{tabbed} build test
Checks that code or software environment can be compiled and deployed.

![build_test](../images/build_test.png)

```

---
## References

[^esteban2019]: Esteban, O., Markiewicz, C.J., Blair, R.W. et al. fMRIPrep: a robust preprocessing pipeline for functional MRI. Nat Methods 16, 111–116 (2019). https://doi.org/10.1038/s41592-018-0235-4

[^botvinik2020]: Botvinik-Nezer, R., Holzmeister, F., Camerer, C.F. et al. Variability in the analysis of a single neuroimaging dataset by many teams. Nature 582, 84–88 (2020). https://doi.org/10.1038/s41586-020-2314-9

[^oldham2020]: Oldham, S., Arnatkevic̆iūtė, A., Smith, R.W., et al. The efficacy of different preprocessing steps in reducing motion-related confounds in diffusion MRI connectomics. NeuroImage 222 117252 (2020). https://doi.org/10.1016/j.neuroimage.2020.117252

[^schilling2019]: Schilling, K. G., Daducci, A., Maier-Hein, K., Poupon, C., Houde, J. C., Nath, V., Anderson, A. W., Landman, B. A., & Descoteaux, M. (2019). Challenges in diffusion MRI tractography - Lessons learned from international benchmark competitions. Magnetic resonance imaging, 57, 194–209. https://doi.org/10.1016/j.mri.2018.11.014

[^tax2019]: Tax, C. M., Grussu, F., Kaden, E., Ning, L., Rudrapatna, U., John Evans, C., St-Jean, S., Leemans, A., Koppers, S., Merhof, D., Ghosh, A., Tanno, R., Alexander, D. C., Zappalà, S., Charron, C., Kusmia, S., Linden, D. E., Jones, D. K., & Veraart, J. (2019). Cross-scanner and cross-protocol diffusion MRI data harmonisation: A benchmark database and evaluation of algorithms. NeuroImage, 195, 285–299. https://doi.org/10.1016/j.neuroimage.2019.01.077

[^veraart2019]: Image Processing: Possible Guidelines for Standardization & Clinical Applications. https://www.ismrm.org/19/program_files/MIS15.htm