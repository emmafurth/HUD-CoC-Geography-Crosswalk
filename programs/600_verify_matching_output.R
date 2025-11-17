
library(dplyr)


file_names <- c("coc_population.csv", "county_coc_match.csv", "tract_coc_match.csv")

for (file_name in file_names) {
  orig_df <- read.csv(paste("./original_output", file_name, sep = "/"))
  new_df <- read.csv(paste("./output", file_name, sep = "/"))
  
  orig_df <- orig_df |> filter(startsWith(coc_number, "MD")) # TODO: Remove this line
  
  diffs <- differe(orig_df, new_df, ignore.col.order = TRUE, ignore.row.order = TRUE)
  
  print(paste(file_name, "diffs:", diffs))
}

