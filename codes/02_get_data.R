#----------------------------------------------------------#
#
#
#             SAC Diversity and distributions
#
#                     02_Get_data.R
#
#                     
#                         2025
#
#----------------------------------------------------------#


#----------------------------------------------------------#
# Loading libraries -----
#----------------------------------------------------------#

# Loading libraries
pacman::p_load(
  sf, tidyverse, tictoc, RPostgres, dbplyr, askpass, here
)


#----------------------------------------------------------#
# Directories -----
#----------------------------------------------------------#

source(file.path(here(), "codes", "00_config_file.R"))



#----------------------------------------------------------#
# SQL queries -----
#----------------------------------------------------------#

# SQL query to get atlas species presences
# recordFilter returns only trusted and apparent occurrences in EBBA
# These records (trusted and apparent) correspond to the CHANGE EBBA dataset
query_presences <- 'SELECT "datasetID", "scalingID", "siteID", 
"startYear", "endYear", "samplingPeriodID", 
"verbatimIdentification", "scientificName", "taxonRank", "recordFilter",
"area", "croppedArea"
FROM
"MOBI_vw_FINAL_presence_records" 
WHERE
"datasetID" IN (5,6,13,26)
AND 
"croppedArea" IS NOT NULL
AND 
("datasetID" <> 26 OR "recordFilter" IN (1,2))' 



# SQL query to get the sf grids
query_spatial <- 'SELECT "datasetID", "scalingID", "siteID", "footprintSRS",
"area", "croppedArea", 
"centroidDecimalLongitude", "centroidDecimalLatitude", "geometry"
FROM 
"MOBI_vw_FINAL_site_metrics"
WHERE
"datasetID" IN (5,6,13,26)'


# SQL query to get the taxonomy
query_taxonomy <- 'SELECT "scientificName", "order", "family", "genus"
FROM 
"CB_taxonomy" '


#----------------------------------------------------------#
# Get atlas query data -----
#----------------------------------------------------------#

# Connecting to the database
con <- dbConnect(Postgres(),
                 dbname = "MOBI_atlases_v1",
                 host = "localhost",
                 port = 5432,
                 user = "soria",
                 password = askpass("Password: ")
                 )

#--------------------------------------------------#

# Get presence data
tic()
data_presences <- tbl(con, sql(query_presences)) %>% 
  collect()
toc()

#--------------------------------------------------#

# Get spatial grids data
grid_sf <- st_read(con, query = query_spatial)

#--------------------------------------------------#

# Get the taxonomy
taxonomy <- tbl(con, sql(query_taxonomy)) %>% 
  collect()

#--------------------------------------------------#

# Disconnect from db
dbDisconnect(con)

#----------------------------------------------------------#
# Save data -----
#----------------------------------------------------------#

# Data presences
saveRDS(data_presences, file.path(paths$input_path, 
                                  "species_data.rds"))

# Grid sf
saveRDS(grid_sf, file.path(paths$input_path, "grid_sf.rds"))

# Taxonomy table
saveRDS(taxonomy, file.path(paths$input_path,
                            "taxonomy.rds"))
