library(geosphere)
library(dplyr)
library(igraph)
library(stringr)
library(openxlsx)
library(RRtools)
devtools::source_url("https://github.com/eilishmcmaster/SoS_functions/blob/main/sos_functions.R?raw=TRUE")

setup_variables <- read.xlsx("0_setup_variables.xlsx", colNames = TRUE)
maindir <- setup_variables[1, 2]
species <- setup_variables[2, 2]
dataset <- setup_variables[3, 2]
RandRbase <- ""
raw_meta_path <- setup_variables[4, 2]
species_col_name <- setup_variables[5, 2]
site_col_name <- setup_variables[6, 2] # this is the equivalent of analysis
site_distances <- setup_variables[7, 2] %>% as.numeric()
remove_pops_less_than_n5 <- setup_variables[8, 2]
downsample <- setup_variables[9, 2]
samples_per_pop <- setup_variables[10, 2] %>% as.numeric()
locus_miss <- setup_variables[11, 2] %>% as.numeric()
sample_miss <- setup_variables[12, 2] %>% as.numeric()
maf_val <- setup_variables[13, 2] %>% as.numeric()
clonal_threshold <- setup_variables[14, 2] %>% as.numeric()
custom_meta <- setup_variables[15, 2] 


#####################  check for subdirs and make ##################### 

# Define the subdirectories you want to check and create

if (!dir.exists(species)) {
  dir.create(species, recursive = TRUE)
  cat(paste("Created directory:", species, "\n"))
} else {
  cat(paste("Directory already exists:", species, "\n"))
}

subdirectories <- c("meta", "dart_raw", "popgen", "qual_stat")

# Check and create subdirectories if they don't exist
for (subdir in subdirectories) {
  
  subdirectory_path <- file.path(paste0(species,'/',subdir))
  
  if (!dir.exists(subdirectory_path)) {
    dir.create(subdirectory_path, recursive = TRUE)
    cat(paste("Created directory:", subdirectory_path, "\n"))
  } else {
    cat(paste("Directory already exists:", subdirectory_path, "\n"))
  }
}



#####################  read in raw meta and format ##################### 
d1        <- new.read.dart.xls.onerow(RandRbase,species,dataset,topskip, euchits=FALSE, altcount=TRUE)

# Check if the file exists
if (file.exists(raw_meta_path)) {
  # Read the CSV file if it exists
  rnr_meta_raw <- read.csv(raw_meta_path)
  cat("Importing raw metadata\n")
} else {
  cat("Error: raw metadata not found\n")
}


working_meta <- rnr_meta_raw[,c('nswNumber','acceptedName','decimalLatitude','decimalLongitude',
                                'altitude','coordinateUncertainty','herbariumId','herbariumSpecimenIrn',
                                'locality', 'plants10m','adultsPresent','juvenilesPresent','populationNotes','collectionNotes','sampleDate','eventKey')]

meta_colnames <- c('sample','sp','lat','long',
                   'altitude','coordinateUncertainty','herbariumId','herbariumSpecimenIrn',
                   'locality', 'plants10m','adultsPresent','juvenilesPresent','populationNotes','collectionNotes','sampleDate','eventKey')
colnames(working_meta) <- meta_colnames

#####################  make numeric sites ##################### 
working_meta <- working_meta %>%
  mutate_at(vars(everything()), ~ifelse(. == "", NA, .))
working_meta <- working_meta[working_meta$sample %in% d1$sample_names,]
working_meta2 <- working_meta[!is.na(working_meta$lat)&!is.na(working_meta$long),]

library(geosphere)

S <- distm(x = cbind(working_meta2$long, working_meta2$lat), fun = geosphere::distHaversine)

colnames(S) <- working_meta2$sample
rownames(S) <- working_meta2$sample

distance_mat <- S/1000
# group samples <1km apart

distance_mat2 <- ifelse(distance_mat <= site_distances, 1, 0)

# remove connections if sp is not the same

logical_matrix <- outer(working_meta2[working_meta2$sample==rownames(distance_mat),species_col_name],
                                           working_meta2[working_meta2$sample==colnames(distance_mat),species_col_name], `==`)
distance_mat2[!logical_matrix] <- 0

#

dist_network <- igraph::graph_from_adjacency_matrix(as.matrix(distance_mat2), mode="undirected", diag=F)
ceb <- cluster_fast_greedy(dist_network)
ceb_net_plot <- plot(ceb, dist_network, vertex.label.color="transparent",vertex.size=2, edge.width=0.4)
ceb_net_plot
new_sites <-as.data.frame(cbind(new_site=as.numeric(ceb$membership), sample=ceb$names))


working_meta3 <- merge(working_meta, new_sites,  by="sample", all.x=TRUE) %>% as.data.frame()

#####################  make sites ordered by lat ##################### 
m4_sites_unique <- working_meta3[!is.na(working_meta3$new_site),] %>% 
  distinct(new_site, .keep_all = TRUE)%>%
  arrange(desc(lat))
m4_sites_unique$site_ordered <- 1:nrow(m4_sites_unique)

working_meta3 <- merge(working_meta3, m4_sites_unique[,c("new_site","site_ordered")], by.x="new_site", by.y="new_site", all.x=TRUE)

working_meta3$site_ordered[which(is.na(working_meta3$site_ordered))] <- "no_geo_data"

working_meta3$new_site <- NULL

##################### clean mother/seedling data if present ##############################


if(any(grepl("This individual", working_meta3$collectionNotes, ignore.case = FALSE))){
  working_meta4 <- working_meta3 %>%
    mutate(mother = ifelse(startsWith(collectionNotes, "This individual was germinated from seed collected from mother"), 
                           str_extract(collectionNotes, "\\S+$"), 
                           NA_character_))
  
  # Assuming your DataFrame is named df
  working_meta4 <- working_meta4 %>%
    mutate(tissue = case_when(
      str_detect(collectionNotes, "This individual was germinated from seed collected from mother") ~ "seedling",
      str_detect(collectionNotes, "This individual is the mother of") ~ "mother",
      TRUE ~ NA_character_
    ))
  
  working_meta4$full_fam_mother <- working_meta4$mother
  working_meta4$full_fam_mother[which(working_meta4$tissue=="mother")] <- working_meta4$sample[which(working_meta4$tissue=="mother")]
  
  working_meta4 <- working_meta4 %>%
    group_by(site_ordered) %>%
    arrange(full_fam_mother) %>%
    mutate(families = ifelse(!is.na(full_fam_mother), paste0("site", site_ordered,"_fam", dense_rank(full_fam_mother)), NA)) %>%
    ungroup()
}else{
  working_meta4 <- working_meta3
  working_meta4$mother <- NA
  working_meta4$tissue <- NA
  working_meta4$full_fam_mother <- NA
  working_meta4$families <- NA
}

##################### write meta file ##################### 
out_columns <- c('sample','lat','long','site_ordered','sp',
  'altitude','coordinateUncertainty','herbariumId','herbariumSpecimenIrn',
  'locality', 'plants10m','adultsPresent','juvenilesPresent','populationNotes','collectionNotes','sampleDate','eventKey',
  'mother','tissue','families')
out_meta <- working_meta4[,out_columns]
colnames(out_meta)[4] <- "site"

out_meta$none <- "all_species"

write.xlsx(out_meta, paste0(species, "/meta/", species, "_", dataset, "_meta.xlsx"))
