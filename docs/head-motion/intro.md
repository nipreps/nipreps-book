# The problem of head-motion in dMRI

A recurring problem for any MRI acquisition is that image reconstruction and modeling are extremely sensitive to very small changes in the position of the imaged object.
Rigid-body, bulk-motion of the head will degrade every image, even if the experimenters closely followed all the standard operation procedures and carefully prepared the experiment (e.g., setting correctly the head paddings), and even if the participant was experienced with the MR settings and strictly followed indications to avoid any movement outside time windows allocated for rest.
This effect is exacerbated by the length of the acquisition (longer acquisitions will have more motion), and is not limited to humans.
For instance, although rats are typically accquired with head fixations and under sedation, their breathing (especially when assisted) generally causes motion.
Even the vibration of the scanner itself can introduce motion!

<video width="640" height="680" loop="yes" muted="yes" autoplay="yes" controls="yes"><source src="../videos/hm-sagittal.avi" type="video/png" /></video>

## Dimensions of the head-motion problem

These sudden and unavoidable motion of the head (for instance, when the participant swallowed) result in two degrading consequences that confuse the diffusion model through which we will attempt to understand the data:

- **Misalignment between the different angular samplings**, which means that the same *(i, j, k)* voxel in one orientation will not contain a diffusion measurement of exactly the same anatomical location of the rest of the orientations (see [these slides by Dr. A. Yendiki in 2013](http://ftp.nmr.mgh.harvard.edu/pub/docs/TraculaNov2013/tracula.workshop.iv.pdf)).
- **Attenuation** in the recorded intensity of a particular orientation, especially present when the sudden motion occurred during the diffusion-encoding gradient pulse.

While we can address the misalignment, it is really problematic to overcome the attenuation.

## Objective: Implement a head-motion estimation code

This tutorial focuses on the misalignment problem.
We will build from existing software (DIPY, for diffusion modeling) and ANTs (for image registration), as well as commonplace Python libraries (NumPy) a software framework for head-motion estimation in diffusion MRI data.