# Head-motion and eddy-currents estimation

```{admonition} Overview
**Questions**
- Lorem ipsum

**Objectives**
- Lorem ipsum
```

In this lesson, we'll demonstrate how to make a new contribution to *dMRIPrep* by walking through the implementation of a head-motion correction algorithm. In the process, you'll also be introduced to several tools in the NiPreps arsenal.

Subject motion within the scanner is a major source of dMRI artifacts!

INSERT FIGURE

A common way of correcting for head-motion and eddy-current distortions is to co-register each diffusion-weighted image to a reference unweighted b0 image.
Subsequently, the gradient encoding directions at each image need to be re-oriented to account for this motion.

## Motivation

Unified API for performing head-motion correction on shelled and Cartesian or random q-space sampling schemes.

`eddy_correct` trilinear interpolation
take first volume as reference b0
split all volumes into separate files

`flirt` to register each volume to the first
`fslmerge -t` to merge them all together

cannot handle multi-shell or high B0 values and cannot correct for high motion participants

`eddy_openmp` and `eddy_cuda`

separate the head motion/eddy current correction and susceptibility distortion correction workflows into 2 steps