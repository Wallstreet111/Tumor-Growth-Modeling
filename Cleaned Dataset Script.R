# ============================================================
# Tumor Growth Modeling Project
# Data Cleaning Script – Placebo Group Only
# Files:
#   - clinicaltrial_data.csv
#   - mouse_drug_data.csv
# Location:
#   C:/CalculusResearchProject
# ============================================================

# ------------------------------
# 1. Load Required Libraries
# ------------------------------
library(dplyr)
library(readr)

# ------------------------------
# 2. Set Working Directory
# ------------------------------
# IMPORTANT: Use forward slashes in R
setwd("C:/CalculusResearchProject")

# ------------------------------
# 3. Import Raw Datasets
# ------------------------------
clinical_data <- read_csv("clinicaltrial_data.csv")
mouse_data    <- read_csv("mouse_drug_data.csv")

# ------------------------------
# 4. Inspect Column Names
# ------------------------------
# This ensures we know the exact tumor volume column name
print(colnames(clinical_data))
print(colnames(mouse_data))

# ------------------------------
# 5. Merge Datasets on Mouse ID
# ------------------------------
# Ensures each tumor measurement is linked to its drug group
merged_data <- merge(clinical_data, mouse_data, by = "Mouse ID")

# ------------------------------
# 6. Standardize Tumor Volume Column Name
# ------------------------------
# Automatically detect tumor column (anything containing "Tumor")
tumor_col <- grep("Tumor", colnames(merged_data), value = TRUE)

# Rename detected column to simple name: TumorVolume
merged_data <- merged_data %>%
  rename(TumorVolume = all_of(tumor_col))

# ------------------------------
# 7. Standardize Drug Column Name
# ------------------------------
# Some datasets use "Drug", others "Drug Regimen"
drug_col <- grep("Drug", colnames(merged_data), value = TRUE)

merged_data <- merged_data %>%
  rename(DrugRegimen = all_of(drug_col))

# ------------------------------
# 8. Filter to Placebo Group Only
# ------------------------------
placebo_data <- merged_data %>%
  filter(DrugRegimen == "Placebo")

# ------------------------------
# 9. Remove Missing Values
# ------------------------------
# No imputation is performed (per methodology)
placebo_data <- placebo_data %>%
  filter(!is.na(TumorVolume),
         !is.na(Timepoint))

# ------------------------------
# 10. Remove Duplicate Observations
# ------------------------------
placebo_data <- placebo_data %>%
  distinct()

# ------------------------------
# 11. Remove Implausible Tumor Volumes
# ------------------------------
# Tumor volume must be strictly positive
placebo_data <- placebo_data %>%
  filter(TumorVolume > 0)

# ------------------------------
# 12. Sort Chronologically
# ------------------------------
# Each mouse is treated as an independent time series
placebo_data <- placebo_data %>%
  arrange(`Mouse ID`, Timepoint)

# ------------------------------
# 13. Select Only Modeling Columns
# ------------------------------
cleaned_placebo <- placebo_data %>%
  select(`Mouse ID`,
         Timepoint,
         TumorVolume,
         DrugRegimen)

# ------------------------------
# 14. Verify Structure
# ------------------------------
str(cleaned_placebo)
summary(cleaned_placebo)

# Count number of independent mice
cat("Number of Placebo Mice:",
    length(unique(cleaned_placebo$`Mouse ID`)), "\n")

cat("Total Observations:",
    nrow(cleaned_placebo), "\n")

# ------------------------------
# 15. Export Cleaned Dataset
# ------------------------------
write_csv(cleaned_placebo, "cleaned_placebo_data.csv")

cat("Cleaned dataset successfully exported.\n")

# ============================================================
# End of Data Cleaning Script
# ============================================================

