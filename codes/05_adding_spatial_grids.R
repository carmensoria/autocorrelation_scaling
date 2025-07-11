#----------------------------------------------------------#
#
#
#             SAC Diversity and distributions
#
#                 05_joining_spatial_data.R
#
#                      
#                        2025
#
#----------------------------------------------------------#


#----------------------------------------------------------#
# Loading libraries -----
#----------------------------------------------------------#

pacman::p_load(
  sf, tidyverse, here, tictoc
)


#----------------------------------------------------------#
# Directories -----
#----------------------------------------------------------#

source(file.path(here(), "codes", "00_config_file.R"))



#----------------------------------------------------------#
# Loading data -----
#----------------------------------------------------------#

# Species data
species_data_tbl <- readRDS(file.path(paths$output_path, 
                                      "species_filtered.rds"))

# Richness data
richness_data_tbl <- readRDS(file.path(paths$output_path, 
                                       "richness_table.rds"))

# Grid atlas
grid_sf <- readRDS(file.path(paths$input_path, "grid_sf.rds"))



#----------------------------------------------------------#
# Modifying sf grid -----
#----------------------------------------------------------#

# Making sf grid compatible with the other tables
grid_sf <- grid_sf %>% 
  mutate(
    datasetID = case_when(
      datasetID == 5 ~ "Czechia",
      datasetID == 26 ~ "Europe",
      datasetID == 6 ~ "New York",
      datasetID == 13 ~ "Japan"
    )
  ) %>% 
  mutate(datasetID = factor(datasetID, levels = c("Czechia", "Europe", 
                                                  "New York", "Japan")),
         scalingID = as.factor(scalingID))


#----------------------------------------------------------#
# Joining tables to grid -----
#----------------------------------------------------------#

# Species data
species_sf <- inner_join(grid_sf, species_data_tbl)
# Ensuring there are no unsampled cells
sum(is.na(species_sf$scientificName))

# Richness data
richness_sf <- inner_join(grid_sf, richness_data_tbl)
sum(is.na(species_sf$richness))


#----------------------------------------------------------#
# Saving -----
#----------------------------------------------------------#

# Species
saveRDS(species_sf, file.path(paths$output_path, "species_sf.rds"))

# Richness
saveRDS(richness_sf, file.path(paths$output_path, "richness_sf.rds"))
