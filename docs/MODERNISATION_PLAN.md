# TwoAFC v4.0 — Naming Modernisation & DataJoint Alignment

**Branch:** `datajoint-naming`  
**Status:** In progress  
**Scope:** TwoAFC Bpod protocol + EPHYS IO/DataJoint pipeline

---

## Motivation

The TwoAFC protocol has evolved through three protocol generations with no
consistent naming scheme. Field names in the Bpod `.mat` output, the intermediate
MATLAB processing tables, and the DataJoint schema all differ — sometimes
substantially. This causes silent errors (DV sign flip), redundant storage (three
mismatch columns), and confusion for anyone new to the codebase. This document
describes the changes needed to unify all three layers under a single canonical
vocabulary, fix known bugs, and introduce a coherent version scheme so that legacy
data from all previous protocol generations can still be correctly processed.

---

## Protocol Version Scheme

| Label | Bpod struct layout | Typical protocol names | Detection |
|---|---|---|---|
| `v1` | Flat struct (no `Custom` sub-struct) | `Click2AFCRewPulsSingleSlim2`, `PokeInCenterRewLongWaitSlim` | `~isfield(data, 'Custom')` |
| `v2` | `Custom` struct present, no `LingersTime`, uses `FixBroke` | `Dual2AFCPaul`, `Dual2AFCBen`, `Dual2AFCRicardo` | `isfield(data,'Custom') && ~isfield(data.Custom,'LingersTime')` |
| `v3` | `Custom` struct + `LingersTime`, uses `BrokeFixation` | `TwoAFC` (v2.0), `TwoAFCTraining` | `isfield(data.Custom,'LingersTime') && ~isfield(data.Custom,'sideProgrammed')` |
| `v4` | `Custom` struct + new canonical field names | `TwoAFC` (this branch, v4.0) | `isfield(data.Custom,'sideProgrammed')` |

The current task protocol sets `BpodSystem.Data.Info.ProtocolVersion = '4.0'`.
All EPHYS conversion code uses the version label to route to the correct parsing
path; legacy v1/v2/v3 data is unaffected.

---

## Canonical Field Name Map

### Three-layer alignment

All three layers must agree. The table below shows the full mapping.
`_played` suffix = what the animal actually heard (clicks within sampling window).
`_bpod` suffix on timing fields = Bpod internal clock (seconds from session start).
No suffix on timing fields = relative to trial start.

#### Evidence / Stimulus Identity

| Bpod Custom (v4) | MATLAB table (canonical) | DataJoint field | Type | Description |
|---|---|---|---|---|
| `sideProgrammed` | `sideProgrammed` | `side_programmed` | `enum('left','right','none')` | Side with more *programmed* clicks |
| `sidePlayed` | `sidePlayed` | `side_played` | `enum('left','right','none')` | Side with more *heard* clicks |
| `omega` | `omega` | `omega` | `float` | Beta-distribution draw (0–1); 0.5 = equal evidence |
| `trialAlpha` | `trialAlpha` | `trial_alpha` | `float` | Per-trial difficulty parameter |
| `clickRateLeft` | `clickRateLeft` | `click_rate_left` | `smallint` | Programmed left click rate (Hz) |
| `clickRateRight` | `clickRateRight` | `click_rate_right` | `smallint` | Programmed right click rate (Hz) |
| `clickTrainLeft` | `clickTrainLeft` | `click_train_left` | `longblob` | Played left click timestamps (s, within sampling window) |
| `clickTrainRight` | `clickTrainRight` | `click_train_right` | `longblob` | Played right click timestamps (s) |
| `nClicksLeft` | `nClicksLeft` | `n_clicks_left` | `smallint` | Count of left clicks heard |
| `nClicksRight` | `nClicksRight` | `n_clicks_right` | `smallint` | Count of right clicks heard |
| `evidenceStrength` | `evidenceStrength` | `evidence_strength` | `float` | `(nRight−nLeft)/(nRight+nLeft)`, +ve = right-dominant |
| `evidenceMismatch` | `evidenceMismatch` | `evidence_mismatch` | `tinyint` | `sideProgrammed != sidePlayed` (for non-fixation-broken trials) |

**Note on `evidenceStrength` sign convention:** Positive = more right clicks = animal
should go right. This is the standard psychometric convention (x-axis of
psychometric curve: positive = rightward evidence → rightward choice more likely).
The old `DV` field had the **opposite** sign (positive = more left clicks). This
was a bug causing a silent sign flip between the protocol and the EPHYS
post-processing code.

**Note on `clickTrainLeft/Right`:** These store the timestamps of clicks within
the sampling window (i.e., what the animal actually heard). The full programmed
trains are recoverable from the raw Bpod struct stored in `ConfidenceSession`.

#### Choice and Correctness

| Bpod Custom (v4) | MATLAB table | DataJoint | Type | Description |
|---|---|---|---|---|
| `choiceLeft` | `choiceLeft` | _(internal)_ | `logical` | 1=left, 0=right, NaN=no choice (Bpod internal) |
| — | `choice` | `choice` | `enum('left','right','none')` | Which port entered |
| `choiceCorrect` | `choiceCorrect` | `choice_correct` | `tinyint` | Correct per programmed evidence |
| — | `choiceCorrectPlayed` | `choice_correct_played` | `tinyint` | Correct per heard evidence |

#### Trial Completion Stages

| Bpod Custom (v4) | MATLAB table | DataJoint | Type | Description |
|---|---|---|---|---|
| `brokeFixation` | `brokeFixation` | `broke_fixation` | `tinyint` | Left centre port during pre-stimulus delay |
| `earlyWithdrawal` | `earlyWithdrawal` | `early_withdrawal` | `tinyint` | Left during stimulus (< minSamplingTime) |
| — | `samplingCompleted` | `sampling_completed` | `tinyint` | `~brokeFixation & ~earlyWithdrawal` |
| — | `trialCompleted` | `trial_completed` | `tinyint` | `samplingCompleted & choice != 'none'` |
| `catchTrial` | `catchTrial` | `catch_trial` | `tinyint` | No reward-port signal; tests confidence |
| — | `catchCompleted` | `catch_completed` | `tinyint` | Catch trial where animal waited full period |
| `rewarded` | `rewarded` | `rewarded` | `tinyint` | Reward delivered |
| `isEasyTrial` | `isEasyTrial` | `is_easy_trial` | `tinyint` | Warm-up trial (α=0.1) |
| — | `punished` | `punished` | `tinyint` | Animal received punishment |

#### Timing

`_bpod` suffix = Bpod internal clock (seconds). All other times are relative to
trial start (also Bpod clock) unless stated.

| Bpod Custom (v4) | MATLAB table | DataJoint | Type | Description |
|---|---|---|---|---|
| _(TrialStartTimestamp)_ | `trialStartBpod` | `trial_start_bpod` | `float` | Trial start in Bpod clock |
| `fixationDuration` | `fixationDuration` | `fixation_duration` | `float` | Programmed pre-stimulus centre-hold (drawn from TruncExp) |
| `fixationTime` | `fixationTime` | `fixation_time` | `float` | Actual time held centre during pre-stimulus |
| — | `stimulusOnset` | `stimulus_onset` | `float` | When clicks began (relative to trial start) |
| `samplingDuration` | `samplingDuration` | `sampling_duration` | `float` | How long animal sampled |
| `movementDuration` | `movementDuration` | `movement_duration` | `float` | Time from stimulus end to choice port entry |
| — | `decisionOnset` | `decision_onset` | `float` | When waiting period began (relative to trial start) |
| `waitDuration` | `waitDuration` | `wait_duration` | `float` | Time in choice port (the confidence proxy) |
| `lingerDuration` | `lingerDuration` | `linger_duration` | `float` | Post-reward port occupancy |
| `rewardDelay` | `rewardDelay` | `reward_delay` | `float` | Programmed delay to reward for this trial |
| — | `rewardTime` | `reward_time` | `float` | When reward was delivered (relative to trial start) |
| `minSamplingTime` | `minSamplingTime` | _(settings)_ | `float` | Minimum sampling duration enforced this trial |
| — | `portExitTimeBpod` | `port_exit_time_bpod` | `float` | When animal left choice port (Bpod clock) |
| — | `portExitSample` | `port_exit_sample` | `int` | Same event, ephys master clock |
| — | `portExitSource` | `port_exit_source` | `enum` | `sensor/pose/imputed` |

#### Reward and Animal Identity

| Bpod Custom (v4) | MATLAB table | DataJoint | Type | Description |
|---|---|---|---|---|
| `rewardAmount` | `rewardAmount` | _(settings)_ | `float[2]` | `[left_uL, right_uL]` per trial |
| `trialNumber` | `trialNumber` | `trial_number` | `int` | 1-based trial index |
| `startEasyTrials` | `startEasyTrials` | _(session)_ | `int` | Threshold for warm-up period |

#### Trial Outcome (simplified enum)

The verbose compound strings (e.g. `"Match, Correct, Unrewarded - WT"`) are
replaced by a compact 7-value vocabulary. Mismatch information is captured in the
boolean flags and is not encoded into the outcome label.

| Value | Meaning |
|---|---|
| `rewarded` | Correct choice, full waiting period completed |
| `error` | Incorrect choice, punished |
| `wait_miss` | Correct choice but left port before reward |
| `catch_hit` | Catch trial: stayed full period |
| `catch_miss` | Catch trial: left early |
| `no_choice` | Sampling completed but no side-port entry |
| `aborted` | Did not complete sampling |

---

## Bugs Fixed in This Branch

### TwoAFC Protocol (Bpod)

**B1. DV sign flip (was a silent analysis error)**  
`DV = (nLeft−nRight)/(nLeft+nRight)` in the protocol (positive = left-dominant)
but `decisionVariable = (nRight−nLeft)/(nRight+nLeft)` in EPHYS post-processing
(positive = right-dominant). These are opposite. The psychometric plot in
`MainPlot.m` compensated by using `−DV` on the x-axis. The new `evidenceStrength`
uses the right-dominant convention throughout. `MainPlot.m` is updated accordingly
(outcome y-axis plots `−evidenceStrength` to preserve visual convention).

**B2. `nargin` guard in `generateAuditoryStimuli.m` always triggers**  
`nargin < 4` is always true for a 3-argument function, causing the `leftBias`
parameter to always be overwritten with `TaskParameters.GUI.FutureLeftBias` even
when explicitly passed. Fixed to `nargin < 3`.

**B3. Fallback click-train assignment uses scalar field instead of indexed**  
In `generateAuditoryStimuli.m` (else branch, both-empty case):
`round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000` references
`LeftClickRate` as a scalar instead of `LeftClickRate(trialIdx)`. Fixed.

**B4. `MoreLeftClicks = NaN` on 50-50 trials counts as "right" in text panel**  
The NaN-replace-with-0 logic in `MainPlot.m` made equal-evidence trials count
as right trials in per-side accuracy stats. With `sideProgrammed = 'none'` these
trials are now correctly excluded from both left and right counts.

### EPHYS Pipeline (to be fixed in EPHYS branch)

**E1. `highEvidenceSideClicks = 'right'` for equal-click trials**  
`categorical(nLeft > nRight, [1,0], {'left','right'})` maps 0=0 (equal) to
`'right'`. Fix: use three-value mapping with `'none'` for the equal case.

**E2. Three redundant mismatch columns**  
`mismatch_detected`, `evidence_match`, `evidence_mismatch` all express the same
bit. Keep only `evidence_mismatch`.

**E3. `punishState` computed incorrectly for New/2.0 protocols**  
`ChoiceCorrect==0 & ~CatchTrial` is used as a proxy but does not match the actual
Bpod `timeOut_Incorrect` state. Animals that leave during the grace period are
incorrectly flagged.

**E4. `trialOutcome` categorical has incomplete coverage**  
Some trial combinations produce `<undefined>` entries without warning.

**E5. `ConfidenceSettings` DJ table has mismatched left/right reward delay fields**  
`min_reward_delay_right` exists but `min_reward_delay_left` does not.
Fields `max_reward_delay_left` and `exp_reward_delay_left` are inconsistently
named.

**E6. Duplicate `rightClicks` closure calls `clicksOccuredLeft`**  
Dormant dead-code bug in `generate2AFCConversion.m`.

**E7. `extractTrials2AFC.m` does not parse (malformed nested function)**  
File is a broken draft. To be removed.

**E8. `twoAFCParser.m` is an abandoned parallel implementation**  
Incomplete code with undefined variables. To be removed.

**E9. Duplicate `getTrialEventStart/End/Times` definitions**  
Defined separately in `TwoAFCSession2Table.m` and `extractRawData.m`. To be
moved to a shared utility.

---

## Evidence Mismatch Detection

A mismatch occurs when the animal leaves the centre port during the stimulus
(`stimulus_delivery` state, after `MinSampleAud` but before `AuditoryStimulusTime`)
and the heard click distribution differs from the programmed one. This is the
scientifically important case the original v3 protocol did not flag.

The fix lives in `updateCustomDataFields.m` (host-side MATLAB, runs after each
trial on the computer, not on the Bpod hardware). It cannot react mid-trial
(the state machine has already exited) but it can record the correct mismatch flag
before the next trial begins, ensuring the `.mat` file is self-consistent.

```
After each trial, in updateCustomDataFields:
  nClicksLeft  = sum(clickTrainLeft{iTrial}  <= samplingDuration(iTrial))
  nClicksRight = sum(clickTrainRight{iTrial} <= samplingDuration(iTrial))
  sidePlayed   = 'left'/'right'/'none' depending on counts
  evidenceMismatch = ~brokeFixation(iTrial) && sideProgrammed{iTrial} != sidePlayed{iTrial}
```

This correctly handles:
- `brokeFixation = true`: no stimulus delivered, no comparison needed
- `earlyWithdrawal = true`: stimulus started but animal left before `MinSampleAud`
- Animal leaves during `stimulus_delivery`: the scientifically important case

---

## Files Changed (TwoAFC branch)

| File | Change type | Summary |
|---|---|---|
| `TwoAFC.m` | Rename + version | Field init renames, version `'2.0'` → `'4.0'` |
| `generateAuditoryStimuli.m` | Rename + bug fix | All field renames, DV sign flip, nargin fix, fallback fix |
| `updateCustomDataFields.m` | Rename + new fields | All field renames, add `nClicksLeft/Right`, `sidePlayed`, `evidenceMismatch` |
| `stateMatrix.m` | Logic update | `MoreLeftClicks` numeric → `sideProgrammed` string comparison |
| `MainPlot.m` | Rename + sign fix | All field renames, psychometric x-axis fix, outcome y-axis negation |
| `DailyAnalysisDual2AFC.m` | Deprecated | Calls `Dual2AFCRicardo` (v2-era class, not in repo); marked for rewrite |
| `docs/MODERNISATION_PLAN.md` | New | This document |

---

## Files to Change (EPHYS branch — follow-on)

| File | Change |
|---|---|
| `+EPHYS/+IO/+Confidence/generate2AFCConversion.m` | Add `'v4'` case; fix duplicate `minimumRewardDelayRight`; fix `rightClicks` closure |
| `+EPHYS/+IO/+Confidence/TwoAFCSession2Table.m` | Rename output column names to canonical scheme |
| `+EPHYS/+IO/+Confidence/combineTrialConditions.m` | Fix `highEvidenceSideClicks` 3-value mapping; fix `trialOutcome` coverage; remove redundant mismatch cols |
| `+EPHYS/+IO/+Confidence/extractRawData.m` | Remove duplicate helper functions |
| `datajoint/+task/ConfidenceTrial.m` | Rename all DJ fields to canonical scheme; remove redundant mismatch cols |
| `datajoint/+task/ConfidenceSettings.m` | Fix asymmetric left/right reward delay fields |
| `datajoint/+task/TwoAFCTrial.m` | Align to canonical fields |
| `datajoint/Functions/extractTrials2AFC.m` | Delete (broken stub) |
| `+EPHYS/+IO/+Confidence/twoAFCParser.m` | Delete (abandoned draft) |
| `+EPHYS/+IO/+Confidence/Session.m` | Add `'v4'` generation detection |

---

## Backward Compatibility

Legacy `.mat` files from v1/v2/v3 sessions are handled entirely in the EPHYS
conversion layer. The `generate2AFCConversion.m` dispatch table routes each
version to the correct field-name mapping. All versions produce the same canonical
output table regardless of source. No existing `.mat` files are modified.

The `'v4'` generation is detected by presence of `Custom.sideProgrammed` (a string
cell array — a v3 file cannot have this field as it used the numeric
`MoreLeftClicks`).

---

## Implementation Status

- [x] Branch `datajoint-naming` created
- [x] Plan document written
- [x] `TwoAFC.m` updated
- [x] `generateAuditoryStimuli.m` updated
- [x] `updateCustomDataFields.m` updated
- [x] `stateMatrix.m` updated
- [x] `MainPlot.m` updated
- [ ] `DailyAnalysisDual2AFC.m` — marked deprecated, pending rewrite
- [ ] EPHYS pipeline changes (separate branch)
