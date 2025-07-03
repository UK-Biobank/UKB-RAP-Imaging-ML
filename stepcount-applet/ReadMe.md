# Building a Tool for UK Biobank Bulk Files

## Applying the stepcount Tool

The UK Biobank Research Analysis Platform (RAP) stores imaging and genetic data as Bulk files. Analysing these files efficiently—both in terms of time and cost—is essential. One tool we use for this purpose is the [stepcount tool](https://github.com/OxWearables/stepcount), developed by OxWearables.

### Overview on OxWearables' stepcount tool

OxWearables has developed an advanced step counting tool that offers improved accuracy based on a foundation model for wrist-worn accelerometers. The model was trained using self-supervised learning on the large-scale UK Biobank Accelerometer Dataset and fine-tuned on the OxWalk Dataset. The stepcount tool and additional information can be found on [OxWearables' GitHub](https://github.com/OxWearables/stepcount) and in the [paper](https://www.nature.com/articles/s41746-024-01062-3).

OxWearables has also developed an **applet** that runs on the UK Biobank RAP. This applet processes accelerometry files and provides detailed information on steps, walking patterns, cadence, and more. Additional information is available on their [GitHub](https://github.com/OxWearables/dnanexus-stepcounthttps://github.com/OxWearables/dnanexus-stepcount).

### OxWearables DNAnexus stepcount applet - Usage

**Input**: The applet takes an accelerometry file as input correpsonding to a single individual. e.g. [field id 90001](https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=90001https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=90001)

**Output:**  It generates detailed information on steps, walking, cadence, etc., and saves the results in an "outputs/" folder. Details on the outputs the applet returns can be found in the [Glossary](https://github.com/OxWearables/stepcount/blob/main/GLOSSARY.mdhttps://github.com/OxWearables/stepcount/blob/main/GLOSSARY.md)

**Running Time:** The running time of the applet for a single accelerometry file depends on the size of the file, and can from 2 minutes to 20 minutes.

## Efficient Strategies for Analysing Bulk Files

There are several ways to process Bulk files on the UK Biobank RAP:

1. **Using DNAnexus Applets**:
   Applets are custom tools that can be executed directly on the RAP. In this application we are going to go through the stepcount applet that processes individual accelerometry files. 

2. **Using Docker Images**:
   Alternatively, you can bring your own tool to the RAP by creating a Docker image. This allows for more flexibility and can be integrated into various workflows.

### Contents

This folder contains:

1. The notebook `build_docker_image.ipynb` and the dockerfile `step-count.dockerfile` that walks you through:

    * Building a Docker image for the stepcount tool using a .dockerfile
    * Pulling a pre-built docker image from Github
    * Uploading the Docker image on the UK Biobank RAP to run it using the available workflows

2. The notebook `bulk_file_processing.ipynb` that walks you through running Bulk file analyses using different strategies:

    * Running a single applet instance on individual files in parallel. This uses the stepcount applet developed by OxWearables.
    * Running a single applet instance on multiple files. This uses a modified version of the initial applet developed by OxWearables to take as input a list of files. The modified version of the applet is found in this folder (stepcount-multiplefiles)
    * Using the DNAnexus Swiss Army Knife tool in combination with Docker for enhanced functionality. This uses the docker image intially created in `build_docker_image.ipynb`. 

    The notebook serves as a step-by-step tutorial, providing documentation and detailed instructions for each of these strategies. It aims to help researchers efficiently process large-scale UK Biobank Bulk file datasets using the stepcount tool.

### Considerations for choosing a method

In `bulk_file_processing.ipynb` we provide an estimate of cost for running a single applet instance on a single file which is estimated to be around £0.005/file. Running a single instance on multiple files instead is more expensive for the stepcount tool for the same files. 
However, for workflows which have long instance boot times (e.g. those with large package dependencies), the strategy of running multiple files on a single instance may be more suitable to minimise unnecessary launching overheads and costs.



