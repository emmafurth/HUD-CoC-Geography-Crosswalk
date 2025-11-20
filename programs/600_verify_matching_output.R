
library(tidyverse)
library(diffdf)


perc_diff <- function(new, old){
  return(100*(new - old)/old)
}
output_folder <- "./output_comparison/"
comparison_extension <- "_COMPARISON.csv"

# First we'll compare population calculations for each CoC

orig_coc_pop_df <- read.csv("./original_output/coc_population_ORIG.csv")
new_coc_pop_df <- read.csv("./output/coc_population.csv")

joined_df <- orig_coc_pop_df %>% 
  full_join(new_coc_pop_df, by = join_by(coc_number), suffix = c("_ORIG", "_NEW")) %>%
  mutate(total_population_DIFF = perc_diff(total_population_NEW, total_population_ORIG),
         total_pop_in_poverty_DIFF = perc_diff(total_population_NEW, total_population_ORIG))

write.csv(joined_df, paste0(output_folder, "coc_population", comparison_extension))

# Next we'll compare the matches

file_names <- c("county_coc_match", "tract_coc_match")

for (file_name in file_names) {

  orig_result_file_name = paste0("./original_output/", file_name, "_ORIG.csv")
  new_result_file_name = paste0("./output/", file_name, ".csv")
  orig_tract_coc_df <- read.csv(orig_result_file_name)
  new_tract_coc_df <- read.csv(new_result_file_name)

  in_orig_but_not_new_df <- setdiff(orig_tract_coc_df, new_tract_coc_df) %>%
    mutate(source = "Original")
  in_new_but_not_orig_df <- setdiff(new_tract_coc_df, orig_tract_coc_df) %>%
    mutate(source = "New")
  
  comparison_df <- union_all(in_orig_but_not_new_df, in_new_but_not_orig_df) 
  
  write.csv(comparison_df, paste0(output_folder, file_name, comparison_extension), row.names = FALSE)

}

# remove all files
# rm(list = ls())