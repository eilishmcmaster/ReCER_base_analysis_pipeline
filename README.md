# ReCER_base_analysis_pipeline
These are the scripts for the ReCER base analysis which is required to be done on N drive. 

This will make your metadata file for you and run an analysis. 

## Summary 
1. set up directories, download metadata from RNR, and download dart data
2. clone this git to get scripts
3. customise `0_setup_variables.xlsx` (Variables `species`, `dataset`, and `raw_meta_path` **must** be changed, others can be left default)
4. run `1_make_meta.R` which makes metadata file, including automatically creating sites based on distance
5. run `2_run_analyses.R` which produces summary pdf output as well as specific plots and tables


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

## 3. Customise analysis parameters
To set up your analysis, open `0_setup_variables.xlsx` in excel. This file contains input variables that the R scripts use to do your analyses. 

Here is an example of what `0_setup_variables.xlsx` could look like:
![image](https://github.com/eilishmcmaster/ReCER_base_analysis_pipeline/assets/67452867/cbf3dde2-6b50-417b-9f86-630e67f7b3e2)


Make sure that you have entered the correct values for species, dataset, and raw_meta_path -- these will be specific to your project. The rest of the variables are generic, so you can change them or not. 

### ! IMPORTANT !
The variables `species_col_name` and `site_col_name` are very important for your analysis. 

In your analyses, `species_col_name` specifies the variable containing species/genetic groups. This is used for visualisation (e.g. map of different `species_col_name` groups) and diversity analyses (i.e. in diversity analysis, your loci are filtered to be relevant by `species_col_name` groups). The default workflow will use the species names in RNR (column `sp` in meta file produced by `1_make_meta.R`).
* If you have multiple species in your dataset and you're confident about their IDs, use the default `species_col_name` = `sp`
* If you are **not** confident about species in your dataset, use `species_col_name` = `none`
* If you have custom genetic groups or species, use your custom column name in you metadata e.g. `species_col_name` = `genetic_groups_custom` (you will have to add your custom columns to the metadata AFTER running `1_make_meta.R`

In your analyses, `site_col_name` specifies the variable used for sites or populations. By default this is set to the `site` variable, which is created by `1_make_meta.R` by grouping geographically proxumate samples (i.e. samples<1km apart are in the same site). If you would prefer to use a different metadata variable as `site_col_name`, specify this in `0_setup_variables.xlsx`.


## 4. Generate metadata
Once your `0_setup_variables.xlsx` is complete, open and run `1_make_meta.R`. This script turns your RNR data into RRtools ready metadata. You shouldn't have to modify anything within the script, as variables are supplied through `0_setup_variables.xlsx`. 

`1_make_meta.R` main functions include:
* creates `site` column by determining which samples are <1km apart and grouping them
* creates `sp` column from RNR accepted species 
* If your RNR data contains parent and seedling information, it processes that into `tissue`, `mother`, and `family` columns

It also creates additional subdirectories that your further analysis needs. 

### ! IMPORTANT !
If you already have a metadata file that contains sample, site, lat, long etc, you **do not** have to use the metadata file produced here. You should still run this to make the required directories, but you can either delete the output meta or comment out line 154. Also make sure you specify your variables in `0_setup_variables.xlsx`.
If you want to **exclude** samples, simply leave the `site_col_name` column blank for that sample.

## 5. Run analysis
Once your metadata has been made you can run `2_run_analyses.R`. You shouldn't have to modify anything within the script, as variables are supplied through `0_setup_variables.xlsx`.

This will produce a directory within your **working directory** that contains figures, tables, and other outputs. The final pdf including most analyses (except splitstree and kinship) will be called something like `AcacSuav_combined_outputs.pdf` in your outputs folder. 

Kinship heatmaps are also available in `outputs/plots/` directory, but are usually too large to sensibly include in the combined outputs pdf. The splitstree file is made by this script but it has to be opened and saved using the Splitstree software before it can be re-imported and visualised in R. The code for this is commented out in `2_run_analyses.R`. 



