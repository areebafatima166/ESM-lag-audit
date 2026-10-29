# ESM lag audit: reproducible pipeline for lagged analyses of experience sampling data

This repository contains the R scripts and derived results for a methods study on preparing and analysing lagged multilevel models in experience sampling (ESM) data. The pipeline audits duplicate prompts, missed prompts, expired and unanswered responses, and day boundaries, then fits forward and reverse lagged mixed-effects models with participant-level cluster bootstrap confidence intervals.

## Data

The analyses use two openESM datasets, retrieved programmatically through the `openesm` R package (version 0.2.1):

- **Dataset 0001** (Fried, Papanikolaou & Epskamp, 2022; version 3.0.0; CC BY 4.0)
- **Dataset 0006** (Rowland & Wenzel, 2020; version 1.0.0; CC BY-NC 4.0)

No raw data are included in this repository. Retrieve the data through `openesm` and follow each dataset's licence.

## Scripts and run order

Run the scripts from the repository root (the folder containing this README). Each script creates the `results/` folder if it is missing. Run times are from a Windows 10 laptop.

1. `fried_covid_lag_analysis.R`: retrieves dataset 0001, runs the audit and cleaning steps, fits the joint model, and runs the 1,000-replicate cluster bootstrap. Then runs two checks: a sample-accounting audit with `stopifnot()` and a centering sensitivity analysis. Writes `results/boot_raw.rds`, `results/bootstrap_ci.csv`, `results/final_estimates.csv`, `results/audit_counts.csv`, and `results/centering_sensitivity.csv`. Takes about 4 minutes.
2. `fried_0006_analysis.R`: retrieves dataset 0006, builds the single-item pairs, checks them, and fits the joint model.
3. `fried_0006_bootstrap.R`: sources `fried_0006_analysis.R`, then runs the 1,000-replicate bootstrap for dataset 0006 and prints the number of successful and singular replicates. Writes `results/boot6_raw.rds` and `results/bootstrap6_ci.csv`. Takes about 12 to 14 minutes.
4. `fried_0001_low_engagement.R`: sources `fried_covid_lag_analysis.R`, then runs an exploratory sensitivity analysis on dataset 0001 that excludes participants at or below the 25th percentile of answered prompts. Writes `results/boot_low_raw.rds` and `results/low_engagement_ci.csv`. Takes about 6 minutes in total.

Scripts 3 and 4 source other scripts, so each one runs the chain it needs.

## Settings

- Random seed: 2026 (set before each bootstrap)
- Bootstrap replicates: 1,000, resampling whole participants. No replicate failed and none was singular in any of the three bootstrap runs.
- Estimation: maximum likelihood (`REML = FALSE`) with `lme4` 2.0-6 and `lmerTest` 3.2-1 in R 4.6.1. See `results/sessionInfo_0001.txt` and `results/sessionInfo_0006.txt` (both analyses were run in the same session environment).

## Reproducibility

Rerunning scripts 1, 3 and 4 (as background jobs in fresh R sessions) reproduced the saved bootstrap draws and confidence intervals exactly, so the reported intervals can also be recomputed from the saved `.rds` draws without refitting.

## Results folder

- `audit_counts.csv`: dataset 0001 audit counts (duplicates, all-missing prompts, final sample, pair accounting), written by script 1
- `centering_sensitivity.csv`: change in the four reported coefficients when person means are recomputed on the retained pairs, written by script 1
- `final_estimates.csv`, `bootstrap_ci.csv`: dataset 0001 estimates and intervals (script 1)
- `boot_raw.rds`: dataset 0001 bootstrap draws (script 1)
- `low_engagement_ci.csv`: dataset 0001 low-engagement estimates and intervals (script 4)
- `boot_low_raw.rds`: dataset 0001 low-engagement bootstrap draws (script 4)
- `final_estimates6.csv`, `bootstrap6_ci.csv`, `boot6_raw.rds`: dataset 0006 estimates, intervals, and draws (scripts 2 and 3)
- `sessionInfo_0001.txt`, `sessionInfo_0006.txt`: R session records

## Licence

Code is released under the MIT licence (see `LICENSE`). The openESM data keep their own licences, as stated above.

## Citation
Fatima, A. (2026). A checklist and reproducible pipeline for lagged analyses of experience sampling data. Preprint. Code: https://github.com/areebafatima166/ESM-lag-audit
