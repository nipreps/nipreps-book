# References

```{admonition} Overview
**Questions**
- Lorem ipsum

**Objectives**
- Lorem ipsum
```

In this lesson, we'll demonstrate how to make a new contribution to *dMRIPrep* by walking through the implementation of a head-motion correction algorithm. In the process, you'll also be introduced to several tools in the NiPreps arsenal, including NiBabel, NiTransforms, NiPype and NiWorkflows.

Subject motion within the scanner is a major source of dMRI artifacts!

INSERT FIGURE

How does head motion affect dwi results?
[^brun2019]:
[^baum2018] and [^oldham2020]: effects on structural connectivity
[^kreilkamp2015]: effects on DTI scalar metrics
[^yendiki2014]: ASD children, motion correlated with ADOS score


A common way of correcting for head-motion and eddy-current distortions is to co-register each diffusion-weighted image to a reference unweighted b0 image.
Subsequently, the gradient encoding directions at each image need to be re-oriented to account for this motion.

## Motivation

- open source solution
- unified API for performing head-motion correction on shelled and Cartesian or random q-space sampling schemes
- separate sdc from head motion correction (allow QCing steps separately) - using sdcflows
- provide motion parameters or other confounds in easy to parse tsv

`eddy_correct` trilinear interpolation
take first volume as reference b0
split all volumes into separate files

`flirt` to register each volume to the first
`fslmerge -t` to merge them all together

cannot handle multi-shell or high B0 values and cannot correct for high motion participants

[^bai2008]
[^ben-amitay2012]

comparison of `eddy` and `eddy_correct` in [&andersson2016] - figure 7

FSL eddy models diffusion signal using Gaussian processes instead of parametric models like DTI and DKI
how to explain the difference in approaches?

**Problem**: although most dMRI practitioners employ FSL for the estimation and correction of head-motion and eddy-current distortions, the FSL toolbox has restrictions of commercial use. By using FSL's eddy implementation, *dMRIPrep* inherits those restrictions.
Therefore, a fully-open implementation of *dMRIPrep* would require eliminating FSL as a dependency.
In this case, we will provide our own implementation of an algorithm for head-motion and eddy-current-derived distortions.

**The proposed solution**: we will design a model-based algorithm for the realignment of dMRI data.
This is based on an idea first proposed by [Ben-Amitay et al.](https://pubmed.ncbi.nlm.nih.gov/22183784/) and implemented as the SHORELine algorithm in [qsiprep](https://github.com/mattcieslak/ohbm_shoreline/blob/master/cieslakOHBM2019.pdf).

Also similar implementations in:
[^nilsson2015]
[^elhabian2014]
[^scherrer2012]
