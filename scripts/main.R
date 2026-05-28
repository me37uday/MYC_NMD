packages <- c(
  "tidyverse",
  "ggplot2",
  "patchwork",
  "readr",
  "dplyr",
  "tidyr"
)

installed <- packages %in% installed.packages()

if(any(!installed)) {
  install.packages(packages[!installed])
}

lapply(packages, library, character.only = TRUE)

source("scripts/sig_DEGs.R")
