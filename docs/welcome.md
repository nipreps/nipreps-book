Contributing to an Open Source Project: An Example with dMRIPrep
================================================================

Overview
--------

The development and fast adoption of fMRIPrep have revealed that neuroscientists need tools that simplify their research workflow, provide visual reports and checkpoints, and engender trust in the tool itself.
dMRIPrep extends fMRIPrep's approach and principles to diffusion MRI (dMRI).
The preprocessing of dMRI involves numerous steps to clean and standardize the data before fitting a particular model or carrying out tractography.
Generally, researchers create ad-hoc preprocessing workflows for each dataset, building upon a large inventory of available tools.
The complexity of these workflows has snowballed with rapid advances in acquisition and processing.
dMRIPrep is an analysis-agnostic tool that addresses the challenge of robust and reproducible preprocessing for whole-brain dMRI data.

In this tutorial we will demonstrate how to engage as a new contributor to dMRIPrep with the implementation of a longstanding request for a new feature in the software (https://github.com/nipreps/dmriprep/issues/64).
We will describe the overall process of contributing to an open-source project step-by-step, particularizing steps to the neuroimaging field whenever possible.

Workshop Contents
-----------------

| # |  Episode | Time | Question(s) |
|--:|:---------|:----:|:------------|
| 1 | Intro to dMRIPrep | 5 | |
| 2 | Nuts & Bolts of dMRI | 10 | |
| 3 | Contributing to an Open Source Project | 10 | |
| 4 | Review GitHub Issue | 5 |  |
| 5 | Clustering/Sci-kit Learn | 10 |  |
| 6 | Coding Solution | 20 |  |
| 7 | Pushing changes to GitHub | 10 |  |
| 8 | Open Issues | 5 |   |

Setup
-----

You are welcome to follow along with the tutorial however you like, whether you just want to listen or get more interactive.
Each IPython notebook chapter has a link in the top right corner to a Binder instance. Clicking this link will take you to an interactive Jupyter Lab space with all of the necessary software packages pre-installed.
If you would like to follow along using your own setup, 