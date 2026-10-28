library(openesm); library(dplyr); library(lme4); library(lmerTest)
ds <- get_dataset('0001', metadata_version = '2.0.0', version = '3.0.0')
dat <- ds$data
dat_clean <- dat %>% mutate(resp_time = as.POSIXct(sub(' [A-Z]{2,4}$', '', response), format = '%Y-%m-%d %H:%M:%OS', tz = 'Europe/Brussels'), n_items = rowSums(!is.na(pick(worry:time_home))), answered = n_items > 0) %>% arrange(id, day, beep, desc(answered), resp_time) %>% distinct(id, day, beep, .keep_all = TRUE)
dat_final <- dat_clean %>% filter(answered, duration != 'Expired') %>% mutate(neg_tension = rowMeans(pick(irritable, angry, difficulties_relaxing)))
build_lag2 <- function(pred, out) { dat_final %>% arrange(id, day, beep) %>% group_by(id) %>% mutate(x_mean = mean(.data[[pred]], na.rm = TRUE), x_pmc = .data[[pred]] - x_mean, y_mean = mean(.data[[out]], na.rm = TRUE), y_pmc = .data[[out]] - y_mean) %>% ungroup() %>% group_by(id, day) %>% mutate(prev_x = lag(x_pmc), prev_y = lag(y_pmc), prev_beep = lag(beep)) %>% ungroup() %>% filter(!is.na(prev_x), !is.na(prev_y), beep == prev_beep + 1) }
dat_fwd2 <- build_lag2(pred = 'worry', out = 'neg_tension')
dat_rev2 <- build_lag2(pred = 'neg_tension', out = 'worry')
stopifnot(nrow(dat_fwd2) == 2767, nrow(dat_rev2) == 2767)
std <- function(d) d %>% mutate(across(c(x_pmc, prev_x, prev_y, y_pmc), ~ as.numeric(scale(.))))
dat_both <- bind_rows(std(dat_fwd2) %>% mutate(dir = 'fwd'), std(dat_rev2) %>% mutate(dir = 'rev'))
joint_int <- lmer(y_pmc ~ dir * (prev_x + prev_y) + x_pmc + x_mean + factor(beep) + (0 + x_pmc | id), data = dat_both, REML = FALSE)
boot_terms <- c('prev_x', 'prev_y', 'dirrev:prev_x', 'dirrev:prev_y')
boot_once <- function(d) { ids <- unique(d$id); picked <- sample(ids, length(ids), replace = TRUE); b <- bind_rows(lapply(seq_along(picked), function(i) d[d$id == picked[i], ] %>% mutate(id = i))); fit <- suppressWarnings(lmer(y_pmc ~ dir * (prev_x + prev_y) + x_pmc + x_mean + factor(beep) + (0 + x_pmc | id), data = b, REML = FALSE)); c(fixef(fit)[boot_terms], singular = isSingular(fit)) }
dir.create('results', showWarnings = FALSE)
set.seed(2026)
boot_raw <- t(replicate(1000, tryCatch(boot_once(dat_both), error = function(e) rep(NA_real_, length(boot_terms) + 1))))
colnames(boot_raw) <- c(boot_terms, 'singular')
saveRDS(boot_raw, 'results/boot_raw.rds')
ci <- apply(boot_raw[, boot_terms], 2, quantile, probs = c(0.025, 0.975), na.rm = TRUE)
write.csv(data.frame(term = colnames(ci), ci_lower = ci[1, ], ci_upper = ci[2, ]), 'results/bootstrap_ci.csv', row.names = FALSE)
results <- data.frame(term = c('prev_x (forward)', 'prev_y (forward)', 'prev_x difference (reverse - forward)', 'prev_y difference (reverse - forward)'), estimate = unname(fixef(joint_int)[boot_terms]), ci_lower = unname(ci[1, ]), ci_upper = unname(ci[2, ]))
write.csv(results, 'results/final_estimates.csv', row.names = FALSE)


# ---- Audit counts: reproduces Section 2.2-2.4 and Table 1 ----
cols <- names(dat)[which(names(dat) == "difficulties_relaxing"):which(names(dat) == "time_home")]
items_raw   <- rowSums(!is.na(dat[, cols]))
items_clean <- rowSums(!is.na(dat_clean[, cols]))

dup_split <- dat %>%
  mutate(items_all = items_raw) %>%
  group_by(id, day, beep) %>% filter(n() > 1) %>%
  summarise(answered_rows = sum(items_all > 0), .groups = "drop") %>%
  count(answered_rows)

d2 <- dat_final %>% arrange(id, day, beep) %>% group_by(id, day) %>%
  mutate(paired = !is.na(lag(beep)) & beep - lag(beep) == 1) %>% ungroup()

audit <- data.frame(
  quantity = c("raw rows", "duplicate rows removed", "rows after deduplication",
               "all items missing, raw", "all items missing, after dedup",
               "expired prompts with some responses", "outcome-only prompts",
               "final answered prompts", "prompts with a valid predecessor",
               "day-start prompts without predecessor", "later prompts without valid predecessor",
               "duplicate pairs: both empty", "duplicate pairs: one answered", "duplicate pairs: two answered"),
  value = c(nrow(dat), nrow(dat) - nrow(dat_clean), nrow(dat_clean),
            sum(items_raw == 0), sum(items_clean == 0),
            sum(dat_clean$duration == "Expired" & dat_clean$n_items > 0, na.rm = TRUE),
            sum(dat_clean$n_items == 0 & items_clean > 0),
            nrow(dat_final), sum(d2$paired),
            sum(!d2$paired & d2$beep == 1), sum(!d2$paired & d2$beep > 1),
            dup_split$n[dup_split$answered_rows == 0],
            dup_split$n[dup_split$answered_rows == 1],
            dup_split$n[dup_split$answered_rows == 2]))
write.csv(audit, "results/audit_counts.csv", row.names = FALSE)

stopifnot(
  nrow(dat) == 4372, nrow(dat) - nrow(dat_clean) == 33,
  nrow(dat_clean) - sum(items_clean == 0) - 7 - 1 == nrow(dat_final),
  nrow(dat_final) == 3938, sum(d2$paired) == 2767,
  sum(d2$paired) + sum(!d2$paired & d2$beep == 1) + sum(!d2$paired & d2$beep > 1) == nrow(dat_final)
)
