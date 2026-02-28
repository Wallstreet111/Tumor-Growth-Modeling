# ============================================================
# Tumor Growth Modeling – Placebo Group
# Models:
#   1. Exponential
#   2. Logistic (inflection form)
#   3. Gompertz (inflection form)
# ============================================================

library(dplyr)

# ------------------------------------------------------------
# 1. Load Cleaned Dataset
# ------------------------------------------------------------
setwd("C:/CalculusResearchProject")

data <- read.csv("cleaned_placebo_data.csv")

# Ensure correct column types
data$Timepoint   <- as.numeric(data$Timepoint)
data$TumorVolume <- as.numeric(data$TumorVolume)

# ------------------------------------------------------------
# 2. Prepare Storage for Parameter Estimates
# ------------------------------------------------------------
results <- data.frame()

mice <- unique(data$Mouse.ID)

# ------------------------------------------------------------
# 3. Loop Through Each Mouse
# ------------------------------------------------------------

for (mouse in mice) {
  
  mouse_data <- data %>%
    filter(Mouse.ID == mouse)
  
  t <- mouse_data$Timepoint
  V <- mouse_data$TumorVolume
  
  # Skip mouse if too few data points
  if (length(t) < 5) next
  
  # --------------------------
  # Initial Parameter Guesses
  # --------------------------
  V0_start <- min(V)
  r_start  <- 0.02
  K_start  <- max(V) * 1.3
  tm_start <- median(t)
  
  # ==========================================================
  # 1. EXPONENTIAL MODEL
  # V(t) = V0 * exp(r t)
  # ==========================================================
  
  exp_fit <- try(
    nls(V ~ V0 * exp(r * t),
        start = list(
          V0 = V0_start,
          r  = r_start
        ),
        algorithm = "port",
        lower = c(0, 0),
        upper = c(Inf, 1)),
    silent = TRUE
  )
  
  # ==========================================================
  # 2. LOGISTIC MODEL (Stable Form)
  # V(t) = K / (1 + exp(-r (t - tm)))
  # ==========================================================
  
  log_fit <- try(
    nls(V ~ K / (1 + exp(-r * (t - tm))),
        start = list(
          K  = K_start,
          r  = r_start,
          tm = tm_start
        ),
        algorithm = "port",
        lower = c(0, 0, min(t)),
        upper = c(Inf, 1, max(t))),
    silent = TRUE
  )
  
  # ==========================================================
  # 3. GOMPERTZ MODEL
  # V(t) = K * exp(-exp(-r (t - tm)))
  # ==========================================================
  
  gom_fit <- try(
    nls(V ~ K * exp(-exp(-r * (t - tm))),
        start = list(
          K  = K_start,
          r  = r_start,
          tm = tm_start
        ),
        algorithm = "port",
        lower = c(0, 0, min(t)),
        upper = c(Inf, 1, max(t))),
    silent = TRUE
  )
  
  # ------------------------------------------------------------
  # Extract Coefficients or Assign NA
  # ------------------------------------------------------------
  
  # Exponential
  if (class(exp_fit) != "try-error") {
    coef_exp <- coef(exp_fit)
    Exp_V0 <- coef_exp["V0"]
    Exp_r  <- coef_exp["r"]
  } else {
    Exp_V0 <- NA
    Exp_r  <- NA
  }
  
  # Logistic
  if (class(log_fit) != "try-error") {
    coef_log <- coef(log_fit)
    Log_K  <- coef_log["K"]
    Log_r  <- coef_log["r"]
    Log_tm <- coef_log["tm"]
  } else {
    Log_K  <- NA
    Log_r  <- NA
    Log_tm <- NA
  }
  
  # Gompertz
  if (class(gom_fit) != "try-error") {
    coef_gom <- coef(gom_fit)
    Gom_K  <- coef_gom["K"]
    Gom_r  <- coef_gom["r"]
    Gom_tm <- coef_gom["tm"]
  } else {
    Gom_K  <- NA
    Gom_r  <- NA
    Gom_tm <- NA
  }
  
  # ------------------------------------------------------------
  # Store Results
  # ------------------------------------------------------------
  
  results <- rbind(results,
                   data.frame(
                     MouseID = mouse,
                     
                     Exp_V0 = Exp_V0,
                     Exp_r  = Exp_r,
                     
                     Log_K  = Log_K,
                     Log_r  = Log_r,
                     Log_tm = Log_tm,
                     
                     Gom_K  = Gom_K,
                     Gom_r  = Gom_r,
                     Gom_tm = Gom_tm
                   ))
}

# ------------------------------------------------------------
# 4. Export Parameter Estimates
# ------------------------------------------------------------

write.csv(results,
          "placebo_model_parameters.csv",
          row.names = FALSE)

cat("Model fitting complete.\n")
cat("Results saved as placebo_model_parameters.csv\n")

