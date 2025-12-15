# Imaging and Machine Learning Analyses on UKB-RAP

This repository provides tools, workflows, and tutorials for analysing UK Biobank imaging and accelerometry data on the Research Analysis Platform (RAP). It brings together and builds upon tools and pipelines developed by researchers to process imaging datasets and derive relevant variables. The resource is designed to support scalable, reproducible analysis and will continue to grow as new methods and materials are added.

## Content 

**stepcount-applet:** Example material demonstrating how to run the stepcount applet developed by OxWearables on the RAP.
- It includes a step-by-step guide for running the applet efficiently across large numbers of files.
- The strategy presented is scalable and generalisable, and can be adapted for other applets and bulk file processing tasks on the RAP.

**MONAILabel-Slicer-JupyterLab**: Example notebooks demonstrating how to use MONAI Label and 3D Slicer on JupyterLAB for UKB-RAP. 
- Includes three notebooks. Two of the notebooks are tailored for use with DICOM (MONAILabel_Slicer_DICOM_Demo) and NIFTI files (MONAILabel_Slicer_NIFTI_Demo). The third notebook is a short preliminary guide for extracting a sample UKB NIFTI file. 
- MONAILabel_Slicer_NIFTI_Demo: provides guidance on how to start the MONAI server, run a whole brain segmentation, visualise, edit and save a segmentation label. Should be run after using the Pre_NIFTI_Registration_Demo.
- MONAILabel_Slicer_DICOM_Demo: provides guidance on how to convert data to NIFTI format, use the DICOM database and start MONAI server. 
- Pre_NIFTI_Registration_Demo: provides guidance on how to extract a random participant file, register a T1 defaced image to MNI space, and upload data back to your project. Should be run prior to using the MONAILabel_Slicer_NIFTI_Demo.

**pandora-fsl_glm:** A guide for running voxelwise regressions using `fsl_glm` (developed by FMRIB (OxCIN) Oxford) on UKB PANDORA imaging data via Docker and Swiss Army Knife.
- It includes a Docker image that installs fsl and a wrapper script for running `fsl_glm` on PANDORA files.
- It provides examples using DNAnexus Swiss Army Knife to launch jobs to run regressions reproducibly and at scale.

## Status

This repository is under active development. We are continuously adding new material and refining existing workflows. Stay tuned for updates as we expand the toolkit and documentation.

If you have suggestions or are interested in a particular tool or task, we welcome your input, please share your thoughts!