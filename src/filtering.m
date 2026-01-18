% Updated script: Stage 4 removed; anything related to Stage 4 plots removed/replaced.
load("noise.mat")

%% STAGE 1: HIGH-PASS FILTER (Remove Baseline Wander)
cutoff_HP = 0.5;
[b,a] = butter(6, cutoff_HP/(fs/2), "high");
ecg_stage1 = filtfilt(b, a, ecg_noisy);

MSE_stage1 = mean((ecg_stage1 - ecg_normal).^2);
SNR_stage1 = 10*log10(var(ecg_normal) / var(ecg_stage1 - ecg_normal));
fprintf('\n=== STAGE 1: HIGH-PASS FILTER ===\n');
fprintf('Cutoff: %.1f Hz\n', cutoff_HP);
fprintf('Removes: Baseline wander (0.2-0.4 Hz)\n');
fprintf('MSE: %.4f\n', MSE_stage1);
fprintf('SNR: %.2f dB (Improvement: %.2f dB)\n\n', SNR_stage1, SNR_stage1 - SNR_initial);


%% STAGE 2: NOTCH FILTER (Remove 50 Hz Power Line)
notch_freq = 50;
wo = notch_freq/(fs/2);
Q = 40;
BW = (notch_freq/Q)/(fs/2);
[b,a] = iirnotch(wo, BW);

ecg_stage2 = filtfilt(b, a, ecg_stage1);

MSE_stage2 = mean((ecg_stage2 - ecg_normal).^2);
SNR_stage2 = 10*log10(var(ecg_normal) / var(ecg_stage2 - ecg_normal));

fprintf('\n=== STAGE 2: NOTCH FILTER ===\n');
fprintf('Notch frequency: %d Hz (Normalized: %.4f)\n', notch_freq, wo);
fprintf('Removes: Power line interference\n');
fprintf('MSE: %.4f\n', MSE_stage2);
fprintf('SNR: %.2f dB (Improvement: %.2f dB)\n', SNR_stage2, SNR_stage2 - SNR_stage1);


%% STAGE 3: LOW-PASS FILTER (Remove High-Frequency Muscle Noise)
cutoff_lp = 40;
ecg_final = lowpass(ecg_stage2, cutoff_lp, fs);

MSE_final = mean((ecg_final - ecg_normal).^2);
SNR_final = 10*log10(var(ecg_normal) / var(ecg_final - ecg_normal));

fprintf('\n=== STAGE 3: LOW-PASS FILTER ===\n');
fprintf('Cutoff: %d Hz\n', cutoff_lp);
fprintf('Removes: Muscle artifact (>40 Hz)\n');
fprintf('MSE: %.4f\n', MSE_final);
fprintf('SNR: %.2f dB (Improvement: %.2f dB)\n', SNR_final, SNR_final - SNR_stage2);


%% Summary
fprintf('\n=== Filtering SUMMARY ===\n');
fprintf('Initial SNR:  %.2f dB\n', SNR_initial);
fprintf('Final SNR:    %.2f dB\n', SNR_final);
fprintf('Total Gain:   %.2f dB\n', SNR_final - SNR_initial);


%% TIME DOMAIN Analysis
figure();

% Subplot 1: Clean reference
subplot(5,1,1)
plot(t_clean, ecg_normal, 'b-', 'LineWidth', 1.5)
title('Reference: Clean ECG', 'FontSize', 12, 'FontWeight', 'bold')
ylabel('Amplitude'); grid on; xlim([0 3]); ylim([-1.5 1.5])

% Subplot 2: Noisy input
subplot(5,1,2)
plot(t_clean, ecg_noisy, 'r-', 'LineWidth', 1)
title(sprintf('Input: Noisy ECG (SNR = %.2f dB)', SNR_initial), 'FontSize', 12)
ylabel('Amplitude'); grid on; xlim([0 3]); ylim([-2 2])

% Subplot 3: After Stage 1
subplot(5,1,3)
plot(t_clean, ecg_stage1, 'Color', [0 0.7 0], 'LineWidth', 1.2)
title(sprintf('Stage 1: After High-Pass (%.1f Hz) - SNR = %.2f dB', cutoff_HP, SNR_stage1), 'FontSize', 11)
ylabel('Amplitude'); grid on; xlim([0 3]); ylim([-1.5 1.5])

% Subplot 4: After Stage 2
subplot(5,1,4)
plot(t_clean, ecg_stage2, 'Color', [0.8 0 0.8], 'LineWidth', 1.2)
title(sprintf('Stage 2: After Notch (%d Hz) - SNR = %.2f dB', notch_freq, SNR_stage2), 'FontSize', 11)
ylabel('Amplitude'); grid on; xlim([0 3]); ylim([-1.5 1.5])

% Subplot 5: After Stage 3 (Final)
subplot(5,1,5)
plot(t_clean, ecg_final, 'Color', [0 0.5 0.8], 'LineWidth', 1.5)
title(sprintf('Final: After Low-Pass (%d Hz) - SNR = %.2f dB', cutoff_lp, SNR_final), 'FontSize', 11)
ylabel('Amplitude'); grid on; xlim([0 3]); ylim([-1.5 1.5])
sgtitle('ECG Denoising Pipeline - Time Domain Analysis', 'FontSize', 14, 'FontWeight', 'bold')


% Final vs Clean overlay 
figure();
plot(t_clean, ecg_final, 'g-', 'LineWidth', 1.5, 'DisplayName', 'Filtered')
hold on
plot(t_clean, ecg_normal, 'b--', 'LineWidth', 1.2, 'DisplayName', 'Clean Reference')
hold off
title(sprintf('Final Result vs Reference (MSE = %.4f)', MSE_final), 'FontSize', 12, 'FontWeight', 'bold')
xlabel('Time (s)'); ylabel('Amplitude');
legend();
grid on; xlim([0 3]); ylim([-1.5 1.5])


%% FREQUENCY DOMAIN Analysis

% Compute FFTs
N_ecg = length(ecg_normal);
df = fs / N_ecg;
freq_bins = (0:N_ecg/2-1) * df;

y_clean = fft(ecg_normal);
y_noisy = fft(ecg_noisy);
y_stage1 = fft(ecg_stage1);
y_stage2 = fft(ecg_final);
y_final = fft(ecg_final);

mag_clean = abs(y_clean(1:N_ecg/2)) / N_ecg;
mag_noisy = abs(y_noisy(1:N_ecg/2)) / N_ecg;
mag_stage1 = abs(y_stage1(1:N_ecg/2)) / N_ecg;
mag_stage2 = abs(y_stage2(1:N_ecg/2)) / N_ecg;
mag_final = abs(y_final(1:N_ecg/2)) / N_ecg;

figure();

% Clean spectrum
subplot(3,2,1)
plot(freq_bins, mag_clean, 'b-', 'LineWidth', 1.5)
title('Clean ECG Spectrum', 'FontSize', 11)
ylabel('Magnitude'); grid on; xlim([0 30]); ylim([0 max(mag_clean)*1.2])
xline(0.5, 'g--', 'LineWidth', 1.5, 'Label', 'HPF cutoff')
xline(40, 'r--', 'LineWidth', 1.5, 'Label', 'LPF cutoff')
xline(50, 'm--', 'LineWidth', 1.5, 'Label', 'Notch')

% Noisy spectrum
subplot(3,2,2)
plot(freq_bins, mag_noisy, 'r-', 'LineWidth', 1.5)
title(sprintf('Noisy ECG Spectrum (SNR = %.2f dB)', SNR_initial), 'FontSize', 11)
ylabel('Magnitude'); grid on; xlim([0 30]); ylim([0 max(mag_noisy)*1.2])
xline(50, 'm--', 'LineWidth', 1.5, 'Label', '50 Hz spike')

% After Stage 1 (HPF)
subplot(3,2,3)
plot(freq_bins, mag_stage1, 'g-', 'LineWidth', 1.5)
hold on
plot(freq_bins, mag_clean, 'b--', 'LineWidth', 1)
hold off
title(sprintf('After HPF (%.1f Hz) - Baseline Removed', cutoff_HP), 'FontSize', 11)
ylabel('Magnitude'); grid on; xlim([0 30])
legend('Filtered', 'Clean', 'Location', 'best')

% After Stage 2 (Notch)
subplot(3,2,4)
plot(freq_bins, mag_stage2, 'm-', 'LineWidth', 1.5)
hold on
plot(freq_bins, mag_clean, 'b--', 'LineWidth', 1)
hold off
title(sprintf('After Notch (%d Hz) - Power Line Removed', notch_freq), 'FontSize', 11)
ylabel('Magnitude'); grid on; xlim([0 30])
legend('Filtered', 'Clean', 'Location', 'best')

% After Stage 3 (LPF)
subplot(3,2,5)
plot(freq_bins, mag_final, 'c-', 'LineWidth', 1.5)
hold on
plot(freq_bins, mag_clean, 'b--', 'LineWidth', 1)
hold off
title(sprintf('After LPF (%d Hz) - Muscle Noise Removed', cutoff_lp), 'FontSize', 11)
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on; xlim([0 30])
legend('Filtered', 'Clean', 'Location', 'best')

% Comparison: All stages
subplot(3,2,6)
plot(freq_bins, mag_noisy, 'r-', 'LineWidth', 1, 'DisplayName', 'Noisy')
hold on
plot(freq_bins, mag_final, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Final')
plot(freq_bins, mag_clean, 'b--', 'LineWidth', 1.2, 'DisplayName', 'Clean')
hold off
title('Frequency Domain: Before vs After', 'FontSize', 11, 'FontWeight', 'bold')
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on; xlim([0 30])
legend('Location', 'best')

sgtitle('ECG Denoising Pipeline - Frequency Domain Analysis', 'FontSize', 14, 'FontWeight', 'bold')