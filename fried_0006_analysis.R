library(openesm); library(dplyr); library(lme4); library(lmerTest)
ds2 <- get_dataset('0006', metadata_version = '2.0.0', version = '1.0.0')
raw6 <- ds2$data
items6 <- c('happy','excited','relaxed','satisfied','angry','anxious','depressed','sad')
grid6 <- raw6 %>% mutate(n_items = rowSums(!is.na(pick(all_of(items6)))), answered = n_items > 0,
  neg_tension2 = rowMeans(pick(angry, sad, depressed)), worry_proxy = anxious) %>% arrange(id, day, beep)
stopifnot(sum(rowSums(is.na(grid6[, c('angry','sad','depressed')])) %in% 1:2) == 0)
build_lag6 <- function(pred, out) { grid6 %>% group_by(id) %>%
  mutate(x_mean = mean(.data[[pred]], na.rm = TRUE), x_pmc = .data[[pred]] - x_mean,
         y_mean = mean(.data[[out]], na.rm = TRUE), y_pmc = .data[[out]] - y_mean) %>% ungroup() %>%
  group_by(id, day) %>% mutate(prev_x = lag(x_pmc), prev_y = lag(y_pmc), prev_beep = lag(beep)) %>%
  ungroup() %>% filter(!is.na(prev_x), !is.na(prev_y), !is.na(y_pmc), beep == prev_beep + 1) }
dat6_fwd3 <- build_lag6('anxious', 'angry')
dat6_rev3 <- build_lag6('angry', 'anxious')
stopifnot(nrow(dat6_fwd3) == 14257, nrow(dat6_rev3) == 14257)
std <- function(d) d %>% mutate(across(c(x_pmc, prev_x, prev_y, y_pmc), ~ as.numeric(scale(.))))
dat6_both3 <- bind_rows(std(dat6_fwd3) %>% mutate(dir = 'fwd'), std(dat6_rev3) %>% mutate(dir = 'rev'))
joint6_no  <- lmer(y_pmc ~ dir + x_pmc + prev_x + prev_y + x_mean + factor(beep) + (0 + x_pmc | id), data = dat6_both3, REML = FALSE)
joint6_int <- lmer(y_pmc ~ dir * (prev_x + prev_y) + x_pmc + x_mean + factor(beep) + (0 + x_pmc | id), data = dat6_both3, REML = FALSE)
print(anova(joint6_no, joint6_int))
