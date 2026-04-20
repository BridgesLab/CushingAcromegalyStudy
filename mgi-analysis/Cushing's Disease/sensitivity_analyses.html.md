---
title: "Sensitivity Analyses for Cushings x Obesity Project"
author: "Dave Bridges and Trey Carr"
date: "November 21, 2025"
format:
  html:
    toc: true
    toc-location: right
    keep-md: true
    code-fold: true
    code-summary: "Show the code"
  pdf: default
knitr:
  opts_chunk:
    fig.path: "figures/"
    dev: ["png", "pdf"]  # Remove !expr, just use array syntax
    fig.keep: "all"
execute:
  echo: true
  warning: false
---


::: {.cell}

```{.r .cell-code}
# hide this code chunk
#| echo: false
#| message: false

# defines the se function
se <- function(x) {
  sd(x, na.rm = TRUE) / sqrt(length(x))
}

#load these packages, nearly always needed
library(tidyverse)

# sets maize and blue color scheme
color_scheme <- c("#00274c", "#ffcb05")
```
:::




## Purpose

To perform sensitivity analyses for different models and populations

## Data Entry




::: {.cell}

```{.r .cell-code}
case.demographics.filename <- 'CaseDemographics.csv'
control.demographics.filename <- 'ControlDemographics.csv'

case.lab.results.filename <- 'LabResults.csv'
control.lab.results.filename <- '../controls/LabResults.csv'

bp.filename.cases <- 'NursingStandardVitalSigns.csv'
bp.filename.controls <- '../controls/NursingStandardVitalSigns.csv'

case.encounter.datafile <- "EncounterAll.csv" 
case.encounter.bmi.datafile <- "EncounterAnthropometricsBMI.csv" 
control.encounter.datafile <- "../controls/EncounterAll.csv" 
control.encounter.bmi.datafile <- "../controls/EncounterAnthropometricsBMI.csv" 

library(readr)
library(dplyr)
library(broom)

#labs dont have dates/ages
case.encounters <- read_csv(case.encounter.datafile)
case.encounters.bmi <- read_csv(case.encounter.bmi.datafile)
case.encounters.all <- left_join(case.encounters,case.encounters.bmi,
                                 by = join_by(DeID_PatientID, DeID_EncounterID))

control.encounters <- read_csv(control.encounter.datafile)
control.encounters.bmi <- read_csv(control.encounter.bmi.datafile)
control.encounters.all <- left_join(control.encounters,control.encounters.bmi,
                                 by = join_by(DeID_PatientID, DeID_EncounterID))


case.demographics <- read_csv(case.demographics.filename)
control.demographics <- read_csv(control.demographics.filename)

case.labs <- read_csv(case.lab.results.filename) |>
  left_join(case.encounters.all, by = join_by(DeID_PatientID, DeID_EncounterID)) |> #added encounter info
    left_join(case.demographics, by="DeID_PatientID") # added demographic data
control.labs <- read_csv(control.lab.results.filename) |> 
  left_join(control.encounters.all, by = join_by(DeID_PatientID, DeID_EncounterID)) |> #added encounter info
  left_join(control.demographics, by="DeID_PatientID") # added demographic data
#remove large objects not needed further
#rm(control.encounters,control.encounters.all,control.encounters.bmi)

#combined into one dataset
library(lubridate)

#this is used to filter for the window between when a lab result is allowable relative to the procedure.
procedure.result.interval <- 365 #within a year

lab.results <- bind_rows(control.labs |> mutate(Cushings=0),
                         case.labs |> mutate(Cushings=1)) |>  #combined, new column indicating cushings
  mutate(cushings_procedure = ymd(cushings_procedure),
         DeID_AdmitDate = mdy_hm(DeID_AdmitDate)) |> 
  mutate(TimePoint = case_when(cushings_procedure<= DeID_AdmitDate ~ "Before",
                               cushings_procedure > DeID_AdmitDate ~ "After",
                               .default="Unknown")) %>% # defined each encounter as before or after
  mutate(ProcedureFollowUp = cushings_procedure - DeID_AdmitDate) #used to define point between the lab result and the procedure.

#filtered out lab results outside of our interval
lab.results.filtered <-
  lab.results |>
  filter(ProcedureFollowUp<procedure.result.interval | is.na(ProcedureFollowUp)) |>
  filter(TimePoint!="After")
  
#filtered out if the age, gender, race, ethnicity was NA for a patient.
complete.data.race.ethnicity.age <-
  lab.results.filtered |>
  filter(!if_any(c(AgeInYears, GenderCode, RaceCode, EthnicityCode), is.na)) #removed if they had missing data for age, gender, race or ethnicity

#this is the complete dataset  
complete.data  <-
  complete.data.race.ethnicity.age |>
  mutate(RaceEthnicity = case_when(EthnicityCode=="HL"~"Hispanic or Latino",
                                   RaceCode=="C"~"White",
                                   RaceCode=="AA"~"Black",
                                   RaceCode=="A"~"Asian",
                                   .default="Other")) #defined race/ethnicity categories

#number of controls per case
fold <- 10
```
:::




We began with 69797 controls who had lab data, and **453** cases with Cushing's Disease.

* **Had Laboratory Results**: We also removed 329 lab results from Cushing's patients because they were outside of our acceptable window of 365 days before their procedure.  This eliminated a total of **1** Cushings patients from our dataset.

* **Missing Demographic Data** After filtering out missing demographic data we had 365 cases and 69273 controls with lab results.  The specific pieces of missing information are found here:




::: {.cell}

```{.r .cell-code}
lab.results.filtered |>
  filter(Cushings==1) |> #only for cushings data
  group_by(DeID_PatientID) %>%
  summarise(
    Age_na = sum(is.na(AgeInYears)),
    Gender_na = sum(is.na(GenderCode)),
    Race_na = sum(is.na(RaceCode)),
    Ethnicity_na = sum(is.na(EthnicityCode)),
    Any_na = any(is.na(AgeInYears) | is.na(GenderCode) | is.na(RaceCode) |is.na(EthnicityCode))) |>
  ungroup() |>
    pivot_longer(cols = ends_with("_na"),
                 names_to = "field",
                 values_to = "has_na") |>
  filter(has_na!=0) %>%
  count(field, name = "n_patients_with_NA")-> missing.demographic.summary

library(knitr)
missing.demographic.summary |> arrange(desc(n_patients_with_NA)) |> kable(caption="Summary of exclusions from Cushing's patient pool due to missing demographic data")
```

::: {.cell-output-display}


Table: Summary of exclusions from Cushing's patient pool due to missing demographic data

|field        | n_patients_with_NA|
|:------------|------------------:|
|Any_na       |                 90|
|Ethnicity_na |                 85|
|Gender_na    |                 18|
|Race_na      |                 18|
|Age_na       |                 12|


:::
:::




Our final dataset therefore included **365** Cushing's patients, and we had the ability to draw from **69273** Cushing's patients control patients.

## Propensity Mapping

Used the R package `mapit` to match based on Age, Gender, Race, and Ethnicity.  We wanted exact matches for everything except age, where we wanted the closest case that had a measurement.  We picked 10 matched controls for each case

### Population Definitions

We generated participant pools for all potential matched participants, then specifically for each outcome




::: {.cell}

```{.r .cell-code}
library(MatchIt)
m.out.all <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity, 
                 data = complete.data,
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),# Force exact matches
                 ratio=fold) 

matched_data.all <- match.data(m.out.all)

master.data <- 
  matched_data.all |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  filter(!is.na(Obesity)) 
```
:::





### Hba1c




::: {.cell}

```{.r .cell-code}
m.out.a1c <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity, 
                 data = complete.data |> filter(RESULT_CODE %in% c("A1C", "XXA1C", "A1C EX", "X0022")), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),# Force exact matches
                 ratio=fold) 

matched_data.a1c <- match.data(m.out.a1c)

hba1c.data <- 
  matched_data.a1c |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  mutate(ObesityIII = if_else(BMI>40, "Class III Obese","All Others"))  |>
  filter(!is.na(Obesity)) 
```
:::




#### HbA1c Statistics

Used the fully adjusted model to test the interaction between Cushings's diagnoses and obesity.




::: {.cell}

```{.r .cell-code}
library(emmeans)
#used fully adjusted model
lm.hba1c <- lm(value ~ RaceEthnicity + AgeInYears + GenderName + Cushings * Obesity, data = hba1c.data)

## 1. Adjusted means
emm.hba1c <- emmeans(lm.hba1c, ~ Cushings | Obesity) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "HbA1c",
    Mean_CI = sprintf("%.2f (%.2f–%.2f)", emmean, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, Cushings, Mean_CI)

## 2. Within-stratum Cushing–Control difference
contrast.hba1c <- contrast(emmeans(lm.hba1c, ~ Cushings | Obesity),
                             method = "revpairwise") %>%
  summary(infer = TRUE) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "HbA1c",
    Diff_CI = sprintf("%.2f (%.2f–%.2f)", estimate, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, contrast, Diff_CI, p.value)

## 3. Interaction term
interaction_row.hba1c <- tidy(lm.hba1c) %>%
  filter(term == "Cushings:ObesityObese") %>%
  mutate(
    Outcome = "HbA1c",
    Interaction_CI = sprintf("%.2f (%.2f–%.2f)",
                             estimate,
                             estimate - 1.96 * std.error,
                             estimate + 1.96 * std.error)
  ) %>%
  select(Outcome, term, estimate, std.error, statistic, p.value, Interaction_CI)

## 4. Combine into one publication-style table:
# Pivot adjusted means to wide format (Control vs Cushing side by side)
means_wide <- emm.hba1c %>%
  mutate(Cushings = ifelse(Cushings == 1, "Cushing", "Control")) %>%
  pivot_wider(names_from = Cushings, values_from = Mean_CI)

# Merge means with differences
table.hba1c <- means_wide %>%
  left_join(contrast.hba1c, by = c("Outcome", "Obesity"))

lm(value ~ Cushings + BMI + Cushings:Obesity,data=hba1c.data) |> 
  tidy() |> 
  kable(caption="2x2 ANOVA with Interaction for effects of Obesity and BMI on HbA1c")
```

::: {.cell-output-display}


Table: 2x2 ANOVA with Interaction for effects of Obesity and BMI on HbA1c

|term                  |   estimate| std.error|  statistic|   p.value|
|:---------------------|----------:|---------:|----------:|---------:|
|(Intercept)           |  4.1945228| 0.2517809| 16.6594132| 0.0000000|
|Cushings              |  1.0794586| 0.4613284|  2.3398918| 0.0203221|
|BMI                   |  0.0481857| 0.0078180|  6.1634688| 0.0000000|
|Cushings:ObesityObese | -0.0432075| 0.5389931| -0.0801634| 0.9361912|


:::
:::




### Glucose




::: {.cell}

```{.r .cell-code}
m.out.glucose <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity, 
                 data = complete.data |> filter(RESULT_CODE %in% c("GLUC","GLUC_WB")), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),# Force exact matches
                 ratio=fold) 

matched_data.glucose <- match.data(m.out.glucose)

glucose.data <- 
  matched_data.glucose |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  mutate(ObesityIII = if_else(BMI>40, "Class III Obese","All Others"))  |>
  filter(!is.na(Obesity)) 
```
:::




#### Glucose Statistics

Used the fully adjusted model to test the interaction between Cushings's diagnoses and obesity.




::: {.cell}

```{.r .cell-code}
#used fully adjusted model
lm.glucose <- lm(value ~ RaceEthnicity + AgeInYears + GenderName +  Cushings * Obesity, data = glucose.data)

## 1. Adjusted means
emm.glucose <- emmeans(lm.glucose, ~ Cushings | Obesity) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "Glucose",
    Mean_CI = sprintf("%.2f (%.2f–%.2f)", emmean, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, Cushings, Mean_CI)

## 2. Within-stratum Cushing–Control difference
contrast.glucose <- contrast(emmeans(lm.glucose, ~ Cushings | Obesity),
                             method = "revpairwise") %>%
  summary(infer = TRUE) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "Glucose",
    Diff_CI = sprintf("%.2f (%.2f–%.2f)", estimate, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, contrast, Diff_CI, p.value)

## 3. Interaction term
interaction_row.glucose <- tidy(lm.glucose) %>%
  filter(term == "Cushings:ObesityObese") %>%
  mutate(
    Outcome = "Glucose",
    Interaction_CI = sprintf("%.2f (%.2f–%.2f)",
                             estimate,
                             estimate - 1.96 * std.error,
                             estimate + 1.96 * std.error)
  ) %>%
  select(Outcome, term, estimate, std.error, statistic, p.value, Interaction_CI)

## 4. Combine into one publication-style table:
# Pivot adjusted means to wide format (Control vs Cushing side by side)
means_wide <- emm.glucose %>%
  mutate(Cushings = ifelse(Cushings == 1, "Cushing", "Control")) %>%
  pivot_wider(names_from = Cushings, values_from = Mean_CI)

# Merge means with differences
table.glucose <- means_wide %>%
  left_join(contrast.glucose, by = c("Outcome", "Obesity"))

lm(value ~ Cushings + BMI + Cushings:Obesity,data=glucose.data) |> 
  tidy() |> 
  kable(caption="2x2 ANOVA with Interaction for effects of Obesity and BMI on Glucose")
```

::: {.cell-output-display}


Table: 2x2 ANOVA with Interaction for effects of Obesity and BMI on Glucose

|term                  |   estimate| std.error|  statistic|   p.value|
|:---------------------|----------:|---------:|----------:|---------:|
|(Intercept)           | 81.2331245| 0.9760673| 83.2249192| 0.0000000|
|Cushings              | 24.3684172| 2.7558656|  8.8423823| 0.0000000|
|BMI                   |  0.6312709| 0.0320940| 19.6694382| 0.0000000|
|Cushings:ObesityObese |  0.9259315| 3.4547262|  0.2680188| 0.7886883|


:::
:::




### Liver Enzymes

#### ALT




::: {.cell}

```{.r .cell-code}
m.out.alt <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity, 
                 data = complete.data |> filter(RESULT_CODE %in% c("ALT")), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),
                 ratio=fold) # Force exact matches
matched_data.alt <- match.data(m.out.alt)

alt.data <- 
  matched_data.alt |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  filter(!is.na(Obesity))
```
:::





##### ALT Statistics

Used the fully adjusted model to test the interaction between Cushings's diagnoses and obesity.




::: {.cell}

```{.r .cell-code}
#used fully adjusted model
lm.alt <- lm(value ~ RaceEthnicity + AgeInYears + GenderName +  Cushings * Obesity, data = alt.data)

## 1. Adjusted means
emm.alt <- emmeans(lm.alt, ~ Cushings | Obesity) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "ALT",
    Mean_CI = sprintf("%.2f (%.2f–%.2f)", emmean, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, Cushings, Mean_CI)

## 2. Within-stratum Cushing–Control difference
contrast.alt <- contrast(emmeans(lm.alt, ~ Cushings | Obesity),
                             method = "revpairwise") %>%
  summary(infer = TRUE) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "ALT",
    Diff_CI = sprintf("%.2f (%.2f–%.2f)", estimate, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, contrast, Diff_CI, p.value)

## 3. Interaction term
interaction_row.alt <- tidy(lm.alt) %>%
  filter(term == "Cushings:ObesityObese") %>%
  mutate(
    Outcome = "ALT",
    Interaction_CI = sprintf("%.2f (%.2f–%.2f)",
                             estimate,
                             estimate - 1.96 * std.error,
                             estimate + 1.96 * std.error)
  ) %>%
  select(Outcome, term, estimate, std.error, statistic, p.value, Interaction_CI)

## 4. Combine into one publication-style table:
# Pivot adjusted means to wide format (Control vs Cushing side by side)
means_wide <- emm.alt %>%
  mutate(Cushings = ifelse(Cushings == 1, "Cushing", "Control")) %>%
  pivot_wider(names_from = Cushings, values_from = Mean_CI)

# Merge means with differences
table.alt <- means_wide %>%
  left_join(contrast.alt, by = c("Outcome", "Obesity"))

lm(value ~ Cushings + BMI + Cushings:Obesity,data=alt.data) |> 
  tidy() |> 
  kable(caption="2x2 ANOVA with Interaction for effects of Obesity and BMI on ALT")
```

::: {.cell-output-display}


Table: 2x2 ANOVA with Interaction for effects of Obesity and BMI on ALT

|term                  |   estimate| std.error| statistic|   p.value|
|:---------------------|----------:|---------:|---------:|---------:|
|(Intercept)           |  9.5958441| 3.2222652|  2.977981| 0.0029366|
|Cushings              | 36.0507907| 6.3190946|  5.705056| 0.0000000|
|BMI                   |  0.5421501| 0.1042606|  5.199950| 0.0000002|
|Cushings:ObesityObese | 35.4740470| 8.1117369|  4.373175| 0.0000129|


:::
:::




#### AST




::: {.cell}

```{.r .cell-code}
m.out.ast <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity, 
                 data = complete.data |> filter(RESULT_CODE %in% c("AST")), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),
                 ratio=fold) # Force exact matches

matched_data.ast <- match.data(m.out.ast)

ast.data <- 
  matched_data.ast |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  filter(!is.na(Obesity))
```
:::




##### AST Statistics

Used the fully adjusted model to test the interaction between Cushings's diagnoses and obesity.




::: {.cell}

```{.r .cell-code}
#used fully adjusted model
lm.ast <- lm(value ~ RaceEthnicity + AgeInYears + GenderName +                     Cushings * Obesity, data = ast.data)

## 1. Adjusted means
emm.ast <- emmeans(lm.ast, ~ Cushings | Obesity) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "AST",
    Mean_CI = sprintf("%.2f (%.2f–%.2f)", emmean, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, Cushings, Mean_CI)

## 2. Within-stratum Cushing–Control difference
contrast.ast <- contrast(emmeans(lm.ast, ~ Cushings | Obesity),
                             method = "revpairwise") %>%
  summary(infer = TRUE) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "AST",
    Diff_CI = sprintf("%.2f (%.2f–%.2f)", estimate, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, contrast, Diff_CI, p.value)

## 3. Interaction term
interaction_row.ast <- tidy(lm.ast) %>%
  filter(term == "Cushings:ObesityObese") %>%
  mutate(
    Outcome = "AST",
    Interaction_CI = sprintf("%.2f (%.2f–%.2f)",
                             estimate,
                             estimate - 1.96 * std.error,
                             estimate + 1.96 * std.error)
  ) %>%
  select(Outcome, term, estimate, std.error, statistic, p.value, Interaction_CI)

## 4. Combine into one publication-style table:
# Pivot adjusted means to wide format (Control vs Cushing side by side)
means_wide <- emm.ast %>%
  mutate(Cushings = ifelse(Cushings == 1, "Cushing", "Control")) %>%
  pivot_wider(names_from = Cushings, values_from = Mean_CI)

# Merge means with differences
table.ast <- means_wide %>%
  left_join(contrast.ast, by = c("Outcome", "Obesity"))

lm(value ~ Cushings + BMI + Cushings:Obesity,data=ast.data) |> 
  tidy() |> 
  kable(caption="2x2 ANOVA with Interaction for effects of Obesity and BMI on AST")
```

::: {.cell-output-display}


Table: 2x2 ANOVA with Interaction for effects of Obesity and BMI on AST

|term                  |   estimate| std.error| statistic|   p.value|
|:---------------------|----------:|---------:|---------:|---------:|
|(Intercept)           | 24.0096571|  7.483368| 3.2084024| 0.0013559|
|Cushings              | 15.9148667| 14.719938| 1.0811776| 0.2797485|
|BMI                   |  0.0991493|  0.242383| 0.4090606| 0.6825390|
|Cushings:ObesityObese | 39.2513118| 18.821520| 2.0854485| 0.0371552|


:::
:::




### Blood Pressure

Blood pressure data is in a separate file (NursingStandardVitalSigns.csv and ../controls/NursingStandardVitalSigns.csv).  We have mean noninvasive blood pressure, as well as systolic and diastolic.  These data, similar to lab results need to be mapped to encounter data 




::: {.cell}

```{.r .cell-code}
bp.data.cases <- read_csv(bp.filename.cases) |>
  left_join(case.encounters.all) |>
  left_join(case.demographics, by="DeID_PatientID") 

bp.data.controls <- read_csv(bp.filename.controls) |>
  left_join(control.encounters.all) |>
  left_join(control.demographics, by="DeID_PatientID") 

bp.results <- bind_rows(bp.data.controls |> mutate(Cushings=0),
          bp.data.cases |> mutate(Cushings=1)) |>  #combined, new column indicating cushings
  mutate(cushings_procedure = ymd(cushings_procedure),
         DeID_AdmitDate = mdy_hm(DeID_AdmitDate)) |> 
  mutate(TimePoint = case_when(cushings_procedure<= DeID_AdmitDate ~ "Before",
                               cushings_procedure > DeID_AdmitDate ~ "After",
                               .default="Unknown")) %>% # defined each encounter as before or after
  mutate(ProcedureFollowUp = cushings_procedure - DeID_AdmitDate) #used to define point between the lab result and the procedure.

#filtered out lab results outside of our interval
bp.results.filtered <-
  bp.results |>
  filter(ProcedureFollowUp<procedure.result.interval | is.na(ProcedureFollowUp)) |>
  filter(TimePoint!="After")
  
#filtered out if the age, gender, race, ethnicity was NA for a patient.
bp.data.race.ethnicity.age <-
  bp.results.filtered |>
  filter(!if_any(c(AgeInYears, GenderCode, RaceCode, EthnicityCode), is.na)) #removed if they had missing data for age, gender, race or ethnicity

#this is the complete dataset  
bp.data  <-
  bp.data.race.ethnicity.age |>
  mutate(RaceEthnicity = case_when(EthnicityCode=="HL"~"Hispanic or Latino",
                                   RaceCode=="C"~"White",
                                   RaceCode=="AA"~"Black",
                                   RaceCode=="A"~"Asian",
                                   .default="Other")) #defined race/ethnicity categories
```
:::




#### Inclusion and Exclusion for Blood Pressure Data

We began with 97442 controls who had lab data, and **339** cases with Cushing's Disease.

* **Had Laboratory Results**: We also removed 168 lab results from Cushing's patients because they were outside of our acceptable window of 365 days before their procedure.  This eliminated a total of **1** Cushings patients from our dataset.

* **Missing Demographic Data** After filtering out missing demographic data we had 311 cases and 96780 controls with lab results.  The specific pieces of missing information are found here:




::: {.cell}

```{.r .cell-code}
bp.results.filtered |>
  filter(Cushings==1) |> #only for cushings data
  group_by(DeID_PatientID) %>%
  summarise(
    Age_na = sum(is.na(AgeInYears)),
    Gender_na = sum(is.na(GenderCode)),
    Race_na = sum(is.na(RaceCode)),
    Ethnicity_na = sum(is.na(EthnicityCode)),
    Any_na = any(is.na(AgeInYears) | is.na(GenderCode) | is.na(RaceCode) |is.na(EthnicityCode))) |>
  ungroup() |>
    pivot_longer(cols = ends_with("_na"),
                 names_to = "field",
                 values_to = "has_na") |>
  filter(has_na!=0) %>%
  count(field, name = "n_patients_with_NA")-> missing.demographic.summary.bp

library(knitr)
missing.demographic.summary.bp |> arrange(desc(n_patients_with_NA)) |> kable(caption="Summary of exclusions from Cushing's patient pool due to missing demographic data, for blood pressure measures")
```

::: {.cell-output-display}


Table: Summary of exclusions from Cushing's patient pool due to missing demographic data, for blood pressure measures

|field        | n_patients_with_NA|
|:------------|------------------:|
|Any_na       |                 34|
|Ethnicity_na |                 24|
|Gender_na    |                 15|
|Race_na      |                 15|
|Age_na       |                 12|


:::
:::




Our final dataset for blood pressure therefore included **365** Cushing's patients, and we had the ability to draw from **69273** control patients.


#### Blood Pressure Propensity Mapping




::: {.cell}

```{.r .cell-code}
m.out.bp <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity, 
                 data = bp.data, 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),# Force exact matches
                 ratio=fold) 

matched_data <- match.data(m.out.bp)

bp.data <- 
  matched_data |>
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  mutate(ObesityIII = if_else(BMI>40, "Class III Obese","All Others"))  |>
  filter(!is.na(Obesity)) |>
  mutate(MAP_imputed = if_else(
    is.na(BPMeanNonInvasive) & !is.na(BPSysNonInvasive) & !is.na(BPDiaNonInvasive),
    (BPSysNonInvasive + 2*BPDiaNonInvasive)/3,
    BPMeanNonInvasive
  ))

# Calculate agreement statistics
map_agreement <- bp.data %>%
  filter(!is.na(BPMeanNonInvasive) & !is.na(BPSysNonInvasive) & !is.na(BPDiaNonInvasive)) %>%
  mutate(MAP_calc = (BPSysNonInvasive + 2*BPDiaNonInvasive)/3,
         difference = BPMeanNonInvasive - MAP_calc) %>%
  summarise(
    mean_diff = round(mean(difference), 2),
    sd_diff = round(sd(difference), 2),
    correlation = round(cor(BPMeanNonInvasive, MAP_calc), 3)
  )

# Count how many will be imputed
n_imputed <- bp.data %>%
  filter(is.na(BPMeanNonInvasive) & !is.na(BPSysNonInvasive) & !is.na(BPDiaNonInvasive)) %>%
  nrow()
```
:::




Mean arterial pressure was directly measured in the majority of cases. When MAP was missing but systolic and diastolic BP were available (n=22873), MAP was calculated as (SBP + 2×DBP)/3. The calculated values showed high agreement with measured MAP (r=0.963, mean difference=1.32 ± 3.38 mmHg) in cases where both were available.

#### Mean Arterial Pressure Statistics

Used the fully adjusted model to test the interaction between Cushings's diagnoses and obesity.




::: {.cell}

```{.r .cell-code}
#used fully adjusted model
lm.map <- lm(MAP_imputed ~ RaceEthnicity + AgeInYears + GenderName +                     Cushings * Obesity, data = bp.data)

## 1. Adjusted means
emm.map <- emmeans(lm.map, ~ Cushings | Obesity) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "Mean Arterial Pressure",
    Mean_CI = sprintf("%.2f (%.2f–%.2f)", emmean, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, Cushings, Mean_CI)

## 2. Within-stratum Cushing–Control difference
contrast.map <- contrast(emmeans(lm.map, ~ Cushings | Obesity),
                             method = "revpairwise") %>%
  summary(infer = TRUE) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "Mean Arterial Pressure",
    Diff_CI = sprintf("%.2f (%.2f–%.2f)", estimate, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, contrast, Diff_CI, p.value)

## 3. Interaction term
interaction_row.map <- tidy(lm.map) %>%
  filter(term == "Cushings:ObesityObese") %>%
  mutate(
    Outcome = "Mean Arterial Pressure",
    Interaction_CI = sprintf("%.2f (%.2f–%.2f)",
                             estimate,
                             estimate - 1.96 * std.error,
                             estimate + 1.96 * std.error)
  ) %>%
  select(Outcome, term, estimate, std.error, statistic, p.value, Interaction_CI)

## 4. Combine into one publication-style table:
# Pivot adjusted means to wide format (Control vs Cushing side by side)
means_wide <- emm.map %>%
  mutate(Cushings = ifelse(Cushings == 1, "Cushing", "Control")) %>%
  pivot_wider(names_from = Cushings, values_from = Mean_CI)

# Merge means with differences
table.map <- means_wide %>%
  left_join(contrast.map, by = c("Outcome", "Obesity"))
```
:::





#### Systolic Blood Pressure Statistics

Used the fully adjusted model to test the interaction between Cushings's diagnoses and obesity.




::: {.cell}

```{.r .cell-code}
#used fully adjusted model
lm.sbp <- lm(BPSysNonInvasive ~ RaceEthnicity + AgeInYears + GenderName + Cushings * Obesity, data = bp.data)

## 1. Adjusted means
emm.sbp <- emmeans(lm.sbp, ~ Cushings | Obesity) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "Systolic Blood Pressure",
    Mean_CI = sprintf("%.2f (%.2f–%.2f)", emmean, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, Cushings, Mean_CI)

## 2. Within-stratum Cushing–Control difference
contrast.sbp <- contrast(emmeans(lm.sbp, ~ Cushings | Obesity),
                             method = "revpairwise") %>%
  summary(infer = TRUE) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "Systolic Blood Pressure",
    Diff_CI = sprintf("%.2f (%.2f–%.2f)", estimate, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, contrast, Diff_CI, p.value)

## 3. Interaction term
interaction_row.sbp <- tidy(lm.sbp) %>%
  filter(term == "Cushings:ObesityObese") %>%
  mutate(
    Outcome = "Systolic Blood Pressure",
    Interaction_CI = sprintf("%.2f (%.2f–%.2f)",
                             estimate,
                             estimate - 1.96 * std.error,
                             estimate + 1.96 * std.error)
  ) %>%
  select(Outcome, term, estimate, std.error, statistic, p.value, Interaction_CI)

## 4. Combine into one publication-style table:
# Pivot adjusted means to wide format (Control vs Cushing side by side)
means_wide <- emm.sbp %>%
  mutate(Cushings = ifelse(Cushings == 1, "Cushing", "Control")) %>%
  pivot_wider(names_from = Cushings, values_from = Mean_CI)

# Merge means with differences
table.sbp <- means_wide %>%
  left_join(contrast.sbp, by = c("Outcome", "Obesity"))
```
:::




#### Diastolic Arterial Pressure Statistics

Used the fully adjusted model to test the interaction between Cushings's diagnoses and obesity.




::: {.cell}

```{.r .cell-code}
#used fully adjusted model
lm.dbp <- lm(BPDiaNonInvasive ~ RaceEthnicity + AgeInYears + GenderName + Cushings * Obesity, data = bp.data)

## 1. Adjusted means
emm.dbp <- emmeans(lm.dbp, ~ Cushings | Obesity) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "Diastolic Blood Pressure",
    Mean_CI = sprintf("%.2f (%.2f–%.2f)", emmean, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, Cushings, Mean_CI)

## 2. Within-stratum Cushing–Control difference
contrast.dbp <- contrast(emmeans(lm.dbp, ~ Cushings | Obesity),
                             method = "revpairwise") %>%
  summary(infer = TRUE) %>%
  as.data.frame() %>%
  mutate(
    Outcome = "Diastolic Blood Pressure",
    Diff_CI = sprintf("%.2f (%.2f–%.2f)", estimate, lower.CL, upper.CL)
  ) %>%
  select(Outcome, Obesity, contrast, Diff_CI, p.value)

## 3. Interaction term
interaction_row.dbp <- tidy(lm.dbp) %>%
  filter(term == "Cushings:ObesityObese") %>%
  mutate(
    Outcome = "Diastolic Blood Pressure",
    Interaction_CI = sprintf("%.2f (%.2f–%.2f)",
                             estimate,
                             estimate - 1.96 * std.error,
                             estimate + 1.96 * std.error)
  ) %>%
  select(Outcome, term, estimate, std.error, statistic, p.value, Interaction_CI)

## 4. Combine into one publication-style table:
# Pivot adjusted means to wide format (Control vs Cushing side by side)
means_wide <- emm.dbp %>%
  mutate(Cushings = ifelse(Cushings == 1, "Cushing", "Control")) %>%
  pivot_wider(names_from = Cushings, values_from = Mean_CI)

# Merge means with differences
table.dbp <- means_wide %>%
  left_join(contrast.dbp, by = c("Outcome", "Obesity"))
```
:::




## Summary of Interaction Effects




::: {.cell}

```{.r .cell-code}
create_lm_summary_row <- function(model_name, lm.glucose = NULL, lm.hba1c = NULL, 
                                   lm.alt = NULL, lm.ast = NULL, 
                                   lm.map = NULL, lm.sbp = NULL, lm.dbp = NULL, 
                                   coef_name = NULL) {
  
  # Helper function to extract and format results from a single model
  format_estimate <- function(model, coef_name = NULL) {
    if (is.null(model)) return(NA_character_)
    
    # Get coefficient summary
    coef_summary <- summary(model)$coefficients
    
    # If coef_name specified, use that row, otherwise use second row (first predictor)
    if (!is.null(coef_name)) {
      if (!coef_name %in% rownames(coef_summary)) return(NA_character_)
      row_idx <- which(rownames(coef_summary) == coef_name)
    } else {
      row_idx <- 2  # Default to first predictor (row 2, since row 1 is intercept)
    }
    
    estimate <- coef_summary[row_idx, "Estimate"]
    se <- coef_summary[row_idx, "Std. Error"]
    p_value <- coef_summary[row_idx, "Pr(>|t|)"]
    
    # Calculate 95% CI
    ci_lower <- estimate - 1.96 * se
    ci_upper <- estimate + 1.96 * se
    
    # Format the string
    result <- sprintf("%.2f [%.2f, %.2f]", estimate, ci_lower, ci_upper)
    
    # Add asterisk if p < 0.05
    if (p_value < 0.05) {
      result <- paste0(result, "*")
    }
    
    return(result)
  }
  
  # Create the row
  tibble(
    `Primary outcome` = model_name,
    Glucose = format_estimate(lm.glucose, coef_name),
    HbA1c = format_estimate(lm.hba1c, coef_name),
    ALT = format_estimate(lm.alt, coef_name),
    AST = format_estimate(lm.ast, coef_name),
    MAP = format_estimate(lm.map, coef_name),
    SBP = format_estimate(lm.sbp, coef_name),
    DBP = format_estimate(lm.dbp, coef_name)
  )
}

row1 <- create_lm_summary_row(
  model_name = "Main Analysis",
  lm.glucose = lm.glucose,
  lm.hba1c = lm.hba1c,
  lm.alt = lm.alt,
  lm.ast = lm.ast,
  lm.map = lm.map,
  lm.sbp = lm.sbp,
  lm.dbp = lm.dbp,
  coef_name = "Cushings:ObesityObese"
)
```
:::




## Alternate Models

### Modifying Covariates

#### Crude models

This includes models with no covariates other than Cushings $\times$ Obesity




::: {.cell}

```{.r .cell-code}
lm.hba1c.crude <- lm(value ~ Cushings * Obesity, data = hba1c.data )
lm.glucose.crude <- lm(value ~ Cushings * Obesity, data = glucose.data )
lm.alt.crude <- lm(value ~ Cushings * Obesity, data = alt.data )
lm.ast.crude <- lm(value ~ Cushings * Obesity, data = ast.data )
lm.map.crude <- lm(MAP_imputed ~ Cushings * Obesity, data = bp.data )
lm.sbp.crude <- lm(BPSysNonInvasive ~ Cushings * Obesity, data = bp.data )
lm.dbp.crude <- lm(BPDiaNonInvasive ~ Cushings * Obesity, data = bp.data )

crude.models <- create_lm_summary_row(
  model_name = "Unadjusted Models",
  lm.glucose = lm.glucose.crude,
  lm.hba1c = lm.hba1c.crude,
  lm.alt = lm.alt.crude,
  lm.ast = lm.ast.crude,
  lm.map = lm.map.crude,
  lm.sbp = lm.sbp.crude,
  lm.dbp = lm.dbp.crude,
  coef_name = "Cushings:ObesityObese"
)
```
:::




#### Gender adjusted only




::: {.cell}

```{.r .cell-code}
lm.hba1c.gender.only <- lm(value ~ GenderCode + Cushings * Obesity, data = hba1c.data )
lm.glucose.gender.only <- lm(value ~ GenderCode + Cushings * Obesity, data = glucose.data )
lm.alt.gender.only <- lm(value ~ GenderCode + Cushings * Obesity, data = alt.data )
lm.ast.gender.only <- lm(value ~ GenderCode + Cushings * Obesity, data = ast.data )
lm.map.gender.only <- lm(MAP_imputed ~ GenderCode + Cushings * Obesity, data = bp.data )
lm.sbp.gender.only <- lm(BPSysNonInvasive ~ GenderCode + Cushings * Obesity, data = bp.data )
lm.dbp.gender.only <- lm(BPDiaNonInvasive ~ GenderCode + Cushings * Obesity, data = bp.data )

gender.only.models <- create_lm_summary_row(
  model_name = "Adjusting for Gender Only",
  lm.glucose = lm.glucose.gender.only,
  lm.hba1c = lm.hba1c.gender.only,
  lm.alt = lm.alt.gender.only,
  lm.ast = lm.ast.gender.only,
  lm.map = lm.map.gender.only,
  lm.sbp = lm.sbp.gender.only,
  lm.dbp = lm.dbp.gender.only,
  coef_name = "Cushings:ObesityObese"
)
```
:::




#### Age adjusted only




::: {.cell}

```{.r .cell-code}
lm.hba1c.age.only <- lm(value ~ AgeInYears + Cushings * Obesity, data = hba1c.data )
lm.glucose.age.only <- lm(value ~ AgeInYears + Cushings * Obesity, data = glucose.data )
lm.alt.age.only <- lm(value ~ AgeInYears + Cushings * Obesity, data = alt.data )
lm.ast.age.only <- lm(value ~ AgeInYears + Cushings * Obesity, data = ast.data )
lm.map.age.only <- lm(MAP_imputed ~ AgeInYears + Cushings * Obesity, data = bp.data )
lm.sbp.age.only <- lm(BPSysNonInvasive ~ AgeInYears + Cushings * Obesity, data = bp.data )
lm.dbp.age.only <- lm(BPDiaNonInvasive ~ AgeInYears + Cushings * Obesity, data = bp.data )

age.only.models <- create_lm_summary_row(
  model_name = "Adjusting for Age Only",
  lm.glucose = lm.glucose.age.only,
  lm.hba1c = lm.hba1c.age.only,
  lm.alt = lm.alt.age.only,
  lm.ast = lm.ast.age.only,
  lm.map = lm.map.age.only,
  lm.sbp = lm.sbp.age.only,
  lm.dbp = lm.dbp.age.only,
  coef_name = "Cushings:ObesityObese"
)
```
:::




#### Race/ethnicity adjusted only




::: {.cell}

```{.r .cell-code}
lm.hba1c.race.only <- lm(value ~ RaceEthnicity + Cushings * Obesity, data = hba1c.data )
lm.glucose.race.only <- lm(value ~ RaceEthnicity + Cushings * Obesity, data = glucose.data )
lm.alt.race.only <- lm(value ~ RaceEthnicity + Cushings * Obesity, data = alt.data )
lm.ast.race.only <- lm(value ~ RaceEthnicity + Cushings * Obesity, data = ast.data )
lm.map.race.only <- lm(MAP_imputed ~ RaceEthnicity + Cushings * Obesity, data = bp.data )
lm.sbp.race.only <- lm(BPSysNonInvasive ~ RaceEthnicity + Cushings * Obesity, data = bp.data )
lm.dbp.race.only <- lm(BPDiaNonInvasive ~ RaceEthnicity + Cushings * Obesity, data = bp.data )

race.only.models <- create_lm_summary_row(
  model_name = "Adjusting for Race and Ethnicity Only",
  lm.glucose = lm.glucose.race.only,
  lm.hba1c = lm.hba1c.race.only,
  lm.alt = lm.alt.race.only,
  lm.ast = lm.ast.race.only,
  lm.map = lm.map.race.only,
  lm.sbp = lm.sbp.race.only,
  lm.dbp = lm.dbp.race.only,
  coef_name = "Cushings:ObesityObese"
)
```
:::




### Sex Stratified models




::: {.cell}

```{.r .cell-code}
lm.hba1c.m <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = hba1c.data |> filter(GenderCode=="M"))
lm.glucose.m <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = glucose.data |> filter(GenderCode=="M"))
lm.alt.m <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = alt.data |> filter(GenderCode=="M"))
lm.ast.m <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = ast.data |> filter(GenderCode=="M"))
lm.map.m <- lm(MAP_imputed ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(GenderCode=="M"))
lm.sbp.m <- lm(BPSysNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(GenderCode=="M"))
lm.dbp.m <- lm(BPDiaNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(GenderCode=="M"))

males.only <- create_lm_summary_row(
  model_name = "Male Patients",
  lm.glucose = lm.glucose.m,
  lm.hba1c = lm.hba1c.m,
  lm.alt = lm.alt.m,
  lm.ast = lm.ast.m,
  lm.map = lm.map.m,
  lm.sbp = lm.sbp.m,
  lm.dbp = lm.dbp.m,
  coef_name = "Cushings:ObesityObese"
)



lm.hba1c.f <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = hba1c.data |> filter(GenderCode=="F"))
lm.glucose.f <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = glucose.data |> filter(GenderCode=="F"))
lm.alt.f <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = alt.data |> filter(GenderCode=="F"))
lm.ast.f <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = ast.data |> filter(GenderCode=="F"))
lm.map.f <- lm(MAP_imputed ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(GenderCode=="F"))
lm.sbp.f <- lm(BPSysNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(GenderCode=="F"))
lm.dbp.f <- lm(BPDiaNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(GenderCode=="F"))

females.only <- create_lm_summary_row(
  model_name = "Female Patients",
  lm.glucose = lm.glucose.f,
  lm.hba1c = lm.hba1c.f,
  lm.alt = lm.alt.f,
  lm.ast = lm.ast.f,
  lm.map = lm.map.f,
  lm.sbp = lm.sbp.f,
  lm.dbp = lm.dbp.f,
  coef_name = "Cushings:ObesityObese"
)
```
:::




### Different Treatment of BMI

#### BMI after group-based stratification




::: {.cell}

```{.r .cell-code}
lm.hba1c.bmi.within.group <- lm(value ~ GenderCode + RaceEthnicity + Cushings * Obesity + BMI, data = hba1c.data )
lm.glucose.bmi.within.group <- lm(value ~ GenderCode + RaceEthnicity + Cushings * Obesity + BMI, data = glucose.data )
lm.alt.bmi.within.group <- lm(value ~ GenderCode + RaceEthnicity + Cushings * Obesity + BMI, data = alt.data )
lm.ast.bmi.within.group <- lm(value ~ GenderCode + RaceEthnicity + Cushings * Obesity + BMI, data = ast.data )
lm.map.bmi.within.group <- lm(MAP_imputed ~ GenderCode + RaceEthnicity + Cushings * Obesity, data = bp.data )
lm.sbp.bmi.within.group <- lm(BPSysNonInvasive ~ GenderCode + RaceEthnicity + Cushings * Obesity + BMI, data = bp.data )
lm.dbp.bmi.within.group <- lm(BPDiaNonInvasive ~ GenderCode + RaceEthnicity + Cushings * Obesity + BMI, data = bp.data )

bmi.within.group.models <- create_lm_summary_row(
  model_name = "Adjusting for BMI within Group",
  lm.glucose = lm.glucose.bmi.within.group,
  lm.hba1c = lm.hba1c.bmi.within.group,
  lm.alt = lm.alt.bmi.within.group,
  lm.ast = lm.ast.bmi.within.group,
  lm.map = lm.map.bmi.within.group,
  lm.sbp = lm.sbp.bmi.within.group,
  lm.dbp = lm.dbp.bmi.within.group,
  coef_name = "Cushings:ObesityObese"
)
```
:::




#### BMI as linear

In sensitivity analyses modelling BMI as a continuous predictor (linear term or restricted cubic spline), the Cushing's × obesity interaction is summarised on the **obese-minus-lean shift scale** so that it is directly comparable to the dichotomous BMI ≥30 interaction reported elsewhere in Table 4. Specifically, we fit the model `outcome ~ covariates + Cushings * BMI` (or `... * ns(BMI, df = 4)` for the spline version), then contrast predicted outcomes at the mean BMI among participants with BMI ≥30 versus the mean BMI among those with BMI <30. The reported estimate is the difference-in-differences `[Cushings effect at obese-mean BMI] − [Cushings effect at lean-mean BMI]`, which uses the same sign convention as the `Cushings:ObesityObese` coefficient in the dichotomous model (positive = synergy, Cushings effect amplified at higher BMI). Estimates are reported in native outcome units with 95% confidence intervals; `*` indicates `p < 0.05`.




::: {.cell}

```{.r .cell-code}
lm.hba1c.bmi.linear <- lm(value ~ GenderCode + RaceEthnicity + Cushings * BMI, data = hba1c.data )
lm.glucose.bmi.linear <- lm(value ~ GenderCode + RaceEthnicity + Cushings * BMI, data = glucose.data )
lm.alt.bmi.linear <- lm(value ~ GenderCode + RaceEthnicity + Cushings * BMI, data = alt.data )
lm.ast.bmi.linear <- lm(value ~ GenderCode + RaceEthnicity + Cushings * BMI, data = ast.data )
lm.map.bmi.linear <- lm(MAP_imputed ~ GenderCode + RaceEthnicity + Cushings * BMI, data = bp.data )
lm.sbp.bmi.linear <- lm(BPSysNonInvasive ~ GenderCode + RaceEthnicity + Cushings * BMI, data = bp.data )
lm.dbp.bmi.linear <- lm(BPDiaNonInvasive ~ GenderCode + RaceEthnicity + Cushings * BMI, data = bp.data )


# Unified helper: Cushing's x BMI interaction on the obese-minus-lean scale,
# in native outcome units, signed so positive = synergy. Same sign/scale
# convention as the Cushings:ObesityObese coefficient in the dichotomous model,
# so rows using this helper are directly comparable to the rest of Table 4.
#
# Works for both linear (Cushings * BMI) and spline (Cushings * ns(BMI, df=4))
# models because ref_grid + emmeans handle prediction machinery identically.
library(emmeans)
library(splines)

bmi_interaction_contrast <- function(model, data = NULL) {

  if (is.null(data)) data <- model.frame(model)

  # Mean BMI within lean (<30) and obese (>=30) subgroups
  means_bmi <- data %>%
    filter(!is.na(BMI)) %>%
    mutate(obese = BMI >= 30) %>%
    group_by(obese) %>%
    summarise(mean_bmi = mean(BMI), .groups = "drop")

  bmi_lean  <- means_bmi$mean_bmi[!means_bmi$obese]
  bmi_obese <- means_bmi$mean_bmi[ means_bmi$obese]

  # Reference grid at the two BMI anchor points, crossed with Cushings levels
  rg <- ref_grid(
    model,
    data = data,
    at   = list(BMI = c(bmi_lean, bmi_obese)),
    cov.reduce = FALSE
  )

  emm <- emmeans(rg, ~ Cushings * BMI)

  # Row order of emm: (C=0,lean), (C=0,obese), (C=1,lean), (C=1,obese)
  # Interaction = [(C=1,obese) - (C=0,obese)] - [(C=1,lean) - (C=0,lean)]
  #             = c(1, -1, -1, 1) applied in that row order.
  # Positive estimate = Cushings effect amplified in obese stratum (synergy).
  contr <- contrast(
    emm,
    method = list(
      `Cushings_x_Obesity` = c(1, -1, -1, 1)
    ),
    infer = TRUE
  )

  s <- as.data.frame(summary(contr))

  ci_lower <- intersect(c("lower.CL", "asymp.LCL", "LCL", "lower"), names(s))[1]
  ci_upper <- intersect(c("upper.CL", "asymp.UCL", "UCL", "upper"), names(s))[1]

  sprintf("%.2f [%.2f, %.2f]%s",
          s$estimate,
          s[[ci_lower]],
          s[[ci_upper]],
          ifelse(s$p.value < 0.05, "*", ""))
}

# Sanity check: compare helper output to direct Cushings:BMI coefficient
# scaled by (mean_obese - mean_lean). These should match closely for the
# linear model.
.sanity_lean  <- mean(glucose.data$BMI[glucose.data$BMI <  30], na.rm = TRUE)
.sanity_obese <- mean(glucose.data$BMI[glucose.data$BMI >= 30], na.rm = TRUE)
.sanity_coef  <- coef(lm.glucose.bmi.linear)["Cushings:BMI"]
cat("Direct Cushings:BMI coef * (mean_obese - mean_lean) = ",
    round(.sanity_coef * (.sanity_obese - .sanity_lean), 3), "\n")
```

::: {.cell-output .cell-output-stdout}

```
Direct Cushings:BMI coef * (mean_obese - mean_lean) =  -4.187 
```


:::

```{.r .cell-code}
cat("Helper output for glucose linear model           = ",
    bmi_interaction_contrast(lm.glucose.bmi.linear, data = glucose.data), "\n")
```

::: {.cell-output .cell-output-stdout}

```
Helper output for glucose linear model           =  -4.19 [-7.11, -1.26]* 
```


:::

```{.r .cell-code}
bmi.linear.models <- data.frame(
  Glucose = bmi_interaction_contrast(lm.glucose.bmi.linear, data = glucose.data),
  HbA1c   = bmi_interaction_contrast(lm.hba1c.bmi.linear,   data = hba1c.data),
  ALT     = bmi_interaction_contrast(lm.alt.bmi.linear,     data = alt.data),
  AST     = bmi_interaction_contrast(lm.ast.bmi.linear,     data = ast.data),
  MAP     = bmi_interaction_contrast(lm.map.bmi.linear,     data = bp.data),
  SBP     = bmi_interaction_contrast(lm.sbp.bmi.linear,     data = bp.data),
  DBP     = bmi_interaction_contrast(lm.dbp.bmi.linear,     data = bp.data)
)
```
:::




#### BMI as splined nonlinear covariate

Used the splines package.  `ns(BMI, df = 4)` fits a natural (restricted) cubic spline with 4 total degrees of freedom, which places 3 interior knots (by default at the 5th, 50th, and 95th percentiles of BMI) and forces the function to be linear beyond the outermost knots. This creates a smooth, flexible curve that can bend up to three times but remains well-behaved and avoids wild extrapolations at the extremes.

Decades of epidemiological research (Framingham, Nurses’ Health, ARIC, UK Biobank, *etc.*) have repeatedly shown that 4 df are sufficient to capture the true non-linear shapes of BMI with outcomes like diabetes, cardiovascular events, and mortality, without overfitting noise. It reliably reproduces the typical pattern of slowly rising risk at low-to-normal BMI, steepening in the overweight/obese range, and occasional flattening at very high BMI, while keeping confidence intervals honest in the tails where data are sparse. Using fewer df ($\leq$3) often forces an oversimplified shape that misses real curvature, whereas more than 5 df rarely improves fit meaningfully and risks spurious wiggles unless you have thousands of observations.




::: {.cell}

```{.r .cell-code}
library(splines)
lm.hba1c.bmi.non.linear <- lm(value ~ GenderCode + RaceEthnicity + Cushings * ns(BMI, df = 4), data = hba1c.data )
lm.glucose.bmi.non.linear <- lm(value ~ GenderCode + RaceEthnicity + Cushings * ns(BMI, df = 4), data = glucose.data )
lm.alt.bmi.non.linear <- lm(value ~ GenderCode + RaceEthnicity + Cushings * ns(BMI, df = 4), data = alt.data )
lm.ast.bmi.non.linear <- lm(value ~ GenderCode + RaceEthnicity + Cushings * ns(BMI, df = 4), data = ast.data )
lm.map.bmi.non.linear <- lm(MAP_imputed ~ GenderCode + RaceEthnicity + Cushings * ns(BMI, df = 4), data = bp.data )
lm.sbp.bmi.non.linear <- lm(BPSysNonInvasive ~ GenderCode + RaceEthnicity + Cushings * ns(BMI, df = 4), data = bp.data )
lm.dbp.bmi.non.linear <- lm(BPDiaNonInvasive ~ GenderCode + RaceEthnicity + Cushings * ns(BMI, df = 4), data = bp.data )

# Apply the same unified helper defined in the BMI-linear chunk.
# Because the helper uses ref_grid + emmeans, it handles spline models
# transparently. Outputs are on the obese-minus-lean scale in native units,
# directly comparable to the BMI (Linear) row and to the dichotomous rows.
bmi.non.linear.models <- data.frame(
  Glucose = bmi_interaction_contrast(lm.glucose.bmi.non.linear, data = glucose.data),
  HbA1c   = bmi_interaction_contrast(lm.hba1c.bmi.non.linear,   data = hba1c.data),
  ALT     = bmi_interaction_contrast(lm.alt.bmi.non.linear,     data = alt.data),
  AST     = bmi_interaction_contrast(lm.ast.bmi.non.linear,     data = ast.data),
  MAP     = bmi_interaction_contrast(lm.map.bmi.non.linear,     data = bp.data),
  SBP     = bmi_interaction_contrast(lm.sbp.bmi.non.linear,     data = bp.data),
  DBP     = bmi_interaction_contrast(lm.dbp.bmi.non.linear,     data = bp.data)
)
```
:::




#### BMI as categories

##### BMI Class I




::: {.cell}

```{.r .cell-code}
lm.hba1c.ci <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = hba1c.data |> filter(BMI<=35))
lm.glucose.ci <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = glucose.data |> filter(BMI<=35))
lm.alt.ci <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = alt.data |> filter(BMI<=35))
lm.ast.ci <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = ast.data |> filter(BMI<=35))
lm.map.ci <- lm(MAP_imputed ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI<=35))
lm.sbp.ci<- lm(BPSysNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI<=35))
lm.dbp.ci<- lm(BPDiaNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI<=35))

classI.obesity.only <- create_lm_summary_row(
  model_name = "Class I Obesity",
  lm.glucose = lm.glucose.ci,
  lm.hba1c = lm.hba1c.ci,
  lm.alt = lm.alt.ci,
  lm.ast = lm.ast.ci,
  lm.map = lm.map.ci,
  lm.sbp = lm.sbp.ci,
  lm.dbp = lm.dbp.ci,
  coef_name = "Cushings:ObesityObese"
)
```
:::




##### BMI Class II




::: {.cell}

```{.r .cell-code}
lm.hba1c.cii <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = hba1c.data |> filter(BMI < 30 | (BMI >= 35 & BMI < 40)))
lm.glucose.cii <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = glucose.data |> filter(BMI < 30 | (BMI >= 35 & BMI < 40)))
lm.alt.cii <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = alt.data |> filter(BMI < 30 | (BMI >= 35 & BMI < 40)))
lm.ast.cii <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = ast.data |> filter(BMI < 30 | (BMI >= 35 & BMI < 40)))
lm.map.cii <- lm(MAP_imputed ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI < 30 | (BMI >= 35 & BMI < 40)))
lm.sbp.cii<- lm(BPSysNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI < 30 | (BMI >= 35 & BMI < 40)))
lm.dbp.cii<- lm(BPDiaNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI < 30 | (BMI >= 35 & BMI < 40)))

classII.obesity.only <- create_lm_summary_row(
  model_name = "Class II Obesity",
  lm.glucose = lm.glucose.cii,
  lm.hba1c = lm.hba1c.cii,
  lm.alt = lm.alt.cii,
  lm.ast = lm.ast.cii,
  lm.map = lm.map.cii,
  lm.sbp = lm.sbp.cii,
  lm.dbp = lm.dbp.cii,
  coef_name = "Cushings:ObesityObese"
)
```
:::




##### BMI Class III




::: {.cell}

```{.r .cell-code}
lm.hba1c.ciii <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = hba1c.data |> filter(BMI < 30 | BMI >= 40))
lm.glucose.ciii <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = glucose.data |> filter(BMI < 30 | BMI >= 40))
lm.alt.ciii <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = alt.data |> filter(BMI < 30 | BMI >= 40))
lm.ast.ciii <- lm(value ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = ast.data |> filter(BMI < 30 | BMI >= 40))
lm.map.ciii <- lm(MAP_imputed ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI < 30 | BMI >= 40))
lm.sbp.ciii<- lm(BPSysNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI < 30 | BMI >= 40))
lm.dbp.ciii<- lm(BPDiaNonInvasive ~ RaceEthnicity + AgeInYears + Cushings * Obesity, data = bp.data |> filter(BMI < 30 | BMI >= 40))

classIII.obesity.only <- create_lm_summary_row(
  model_name = "Class III Obesity",
  lm.glucose = lm.glucose.ciii,
  lm.hba1c = lm.hba1c.ciii,
  lm.alt = lm.alt.ciii,
  lm.ast = lm.ast.ciii,
  lm.map = lm.map.ciii,
  lm.sbp = lm.sbp.ciii,
  lm.dbp = lm.dbp.ciii,
  coef_name = "Cushings:ObesityObese"
)
```
:::





#### Matching Participants by BMI




::: {.cell}

```{.r .cell-code}
m.out.a1c.bmi <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity + BMI, 
                 data = complete.data |> filter(RESULT_CODE %in% c("A1C", "XXA1C", "A1C EX", "X0022")) |> filter(!is.na(BMI)) |> filter(is.finite(BMI)), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),# Force exact matches
                 ratio=fold) 

matched_data.a1c.bmi <- match.data(m.out.a1c.bmi)

hba1c.data.bmi <- 
  matched_data.a1c.bmi |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  mutate(ObesityIII = if_else(BMI>40, "Class III Obese","All Others"))  |>
  filter(!is.na(Obesity)) 

m.out.glucose.bmi <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity + BMI, 
                 data = complete.data |> filter(RESULT_CODE %in% c("GLUC","GLUC_WB"))|> filter(!is.na(BMI)) |> filter(is.finite(BMI)), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),# Force exact matches
                 ratio=fold) 

matched_data.glucose.bmi <- match.data(m.out.glucose.bmi)

glucose.data.bmi <- 
  matched_data.glucose.bmi |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  mutate(ObesityIII = if_else(BMI>40, "Class III Obese","All Others"))  |>
  filter(!is.na(Obesity))

m.out.alt.bmi <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity + BMI, 
                 data = complete.data |> filter(RESULT_CODE %in% c("ALT"))|> filter(!is.na(BMI)) |> filter(is.finite(BMI)), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),
                 ratio=fold) # Force exact matches
matched_data.alt.bmi <- match.data(m.out.alt.bmi)

alt.data.bmi <- 
  matched_data.alt.bmi |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  filter(!is.na(Obesity))

m.out.ast.bmi <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity + BMI, 
                 data = complete.data |> filter(RESULT_CODE %in% c("AST"))|> filter(!is.na(BMI)) |> filter(is.finite(BMI)), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),
                 ratio=fold) # Force exact matches
matched_data.ast.bmi <- match.data(m.out.ast.bmi)

ast.data.bmi <- 
  matched_data.ast.bmi |>
  mutate(value = as.numeric(VALUE)) %>% #forced into numeric form  
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  filter(!is.na(Obesity))

m.out.bp.bmi <- matchit(Cushings ~ AgeInYears + GenderCode + RaceEthnicity + BMI, 
                 data = bp.data |> filter(!is.na(BMI)) |> filter(is.finite(BMI)) |> select(-weights,-distance, -subclass), 
                 method = "nearest", 
                 exact = c("GenderCode", "RaceEthnicity"),# Force exact matches
                 ratio=fold) 

matched_data.bp.bmi <- match.data(m.out.bp.bmi)

bp.data.bmi <- 
  matched_data.bp.bmi |>
  arrange(desc(DeID_AdmitDate)) %>% #sort by date
  distinct(DeID_PatientID,.keep_all = T) %>% #unique cases
  mutate(Obesity = if_else(BMI>30, "Obese","Non-Obese"))  |>
  mutate(ObesityIII = if_else(BMI>40, "Class III Obese","All Others"))  |>
  filter(!is.na(Obesity)) |>
  mutate(MAP_imputed = if_else(
    is.na(BPMeanNonInvasive) & !is.na(BPSysNonInvasive) & !is.na(BPDiaNonInvasive),
    (BPSysNonInvasive + 2*BPDiaNonInvasive)/3,
    BPMeanNonInvasive
  ))

lm.hba1c.bmi.matched <- lm(value ~ GenderCode + RaceEthnicity + Cushings * Obesity, data = hba1c.data.bmi )
lm.glucose.bmi.matched <- lm(value ~ GenderCode + RaceEthnicity + Cushings * Obesity, data = glucose.data.bmi )
lm.alt.bmi.matched <- lm(value ~ GenderCode + RaceEthnicity + Cushings * Obesity, data = alt.data.bmi )
lm.ast.bmi.matched <- lm(value ~ GenderCode + RaceEthnicity + Cushings * Obesity, data = ast.data.bmi )
lm.map.bmi.matched <- lm(MAP_imputed ~ GenderCode + RaceEthnicity + Cushings * Obesity, data = bp.data.bmi )
lm.sbp.bmi.matched <- lm(BPSysNonInvasive ~ GenderCode + RaceEthnicity + Cushings * Obesity, data = bp.data.bmi )
lm.dbp.bmi.matched <- lm(BPDiaNonInvasive ~ GenderCode + RaceEthnicity + Cushings * Obesity, data = bp.data.bmi )

bmi.matched.models <- create_lm_summary_row(
  model_name = "Matching for BMI",
  lm.glucose = lm.glucose.bmi.matched,
  lm.hba1c = lm.hba1c.bmi.matched,
  lm.alt = lm.alt.bmi.matched,
  lm.ast = lm.ast.bmi.matched,
  lm.map = lm.map.bmi.matched,
  lm.sbp = lm.sbp.bmi.matched,
  lm.dbp = lm.dbp.bmi.matched,
  coef_name = "Cushings:ObesityObese"
)
```
:::





## Summary of Sensitivity Analyses




::: {.cell}

```{.r .cell-code}
summary.sensitivity.data <- bind_rows(row1,
                                      crude.models,
                                      age.only.models, 
                                      gender.only.models, 
                                      race.only.models, 
                                      males.only, 
                                      females.only,
                                      bmi.within.group.models,
                                      bmi.linear.models     |> mutate(`Primary outcome` = "BMI (Linear, obese-lean shift)"),
                                      bmi.non.linear.models |> mutate(`Primary outcome` = "BMI (Spline ns df=4, obese-lean shift)"),
                                      bmi.matched.models,
                                      classI.obesity.only,
                                      classII.obesity.only,
                                      classIII.obesity.only
                                      ) |>
  rename(Model = `Primary outcome`)

library(kableExtra)
summary.sensitivity.data |>
  kable(caption="Summary of sensitivity analyses") |>
  kable_styling(full_width = FALSE, position = "center")
```

::: {.cell-output-display}

`````{=html}
<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>Summary of sensitivity analyses</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Model </th>
   <th style="text-align:left;"> Glucose </th>
   <th style="text-align:left;"> HbA1c </th>
   <th style="text-align:left;"> ALT </th>
   <th style="text-align:left;"> AST </th>
   <th style="text-align:left;"> MAP </th>
   <th style="text-align:left;"> SBP </th>
   <th style="text-align:left;"> DBP </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Main Analysis </td>
   <td style="text-align:left;"> 2.26 [-4.45, 8.98] </td>
   <td style="text-align:left;"> 0.47 [-0.65, 1.59] </td>
   <td style="text-align:left;"> 38.26 [22.26, 54.26]* </td>
   <td style="text-align:left;"> 40.02 [2.93, 77.11]* </td>
   <td style="text-align:left;"> -6.58 [-9.50, -3.66]* </td>
   <td style="text-align:left;"> -8.89 [-13.15, -4.63]* </td>
   <td style="text-align:left;"> -5.48 [-8.32, -2.65]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Unadjusted Models </td>
   <td style="text-align:left;"> 0.88 [-5.93, 7.69] </td>
   <td style="text-align:left;"> 0.50 [-0.64, 1.63] </td>
   <td style="text-align:left;"> 37.83 [21.84, 53.81]* </td>
   <td style="text-align:left;"> 41.75 [4.78, 78.72]* </td>
   <td style="text-align:left;"> -7.27 [-10.28, -4.26]* </td>
   <td style="text-align:left;"> -10.16 [-14.65, -5.68]* </td>
   <td style="text-align:left;"> -5.88 [-8.74, -3.01]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Adjusting for Age Only </td>
   <td style="text-align:left;"> 1.56 [-5.17, 8.29] </td>
   <td style="text-align:left;"> 0.40 [-0.70, 1.51] </td>
   <td style="text-align:left;"> 37.71 [21.71, 53.70]* </td>
   <td style="text-align:left;"> 40.97 [4.00, 77.94]* </td>
   <td style="text-align:left;"> -6.72 [-9.66, -3.78]* </td>
   <td style="text-align:left;"> -9.10 [-13.40, -4.80]* </td>
   <td style="text-align:left;"> -5.59 [-8.44, -2.75]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Adjusting for Gender Only </td>
   <td style="text-align:left;"> 1.70 [-5.08, 8.48] </td>
   <td style="text-align:left;"> 0.52 [-0.63, 1.67] </td>
   <td style="text-align:left;"> 38.23 [22.26, 54.20]* </td>
   <td style="text-align:left;"> 41.62 [4.62, 78.61]* </td>
   <td style="text-align:left;"> -7.07 [-10.06, -4.08]* </td>
   <td style="text-align:left;"> -9.84 [-14.29, -5.39]* </td>
   <td style="text-align:left;"> -5.74 [-8.59, -2.88]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Adjusting for Race and Ethnicity Only </td>
   <td style="text-align:left;"> 0.91 [-5.90, 7.72] </td>
   <td style="text-align:left;"> 0.45 [-0.70, 1.60] </td>
   <td style="text-align:left;"> 37.86 [21.85, 53.86]* </td>
   <td style="text-align:left;"> 40.83 [3.75, 77.91]* </td>
   <td style="text-align:left;"> -7.32 [-10.33, -4.31]* </td>
   <td style="text-align:left;"> -10.25 [-14.73, -5.77]* </td>
   <td style="text-align:left;"> -5.91 [-8.77, -3.04]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male Patients </td>
   <td style="text-align:left;"> 7.50 [-9.19, 24.18] </td>
   <td style="text-align:left;"> -0.74 [-2.72, 1.23] </td>
   <td style="text-align:left;"> 23.62 [-6.00, 53.24] </td>
   <td style="text-align:left;"> 25.76 [11.39, 40.14]* </td>
   <td style="text-align:left;"> -4.02 [-10.32, 2.28] </td>
   <td style="text-align:left;"> -3.68 [-12.63, 5.28] </td>
   <td style="text-align:left;"> -4.27 [-10.46, 1.91] </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female Patients </td>
   <td style="text-align:left;"> 0.01 [-7.35, 7.37] </td>
   <td style="text-align:left;"> 0.94 [-0.59, 2.47] </td>
   <td style="text-align:left;"> 41.85 [23.31, 60.39]* </td>
   <td style="text-align:left;"> 41.90 [-3.71, 87.52] </td>
   <td style="text-align:left;"> -6.91 [-10.22, -3.61]* </td>
   <td style="text-align:left;"> -9.76 [-14.62, -4.90]* </td>
   <td style="text-align:left;"> -5.53 [-8.73, -2.33]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Adjusting for BMI within Group </td>
   <td style="text-align:left;"> 0.93 [-5.83, 7.69] </td>
   <td style="text-align:left;"> 0.11 [-0.95, 1.16] </td>
   <td style="text-align:left;"> 36.50 [20.55, 52.45]* </td>
   <td style="text-align:left;"> 39.69 [2.54, 76.83]* </td>
   <td style="text-align:left;"> -7.09 [-10.08, -4.11]* </td>
   <td style="text-align:left;"> -9.86 [-14.25, -5.47]* </td>
   <td style="text-align:left;"> -5.74 [-8.57, -2.90]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BMI (Linear, obese-lean shift) </td>
   <td style="text-align:left;"> -4.19 [-7.11, -1.26]* </td>
   <td style="text-align:left;"> 0.60 [0.03, 1.18]* </td>
   <td style="text-align:left;"> 41.87 [31.54, 52.19]* </td>
   <td style="text-align:left;"> 54.89 [30.65, 79.14]* </td>
   <td style="text-align:left;"> -5.71 [-7.73, -3.69]* </td>
   <td style="text-align:left;"> -7.48 [-10.48, -4.48]* </td>
   <td style="text-align:left;"> -4.86 [-6.80, -2.93]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BMI (Spline ns df=4, obese-lean shift) </td>
   <td style="text-align:left;"> 0.31 [-8.35, 8.96] </td>
   <td style="text-align:left;"> -0.46 [-1.85, 0.93] </td>
   <td style="text-align:left;"> 29.06 [8.70, 49.42]* </td>
   <td style="text-align:left;"> 30.81 [-17.26, 78.87] </td>
   <td style="text-align:left;"> -11.13 [-15.66, -6.60]* </td>
   <td style="text-align:left;"> -16.05 [-22.78, -9.32]* </td>
   <td style="text-align:left;"> -8.57 [-12.91, -4.22]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Matching for BMI </td>
   <td style="text-align:left;"> -0.05 [-7.33, 7.22] </td>
   <td style="text-align:left;"> 0.34 [-0.73, 1.42] </td>
   <td style="text-align:left;"> 34.69 [13.73, 55.65]* </td>
   <td style="text-align:left;"> 38.20 [18.80, 57.61]* </td>
   <td style="text-align:left;"> -6.41 [-9.64, -3.19]* </td>
   <td style="text-align:left;"> -9.16 [-13.99, -4.32]* </td>
   <td style="text-align:left;"> -5.09 [-8.18, -1.99]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Class I Obesity </td>
   <td style="text-align:left;"> -4.58 [-12.15, 2.99] </td>
   <td style="text-align:left;"> -0.47 [-1.35, 0.40] </td>
   <td style="text-align:left;"> -12.78 [-27.24, 1.68] </td>
   <td style="text-align:left;"> -6.36 [-55.39, 42.66] </td>
   <td style="text-align:left;"> -5.25 [-8.75, -1.76]* </td>
   <td style="text-align:left;"> -8.27 [-13.37, -3.17]* </td>
   <td style="text-align:left;"> -3.98 [-7.34, -0.62]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Class II Obesity </td>
   <td style="text-align:left;"> 3.03 [-5.76, 11.82] </td>
   <td style="text-align:left;"> -0.19 [-1.09, 0.71] </td>
   <td style="text-align:left;"> 30.27 [11.10, 49.44]* </td>
   <td style="text-align:left;"> 1.75 [-51.78, 55.27] </td>
   <td style="text-align:left;"> -7.73 [-11.88, -3.57]* </td>
   <td style="text-align:left;"> -10.10 [-16.17, -4.03]* </td>
   <td style="text-align:left;"> -6.31 [-10.30, -2.31]* </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Class III Obesity </td>
   <td style="text-align:left;"> 5.90 [-2.13, 13.94] </td>
   <td style="text-align:left;"> 0.64 [-0.69, 1.97] </td>
   <td style="text-align:left;"> 80.07 [59.70, 100.45]* </td>
   <td style="text-align:left;"> 112.16 [55.49, 168.84]* </td>
   <td style="text-align:left;"> -9.02 [-13.06, -4.97]* </td>
   <td style="text-align:left;"> -11.18 [-17.09, -5.28]* </td>
   <td style="text-align:left;"> -7.97 [-11.86, -4.09]* </td>
  </tr>
</tbody>
</table>

`````

:::

```{.r .cell-code}
summary.sensitivity.data |> write_csv("Sensitivity Analyses.csv")
```
:::




Changes in matching
- n = 1:1, 1:5
- match by calendar year, not possible with existing data (recency bias)
- imputed missing data
- NB You should avoid imputing HbA1c because its missingness is plausibly missing not at random (MNAR): clinicians order HbA1c selectively when they suspect hyperglycaemia or known diabetes, so the probability a value is observed is directly related to the (unobserved) true HbA1c. Imputing under a MAR assumption will therefore produce biased estimates (and with only ~20 observed cases the imputations will be highly unstable), so treat HbA1c as a complete-case outcome or, if you must address missingness, use explicit MNAR sensitivity models (e.g., pattern-mixture or selection models) and report how much those assumptions would need to change to alter your conclusions.
- Gender term
- Stratified by adrenal/pituitary
- Including "non-treated"

## Session Information




::: {.cell}

```{.r .cell-code}
sessionInfo()
```

::: {.cell-output .cell-output-stdout}

```
R version 4.4.3 (2025-02-28)
Platform: x86_64-pc-linux-gnu
Running under: Red Hat Enterprise Linux 8.10 (Ootpa)

Matrix products: default
BLAS:   /sw/pkgs/arc/stacks/gcc/13.2.0/R/4.4.3/lib64/R/lib/libRblas.so 
LAPACK: /sw/pkgs/arc/stacks/gcc/13.2.0/R/4.4.3/lib64/R/lib/libRlapack.so;  LAPACK version 3.12.0

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
 [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
 [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

time zone: America/Detroit
tzcode source: system (glibc)

attached base packages:
[1] splines   stats     graphics  grDevices utils     datasets  methods  
[8] base     

other attached packages:
 [1] kableExtra_1.4.0 emmeans_1.11.2-8 MatchIt_4.7.1    knitr_1.48      
 [5] broom_1.0.12     lubridate_1.9.3  forcats_1.0.0    stringr_1.5.1   
 [9] dplyr_1.2.0      purrr_1.0.2      readr_2.1.5      tidyr_1.3.1     
[13] tibble_3.2.1     ggplot2_3.5.1    tidyverse_2.0.0 

loaded via a namespace (and not attached):
 [1] utf8_1.2.4         generics_0.1.3     xml2_1.3.6         lattice_0.22-6    
 [5] stringi_1.8.4      hms_1.1.3          digest_0.6.36      magrittr_2.0.3    
 [9] estimability_1.5.1 evaluate_0.24.0    grid_4.4.3         timechange_0.3.0  
[13] mvtnorm_1.3-1      fastmap_1.2.0      jsonlite_1.8.8     backports_1.5.0   
[17] fansi_1.0.6        viridisLite_0.4.2  scales_1.3.0       textshaping_0.4.0 
[21] cli_3.6.3          chk_0.10.0         rlang_1.1.7        crayon_1.5.3      
[25] bit64_4.0.5        munsell_0.5.1      withr_3.0.0        yaml_2.3.9        
[29] tools_4.4.3        parallel_4.4.3     tzdb_0.4.0         coda_0.19-4.1     
[33] colorspace_2.1-0   vctrs_0.7.1        R6_2.5.1           lifecycle_1.0.5   
[37] htmlwidgets_1.6.4  bit_4.0.5          vroom_1.6.5        pkgconfig_2.0.3   
[41] pillar_1.9.0       gtable_0.3.6       glue_1.8.0         Rcpp_1.0.14       
[45] systemfonts_1.3.1  highr_0.11         xfun_0.45          tidyselect_1.2.1  
[49] rstudioapi_0.16.0  xtable_1.8-4       htmltools_0.5.8.1  svglite_2.2.1     
[53] rmarkdown_2.27     compiler_4.4.3    
```


:::
:::
