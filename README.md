# ESM lag audit: reproducible pipeline for lagged analyses of experience sampling data

This repository contains the R scripts and derived results for a methods study on preparing and analysing lagged multilevel models in experience sampling (ESM) data. The pipeline audits duplicate prompts, missed prompts, expired and unanswered responses, and day boundaries, then fits forward and reverse lagged mixed-effects models with participant-level cluster bootstrap confidence intervals.

## Data

The analyses use two openESM datasets, retrieved programmatically through the `openesm` R package:

- **Dataset 0001** (Fried, Papanikolaou & Epskamp, 2022; version 3.0.0; CC BY 4.0)
- **Dataset 0006** (Rowland & Wenzel, 2020; version 1.0.0; CC BY-NC 4.0)

No raw data are included in this repository. Retrieve the data through `openesm` and follow each dataset's licence.

## Scripts and run order

Run the scripts from the repository root, in this order:

1. `fried_covid_lag_analysis.R`: retrieves dataset 0001, runs the audit and cleaning steps, fits the joint model, and runs the 1,000-replicate cluster bootstrap. Writes `results/boot_raw.rds`, `results/bootstrap_ci.csv`, and `results/final_estimates.csv`.
2. `fried_0006_analysis.R`: retrieves dataset 0006, builds the single-item pairs, checks them, and fits the joint model.
3. `fried_0006_bootstrap.R`: sources `fried_0006_analysis.R`, then runs the 1,000-replicate bootstrap for dataset 0006. Writes `results/boot6_raw.rds` and `results/bootstrap6_ci.csv`.
4. `fried_0001_low_engagement.R`: sources `fried_covid_lag_analysis.R`, then runs the low-engagement sensitivity analysis on dataset 0001. Writes `results/boot_low_raw.rds`.

Scripts 3 and 4 source other scripts, so each one runs the chain it needs. Script 2 is also run by script 3.

## Settings

- Random seed: 2026
- Bootstrap replicates: 1,000
- Estimation: maximum likelihood (`REML = FALSE`) with `lme4` 2.0-6 and `lmerTest` 3.2-1 in R 4.6.1. See `results/sessionInfo_0001.txt` and `results/sessionInfo_0006.txt`.

## Results folder

- `final_estimates.csv`, `bootstrap_ci.csv`: dataset 0001 estimates and intervals (script 1)
- `boot_raw.rds`: dataset 0001 bootstrap draws (script 1)
- `boot_low_raw.rds`: dataset 0001 low-engagement bootstrap draws (script 4)
- `final_estimates6.csv`, `bootstrap6_ci.csv`, `boot6_raw.rds`: dataset 0006 estimates, intervals, and draws (scripts 2 and 3)
- `sessionInfo_0001.txt`, `sessionInfo_0006.txt`: R session records

## Licence

Code is released under the MIT licence (see `LICENSE`). The openESM data keep their own licences, as stated above.

