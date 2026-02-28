# Tumor Growth Modeling Using Nonlinear Regression in R

## Overview

This project analyzes longitudinal tumor growth data from placebo-treated mice using nonlinear regression techniques. The objective is to compare classical biological growth models and evaluate their ability to capture real tumor growth dynamics.

The models implemented include:

- Exponential growth model  
- Logistic growth model  
- Gompertz growth model  

Each mouse is treated as an independent time series.

---

## Research Objective

To determine which mathematical growth model best represents observed tumor volume progression over time in untreated (placebo) mice.

The analysis focuses on:

- Parameter estimation using nonlinear least squares  
- Stability and biological plausibility of fitted models  
- Comparison of growth dynamics across subjects  

---

## Dataset

The dataset contains:

- Mouse ID  
- Timepoint (days)  
- Tumor volume (mm³)  
- Drug regimen  

For this phase of the project, analysis is restricted to the **Placebo** group.

Data cleaning includes:

- Removal of missing values  
- Removal of duplicate entries  
- Removal of biologically invalid tumor volumes  
- Preservation of irregular time spacing  

No imputation or resampling was performed.

---

## Mathematical Models

### 1. Exponential Model

\[
V(t) = V_0 e^{rt}
\]

Models unrestricted tumor growth.

---

### 2. Logistic Model

\[
V(t) = \frac{K}{1 + e^{-r(t - t_m)}}
\]

Includes a carrying capacity `K`, modeling growth saturation.

---

### 3. Gompertz Model

\[
V(t) = K e^{-e^{-r(t - t_m)}}
\]

Captures asymmetric growth and decelerating expansion typical in tumor dynamics.

---

## Methodology

- Data cleaned in R  
- Nonlinear least squares regression performed using `nls()`  
- Bounded optimization applied to ensure biological realism  
- Each mouse modeled independently  

Parameter estimates are exported for further comparative analysis.

---
