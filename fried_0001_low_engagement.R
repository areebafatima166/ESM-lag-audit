
library(openesm); library(dplyr); library(lme4); library(lmerTest)

# ---- Rebuild the 0001 analysis data ----
source("fried_covid_lag_analysis.R")

# ---- Low-engagement subsample ----
resp <- dat_final %>% count(id, name = "n_answered")
low  <- resp %>% filter(n_answered <= quantile(n_answered, 0.25)) %>% pull(id)
dat_both_low <- dat_both %>% filter(!id %in% low)
cat("Excluded:", length(low), "| Remaining:", length(unique(dat_both_low$id)), "\n")

# ---- Bootstrap ----
boot_terms <- c("prev_x", "prev_y", "dirrev:prev_x", "dirrev:prev_y")

boot_once_low <- function(d) {
  ids    <- unique(d$id)
  picked <- sample(ids, length(ids), replace = TRUE)
  b <- bind_rows(lapply(seq_along(picked), function(i) {
    d[d$id == picked[i], ] %>% mutate(id = i)
  }))
  fit <- suppressWarnings(lmer(
    y_pmc ~ dir * (prev_x + prev_y) + x_pmc + x_mean + factor(beep) + (0 + x_pmc | id),
    data = b, REML = FALSE))
  c(fixef(fit)[boot_terms], singular = isSingular(fit))
}

set.seed(2026)
boot_low_raw <- t(replicate(1000, tryCatch(boot_once_low(dat_both_low),
                 error = function(e) rep(NA_real_, length(boot_terms) + 1))))
colnames(boot_low_raw) <- c(boot_terms, "singular")
dir.create("results", showWarnings = FALSE)
saveRDS(boot_low_raw, "results/boot_low_raw.rds")

