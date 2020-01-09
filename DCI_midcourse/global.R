library(shinydashboard)
library(tidyverse)
library(DT)
library(dplyr)
library(ggplot2)


dci_data <- readRDS('data/dci_data_shiny.rds')


year<-dci_data %>%
  pull(dos_year) %>%
  unique()

month<-dci_data %>%
  pull(dos_month) %>%
  unique()


modality <- c('HIC','PD','HH')

