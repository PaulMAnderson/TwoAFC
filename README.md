# TwoAFC Bpod Protocol

This repository contains the Bpod protocol for a Two-Alternative Forced Choice (2AFC) auditory discrimination task, optimized for integration with a DataJoint-based ephys pipeline.

## Overview

The `TwoAFC` protocol is designed for rodents to perform auditory evidence accumulation. Animals initiate trials by poking into a center port, sample a Poisson click train, and make a decision by poking into one of two side ports.

### Key Features (v4.0 Modernization)

The project is currently undergoing a modernization phase (branch `datajoint-naming`) to align Bpod data fields with a canonical naming scheme compatible with DataJoint.

- **Canonical Naming:** All `BpodSystem.Data.Custom` fields have been renamed to camelCase (e.g., `choiceLeft`, `sideProgrammed`, `evidenceStrength`) to match the snake_case schema in DataJoint.
- **Evidence Mismatch Detection:** Real-time detection of discrepancies between programmed stimuli and what the animal actually heard (based on sampling duration).
- **Performance Optimizations:** Significant refactoring of stimulus generation and data field updates for lower latency and better maintainability.
- **Psychometric Accuracy:** Standardized `evidenceStrength` sign convention (Positive = Right-dominant) for easier cross-session analysis.

## Repository Structure

- `TwoAFC.m`: Main protocol file (State Machine initialization and trial loop).
- `stateMatrix.m`: Defines the Bpod state transition matrix.
- `generateAuditoryStimuli.m`: Generates Poisson click trains with controlled evidence strength.
- `updateCustomDataFields.m`: Handles post-trial data processing and adaptive parameter updates (e.g., auto-incrementing difficulty).
- `MainPlot.m`: Real-time performance visualization during the session.
- `docs/MODERNISATION_PLAN.md`: Detailed specification of the v4.0 naming scheme and refactoring goals.

## Versioning

| Version | Description |
|---|---|
| v1-v3 | Legacy versions with varying naming conventions. |
| **v4.0** | Current active development. Features unified naming, bug fixes, and mismatch detection. |

## Usage

1. Load the protocol in the Bpod Console.
2. Ensure `TaskParameters` are correctly configured in the GUI.
3. Data is saved in the Bpod `Data` directory and is ready for ingestion via the companion EPHYS branch.

---
*Maintained by the Neural Oscillations Lab.*
