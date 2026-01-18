%% STAGE 4: Polynomial baseline fitting (Remove Electrode Noise / Baseline offset)
t_poly = t_clean(1 : round(0.2*fs): end);
ecg_poly = ecg_noisy(1 : round(0.2*fs) : end);
poly_order = 2;
pol = polyfit(t_poly , ecg_poly, poly_order);
pol_check = polyval(pol , t_clean);

figure();
plot(t_clean , pol_check , "-b"); hold on
plot(t_clean , ecg_normal , "--g" ); hold off
xlabel("Time"); ylabel("Amplitude");
ylim([-1 1]) ; xlim([0 5]);
title("Evaluating the polynomial curve fitting");
legend("Polynomial Curve", "Original ECG");
grid on;

ecg_final = ecg_stage3 - pol_check;

MSE_final = mean((ecg_final - ecg_normal).^2);
SNR_final = 10*log10(var(ecg_normal) / var(ecg_final - ecg_normal));

fprintf('\n=== STAGE 4: POLYNOMIAL BASELINE OFFSET CORRECTION ===\n');
fprintf('Polynomial order : %d Hz\n', poly_order);
fprintf('Removes: Electrode Basline offset\n');
fprintf('MSE: %.4f\n', MSE_final);
fprintf('SNR: %.2f dB (Improvement: %.2f dB)\n', SNR_final, SNR_final - SNR_stage3);