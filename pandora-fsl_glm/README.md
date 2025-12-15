# PANDORA FSL-GLM on UKB-RAP

This folder provides an example of running voxel- and super-voxel level regression analyses on UK Biobank PANDORA data using `fsl_glm` developed by FMRIB (OxCIN) Oxford. The workflow runs on UKB-RAP using a Docker image with DNAnexus Swiss Army Knife.

## Overview of PANDORA

**PANDORA** (Population Archive of Neuroimaging Data Organised for Rapid Analysis) is a massive archive of preprocessed brain imaging data created by FMRIB for easy voxel-level regressions. Each PANDORA sub-modality (e.g., warpfield_jacobian, tfMRI_cope2) is stored as a 2D matrix (subjects x voxels) as tar archives (<submodality>.tar).

For more information on PANDORA, please see FMRIB's documentation:

https://pages.fmrib.ox.ac.uk/pandora/web/PANDORA.pdf

https://pages.fmrib.ox.ac.uk/pandora/web/

This tutorial assumes you already have access to the PANDORA tar files in your RAP project. 
You can find them in **/Bulk/Brain MRI/PANDORA/**

## Running regressions with FMRIB's `fsl_glm`

`fsl_glm` is FMRIB's simple regression tool that allows running regressions directly on PANDORA matrices, with regressors of interests and confounds. 

The workflow in this folder wraps `fsl_glm` inside a Docker image that:
- Installs FSL (using miniconda)
- Includes a wrapper script `pandora_regression.sh`
- Accepts a csv with multiple variables, and constructs subjects.txt, design.mat and design.con
- Runs `fsl_glm` in voxel, ICA1K or ICA10K mode
- Outputs an image file with statistical maps (options include T-stats, P-values for T-stats, F-stats, P values for F stats)

## Contents in this folder

**1. `pandora_regression.sh`**

A bash script that:
- Extracts the PANDORA tar files into the working directory
- Builds design.mat, design.con, and subjects.txt from your csv
- Checks for missing values or required parameters or mismatched lengths
- Runs `fsl_glm`
- Writes requested outputs:
  - T stats (default)
  - P values for T stats 
  - F statistics
  - PF (P values for F statistics)

Output naming convention:
```
<pi>_<pm>_<name>_confounds_<confounds>_T.nii.gz
<pi>_<pm>_<name>_confounds_<confounds>_P.nii.gz
<pi>_<pm>_<name>_confounds_<confounds>_F.nii.gz
<pi>_<pm>_<name>_confounds_<confounds>_PF.nii.gz
```
where:

- `pi`= PANDORA submodality (e.g. `tfMRI_cope2`, `warpfield_jacobian`)
- `pm`= mode -`voxel`, `ICA1K`, `ICA10K`
- `name`= label for output files
- `confounds`= confounds (can be `all` or `small`)

Outputs are either in .nii.gz or .dscalar.nii format.

**2. `pandora-regression.dockerfile`**

This build an image with:
- Ubuntu 22.04
- Miniconda
- FSL
- Required utilities
- The `pandora_regression.sh` script

This image is used by Swiss Army Knife to run the regression on the RAP.

**3. `build_docker_image.ipynb`**

This notebook demonstrates:
- Pulling the pre-built docker image from GHCR
- Building the Docker image from `pandora-regression.dockerfile`
- Uploading the Docker image to the RAP

**4. `run_pandora_regression.ipynb`**

This notebook provides:
- Examples using Swiss Army Knife to use the Docker image and input specifications to run the regressions.


### Running Pandora


1. **Build the Docker Image**  
   Run the notebook `build_docker_image.ipynb`.  
   To execute Pandora, you first need to build its Docker image. This can be done:
   - **Locally**, if you have Docker and the `dx-toolkit` installed.
   - **On the RAP**, by running the notebook in the RAP environment.

2. **Run Pandora Regression**  
   Once the Docker image is available in your working directory, use the notebook `run_pandora_regression.ipynb` as an example to run regressions via **Swiss Army Knife**.


## Inspecting the results:
**nifti (.nii.gz) outputs:**
- 3D Slicer 
- FSLeyes

For a guide on using 3D Slicer, please see this [UK Biobank 3D-Slicer article](https://community.ukbiobank.ac.uk/hc/en-gb/articles/30610339733661-Viewing-images-on-UKB-RAP-with-3D-Slicer)
https://biobank.ndph.ox.ac.uk/ukb/ukb/docs/imaging_nifti.pdf.

**cifti (.dscalar.nii) outputs:**
- HCP Workbench (wb_view)

This can be done on the RAP through running a Docker image (via ttyd), described in [FMRIB'S imaging-friendly Docker guide](https://docs.google.com/document/d/1QC3IaACVHS4MJQF1J71L_fNHLR4OkKJCB-Cs6FBEzGY/edit?tab=t.0).