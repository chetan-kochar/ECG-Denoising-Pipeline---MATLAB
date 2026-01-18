# ECG-Denoising-Pipeline---MATLAB
Multi-Stage ECG Denoising Pipeline using MATLAB
## Overview
This project applies signal processing techniques to real ECG data with
the goal of improving signal quality while preserving diagnostic features.

Unlike synthetic signals, ECG recordings contain multiple noise sources
simultaneously. A single filter is not sufficient, so a multi-stage
filtering pipeline was designed and evaluated.

## Dataset
ECG data was obtained from the PhysioNet MIT-BIH Normal Sinus Rhythm Database.
A short segment of the signal was selected and resampled to 250 Hz for
consistent processing.

Only a limited segment is used in this repository to avoid redistribution
of the full dataset.

## Noise Sources Considered
The following noise components were modeled and addressed:
- Baseline wander (respiration and slow movement)
- Power line interference (50 Hz)
- Muscle artifacts (high-frequency EMG noise)
- Electrode contact noise

These noise sources commonly appear in real clinical ECG recordings.

## Filtering Pipeline

### Stage 1: High-Pass Filter (0.5 Hz)
Purpose:
- Remove baseline wander and slow electrode drift

Why this works:
- ECG diagnostic components lie above 0.5 Hz
- Most baseline-related noise is below this range

Result:
- Largest improvement in SNR compared to other stages

### Stage 2: Notch Filter (50 Hz)
Purpose:
- Suppress power line interference

Implementation details:
- Narrow bandwidth notch filter
- Zero-phase filtering using filtfilt to avoid waveform distortion

Result:
- Clear removal of the 50 Hz spike in frequency-domain plots

### Stage 3: Low-Pass Filter (40 Hz)
Purpose:
- Remove high-frequency muscle artifacts

Rationale:
- Most ECG diagnostic information lies below 40 Hz
- Frequencies above this range mainly contribute noise

Result:
- Final improvement in signal clarity without affecting QRS morphology

## Performance Evaluation
Signal quality was evaluated using:
- Signal-to-Noise Ratio (SNR)
- Mean Squared Error (MSE)
- Time-domain waveform comparison
- Frequency-domain validation using FFT

Overall improvement:
- Initial SNR: 4.69 dB
- Final SNR: 16.29 dB
- Total improvement: 11.60 dB

## Important Observations
- High-pass filtering had the largest impact due to dominant baseline noise
- Zero-phase filtering is critical for ECG signals
- Numerical metrics must be supported by visual and frequency analysis

## Tools Used
- MATLAB
- FFT
- Butterworth filters
- Notch filtering
- Zero-phase filtering (filtfilt)

## Future Improvements
- Real-time implementation on embedded platforms
