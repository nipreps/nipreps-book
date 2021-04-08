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