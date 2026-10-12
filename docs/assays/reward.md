# Reward & decision

## Conditioned place preference {#conditioned-place-preference}

Preference for a chamber that was paired with a drug or reward.

**Arena.** Rectangle covering the whole apparatus, with the chambers side by side from left to right in the image. Phase: **Pre-test**, **Conditioning** or **Test**.

**Settings**

| Setting | Default | Meaning |
|---|---|---|
| Apparatus | 2 chambers | 2 or 3 chambers |
| Divider position (2 chambers) | 50 % from left | Where the two chambers meet |
| Neutral chamber width (3 chambers) | 20 % of arena | Width of the middle chamber, centered |
| Paired (drug / reward) side | Left | Which side chamber was paired |
| Zone entry criterion | 0.5 s | Minimum stay for a chamber entry |

| Metric | Unit | Definition |
|---|---|---|
| Preference score | s | Paired − unpaired chamber time |
| Paired-side preference | % | Paired / (paired + unpaired) × 100. Chance is 50 %. |
| Paired, unpaired chamber time | s | Time in each side chamber |
| Neutral chamber time | s | Time in the middle chamber (3-chamber apparatus) |
| Paired chamber entries | count | Entries into the paired chamber |
| Total distance | m | |

**Analysis.** The usual CPP measure is the change from pre-test to test. In the Groups tab choose *Change between phases*, **From** Pre-test **To** Test, measure *Preference score*. Each animal's test − pre-test difference is then compared between groups. *Paired measures* (paired vs unpaired side) tests the preference within each group.

## Two-armed bandit {#two-armed-bandit}

Trial-by-trial choices between two options with probabilistic rewards, often with reversals of which option is better. The data come from an operant box or a T-maze. They are entered trial by trial (**Enter Trials**) or, more conveniently, imported from a trial CSV.

**Columns** (one row per trial): `subject`, `group`, optional `day` or `phase` (session / block), `trial`, `choice` (`L`/`R`, `left`/`right` or `0`/`1`), `reward` (`0`/`1`), and optionally `p_left`, `p_right` (the reward probabilities on that trial) and `rt` (reaction time in s). See the [sample file](/samples/example_bandit_trials.csv).

| Metric | Unit | Definition |
|---|---|---|
| High-value choices | % | Choices of the option with the higher reward probability (needs `p_left`/`p_right`). Chance is 50 %. |
| Reward rate | % | Rewarded trials / trials × 100 |
| Win-stay | % | P(same choice as the previous trial \| previous trial rewarded) × 100 |
| Lose-shift | % | P(other choice \| previous trial unrewarded) × 100 |
| Switch rate | % | P(choice differs from the previous trial) × 100 |
| Right choices | % | Side bias. Chance is 50 %. |
| Learning rate α | — | Q-learning fit (see below) |
| Inverse temperature β | — | Q-learning fit |
| Model pseudo-R² | — | 1 − NLL / (n · ln 2), where 0 means chance-level prediction |
| Trials | count | |
| Mean reaction time | s | Mean of the `rt` column |

Series: the probability of choosing the new best option from 5 trials before to 20 trials after each reversal, available when reward probabilities are given. The result screen also plots the choices across the session.

**The Q-learning model.** Each option has a value *Q*, starting at 0.5. After each trial, the chosen option is updated:

*Q* ← *Q* + α (*r* − *Q*), with *r* = 1 if rewarded, else 0.

The choice probability follows a softmax of the value difference:

P(right) = 1 / (1 + exp(−β (*Q*<sub>right</sub> − *Q*<sub>left</sub>))).

α (0–1) and β (0–50) are fitted by maximum likelihood, using a grid search refined by a local search, on each animal's full trial sequence. At least 10 trials are needed. The negative log-likelihood and BIC are listed under the result's parameters.
