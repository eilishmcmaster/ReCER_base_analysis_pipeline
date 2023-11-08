# ReCER_base_analysis_pipeline
These are the scripts for the ReCER base analysis which is required to be done on N drive. 

This will make your metadata file for you and run an analysis. 


## 1. Set up directories and data

Make a directory that will contain all of your data and analyses. This can be a species name (e.g. `acacia_suaveolens`) or another relevant descriptor (e.g. `red_box_gums`). This is your **main directory**.

Within the **main directory**, create a subdirectory. Usually this would be a combination of the genus and species names (e.g. Acacia suaveolens -> `AcacSuav`). This is the **working directory**, which will contain all of your data and outputs. 

Within the **working directory**, make `dart_raw` and `meta` subdirectories. Save your DArT SNP mapping csv to `dart_raw`. 

Download the relevant RnR export into `meta`. This export should contain all of the samples you wish to analyse. It's okay if it has irrelevant samples, they will be removed. 

Now your directories should look like this:
```
--acacia_suaveolens
  `--AcacSuav
    |--dart_raw
    |   `-Report_DAca20-5040_SNP_mapping_2.csv
    `--meta
        `-Tissue-2023-11-02_135351.csv
```

## 2. Clone the files in this git
You need to get a copy of the files in this github into your **main directory**.

To do this you can either:

1. git clone if you have a mac (`git clone git@github.com:eilishmcmaster/ReCER_base_analysis_pipeline.git`)
2. Manually download zip (go to `Code >Download zip` in top right of https://github.com/eilishmcmaster/ReCER_base_analysis_pipeline)

When you're done it your directory should look like this:

```
--acacia_suaveolens
  |-- 0_setup_variables.xlsx
  |-- 1_make_meta.R
  |-- 2_run_analyses.R
  `--AcacSuav
    |--dart_raw
    |   `-Report_DAca20-5040_SNP_mapping_2.csv
    `--meta
        `-Tissue-2023-11-02_135351.csv
```

## 3. Set up analysis
To set up your analysis, open `0_setup_variables.xlsx` in excel. This file contains input variables that the R scripts use to do your analyses. 

Here is an example of what `0_setup_variables.xlsx` could look like:

![image](https://github.com/eilishmcmaster/ReCER_base_analysis_pipeline/assets/67452867/a8ef5b0f-ccbe-4349-97d9-ada6cc696623)


