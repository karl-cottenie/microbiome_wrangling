##***************************
## collapse multiple taxa
##
## Karl Cottenie
##
## 2023-05-19
##
##***************************

## _ Packages used -------
library(tidyverse)
conflicted::conflicts_prefer(dplyr::filter())
library(viridis)
# + scale_color/fill_viridis_c/d()
theme_set(theme_light())

# Startup ends here

## _ Comment codes ------
# Coding explanations (#, often after the code, but not exclusively)
# Code organization (## XXXXX -----)
# Justification for a section of code ## XXX
# Dead end analyses because it did not work, or not pursuing this line of inquiry (but leave it in as a trace of it, to potentially solve this issue, or avoid making the same mistake in the future # (>_<) 
# Solutions/results/interpretations (#==> XXX)
# Reference to manuscript pieces, figures, results, tables, ... # (*_*)
# TODO items #TODO
# names for data frames (df_name), lists (ls_name), ... (Thanks Jacqueline May)

## _ import data from Eleonore ----------
load("../data/emp_gut.RData")

df_no_zero
df_taxa_gut

df_taxa_gut |>  skimr::skim()
#======> work w/ taxonomy2, 46 groups

vc_d1_groups = 
  df_taxa_gut |> 
  group_by(taxonomy2) |> 
  summarise(n = n()) |> 
  arrange(desc(n)) |> 
  # for testing purposes work w/ the first 3 groups
  pull(taxonomy2)
vc_d1_groups[1:3]

## _ work it out w/ one group --------

vc_d1_firmicutes = df_taxa_gut |> 
  filter(taxonomy2 == vc_d1_groups[1]) |> 
  #check tibble row size = n column in l40 => ok
  pull(taxa_id)

df_no_zero |> 
  select(all_of(vc_d1_firmicutes)) |> 
  #check tibble column = #rows in l49 => ok
  rowwise() |> 
  transmute(total = sum(c_across(everything())))
  
df_no_zero |> 
  select(all_of(vc_d1_firmicutes)) |>
  rowSums() #another option, faster compared to rowwise/transmute

df_otu_d1 = map(vc_d1_groups, function(x){
  vc_group = df_taxa_gut |> 
    filter(taxonomy2 == x) |> 
    pull(taxa_id)
  df_no_zero |> 
    select(all_of(vc_group)) |>
    rowSums() |> 
    as_tibble()
}) |> 
  list_cbind() 
df_otu_d1
names(df_otu_d1) = vc_d1_groups
df_otu_d1
