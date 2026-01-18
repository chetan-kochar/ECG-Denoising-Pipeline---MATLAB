load("ecg.mat")

% 1 -> BAseline Wander => Amplttude=0.2 freq = 0.2,0.3,0.4
% 2 -> Powerline Interference => Amplttude=0.15 freq = 50
% 3 -> Muscle artifact =>Amplttude=0.1  freq = >=40 , <=200
% 4 -> Electrode noise => Amplttude=0.07 freq = 1.5

%% Baseline Wander
noise_BLW = 0.12 * (sin(2*pi*0.2*t_clean) + sin(2*pi*0.3*t_clean) + sin(2*pi*0.4*t_clean));

%% Powerline Interference
noise_PLI = 0.08 * sin(2 * pi * 50 * t_clean);

%% Muscle artifact
noise_rand = 0.05 * randn( size(t_clean) );
[b,a] = butter( 4 , [40 200]/(fs/2) , "bandpass");
noise_MArt = filtfilt(b,a,noise_rand);

%% Electrode noise
noise_ELN = 0.04 * sin(2*pi*1.5*t_clean); % Electrode noise

%% NOise Visualization
figure
subplot(4,1,1);
plot(t_clean , noise_BLW ,"r-" ,"LineWidth",1.5);
title("Baseline Wander")
grid on
xlim([0 5]);

subplot(4,1,2);
plot(t_clean , noise_PLI ,"b-" ,"LineWidth",1.5);
title("Powerline Interference")
grid on
xlim([0 2.5]);

subplot(4,1,3);
plot(t_clean , noise_MArt ,"g-" ,"LineWidth",1.5);
title("Muscle artifact")
grid on
xlim([0 5]);

subplot(4,1,4);
plot(t_clean , noise_ELN ,"y-" ,"LineWidth",1.5);
title("Electrode noise")
grid on
xlim([0 5]);
xlabel("Time"); ylabel("Amplitude");

total_noise = noise_BLW + noise_PLI + noise_MArt + noise_ELN;

% Visualize total noise
figure
plot(t_clean, total_noise, 'b-', 'LineWidth', 1.5);
title('Total Noise');
grid on;
xlim([0 5]);
xlabel('Time'); ylabel('Amplitude');

%% Noise power and SNR
ecg_noisy = ecg_normal + total_noise;

% Calculate SNR
SNR_initial = 10*log10(var(ecg_normal) / var(total_noise));

fprintf('\n=== NOISE ANALYSIS ===\n');
fprintf('Noise Power Breakdown:\n');
fprintf('  Baseline Wander:  %.4f\n', var(noise_BLW));
fprintf('  Power Line (50Hz): %.4f\n', var(noise_PLI));
fprintf('  Muscle Artifact:   %.4f\n', var(noise_MArt));
fprintf('  Electrode Noise:   %.4f\n', var(noise_ELN));
fprintf('  Total Noise Power: %.4f\n', var(total_noise));
fprintf('\nSignal Power: %.4f\n', var(ecg_normal));
fprintf('Initial SNR: %.2f dB\n', SNR_initial);

%% Visualize CLean vs Noisy
figure('Position', [100, 100, 1400, 600]);

subplot(2,1,1)
plot(t_clean, ecg_normal, 'b-', 'LineWidth', 1.5);
title('Clean ECG (PhysioNet Data)', 'FontSize', 14);
ylabel('Amplitude'); grid on; xlim([0 3]); ylim([-1.5 1.5]);

subplot(2,1,2)
plot(t_clean, ecg_noisy, 'r-', 'LineWidth', 1);
hold on
plot(t_clean, ecg_normal, 'b--', 'LineWidth', 1);
hold off
title(sprintf('Noisy ECG (SNR = %.2f dB)', SNR_initial), 'FontSize', 14);
xlabel('Time (s)'); ylabel('Amplitude'); 
legend('Noisy', 'Clean', 'Location', 'best');
grid on; xlim([0 3]); ylim([-2 2]);

save("noise.mat","SNR_initial","total_noise","ecg_noisy","fs","ecg_normal","t_clean")