# Welcome!

## *Implementing a head-motion correction algorithm for diffusion MRI in Python, using Dipy and NiTransforms*

**Summary**.
This tutorial walks attendees through the development of one fundamental step in the processing of diffusion MRI data using a community-driven approach and relying on existing tools.
The tutorial first justifies the *NiPreps* approach to preprocessing, describing how the framework attempts to enhance or extend the scanning device to produce "analysis-grade" data.
This is important because data produced by the scanner is typically not digestible by statistical analysis directly.
Researchers resort to either 1) modifying their experimental design so that it matches the requirements of large-scale studies that have made publicly available all their software tooling or 2) creating custom preprocessing pipelines tailored to each particular study.
This tutorial has been designed to engage signal processing engineers and imaging researchers in the NiPreps community, demonstrating how to fill the gaps of their preprocessing needs regardless of their field.

```{admonition} Objectives
- Learn how to contribute to "open source" software
- Get a tour of the *NiPreps* framework
- Understand the basics of dMRI data and pre-processing
- Discover how to integrate some of the tools in the *NiPreps* framework
```

## Before we start: How to follow this tutorial
This tutorial contains a mix of lecture-based and interactive components.
The interactive components can be executed in your personal computer locally or using the Binder service.
You are welcome to follow along however you like, whether you just want to listen or code along with us.
Each of the chapters involving code are actually Jupyter notebooks!

### Using Binder
Clicking the Binder icon in the top right corner will launch an interactive computing environment with all of the necessary software packages pre-installed.

```{figure} images/binder_link.png
:name: binder_link

Binder Link
```

### Local installation ("bare-metal")
If you would like to follow along using your own setup and you have a functional Python environment, you can:

```bash

# 1. clone this repository
git clone https://github.com/nipreps/nipreps-book

# 2. install the necessary python packages in your Python environment
cd nipreps-book && pip install -r requirements.txt

# 3. launch a Jupyter lab instance
jupyter lab

```

### Local installation ("docker containers") 
