# ESM lag audit: reproducible pipeline for lagged analyses of experience sampling data

This repository contains the R scripts and derived results for a methods study on preparing and analysing lagged multilevel models in experience sampling (ESM) data. The pipeline audits duplicate prompts, missed prompts, expired and unanswered responses, and day boundaries, then fits forward and reverse lagged mixed-effects models with participant-level cluster bootstrap confidence intervals.

## Data

The analyses use two openESM datasets, retrieved programmatically through the `openesm` R package:

- **Dataset 0001** (Fried, Papanikolaou & Epskamp, 2022; version 3.0.0; CC BY 4.0)
- **Dataset 0006** (Rowland & Wenzel, 2020; version 1.0.0; CC BY-NC 4.0)

No raw data are included in this repository. Users should retrieve the data through openesm and follow each dataset's licence.

## Scripts and run order

Run the scripts in this order, from the project folder:

1. `fried_covid_lag_analysis.R`: retrieves dataset 0001, runs the audit and cleaning steps, fits the joint model, and runs the 1,000-replicate cluster bootstrap.
2. `fried_0006_analysis.R`: retrieves dataset 0006, builds the single-item pairs, and fits the joint model.
3. `fried_0006_bootstrap.R`: runs the 1,000-replicate bootstrap for dataset 0006.
4. `fried_0001_low_engagement.R`: runs the low-engagement sensitivity analysis on dataset 0001.

Each script is self-contained apart from the call to `fried_covid_lag_analysis.R` in step 4.

## Settings

- Random seed: 2026
- Bootstrap replicates: 1,000
- Estimation: maximum likelihood (`REML = FALSE`) with `lme4` 2.0-6 and `lmerTest` 3.2-1 in R 4.6.1 (see `results/sessionInfo_0001.txt` and `results/sessionInfo_0006.txt`)

## Results

The `results/` folder contains:

- `final_estimates.csv` and `bootstrap_ci.csv`: dataset 0001 estimates and intervals
- `bootstrap6_ci.csv`: dataset 0006 intervals
- `boot_raw.rds`, `boot6_raw.rds`, `boot_low_raw.rds`: saved bootstrap draws
- `sessionInfo_0001.txt`, `sessionInfo_0006.txt`: session records

## Licence

The code in this repository is released under the MIT licence (see `LICENSE`). The openESM data keep their own licences, as stated above.

