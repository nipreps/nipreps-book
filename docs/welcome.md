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

In this tutorial we will demonstrate how to engage as a new contributor to dMRIPrep with the implementation of a longstanding request for a [new feature in the software](https://github.com/nipreps/dmriprep/issues/64).
We will describe the overall process of contributing to an open-source project step-by-step, particularizing steps to the neuroimaging field whenever possible.

Workshop Contents
-----------------

| # |  Episode | Time |
|--:|:---------|:-----|
| 1 | About dMRIPrep | 5 |
| 2 | Intro to dMRI | 10 |
| 3 | Contributing to an Open Source Project | 10 |
| 4 | Review GitHub Issue | 5 |
| 5 | Coding Solution | 20 |
| 6 | Pushing changes to GitHub | 10 |
| 7 | Open Issues | 5 |

Setup
-----

This tutorial contains a mix of lecture-based and interactive components.
You are welcome to follow along however you like, whether you just want to listen or code along with us.

Each of the chapters involving code are actually IPython notebooks!
Clicking the Binder icon in the top right corner will launch an interactive Jupyter Lab environment with all of the necessary software packages pre-installed.
![binder_link](images/binder_link.png)

If you would like to follow along using your own setup, you can:
1. clone this repository  
        `git clone https://github.com/nipreps/nipreps-book`
2. install the necessary python packages in your Python environment  
        `cd nipreps-book && pip install -r requirements.txt`
3. launch a Jupyter lab instance  
        `jupyter lab`
