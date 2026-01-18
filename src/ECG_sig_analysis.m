%% LOAD PHYSIONET ECG DATA

load('ECGData.mat'); 

% Check the structure
fprintf('=== ECG DATA LOADED ===\n');
fprintf('Total recordings: %d\n', size(ECGData.Data, 1));
fprintf('Samples per recording: %d\n', size(ECGData.Data, 2));
fprintf('Sampling frequency: 128 Hz\n');
fprintf('Duration per recording: %.1f seconds\n', size(ECGData.Data, 2)/128);

% Check labels
unique_labels = unique(ECGData.Labels);
fprintf('\nCategories: ');
fprintf('%s ', unique_labels{:});
fprintf('\n');

%% NORMAL SINUS RHYTHM ECG

% NSR recordings (rows 127-162)
nsr_indices = find(strcmp(ECGData.Labels, 'NSR'));
fprintf('\nFound %d Normal Sinus Rhythm recordings\n', length(nsr_indices));

record_idx = nsr_indices(1);  % First NSR recording
fprintf('Selected record #%d (Label: %s)\n', record_idx, ECGData.Labels{record_idx});

% Extract the ECG signal
ecg_original = ECGData.Data(record_idx, :);  % 1x65536 vector
fs_original = 128;  % Sampling frequency

% Time vector
t_original = (0:length(ecg_original)-1) / fs_original;

% Plot of entire recording(row)
figure('Position', [100, 100, 1400, 400]);
plot(t_original, ecg_original, 'b', 'LineWidth', 1);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Amplitude (mV)', 'FontSize', 12);
title(sprintf('Full ECG Recording - Record #%d (%s)', record_idx, ECGData.Labels{record_idx}), 'FontSize', 14);
grid on;
xlim([0 10]);  % First 10 seconds

ecg_sample = ecg_original(10000 : 10000+ fs_original*10 ); % 10s sample : 10,000 -> 11280 

%% Resampling 128Hz signal to 250Hz
fs = 500 ; % Final Sampling Frequency
ecg_clean = resample(ecg_sample , fs , 128);
t_clean = (0:length(ecg_clean)-1)/fs;

%% Normalizing the clean ecg sample
a=-1; b=1;
ecg_normal = rescale(ecg_clean , a , b);

figure('Position', [100, 100, 1400, 400]);
plot(t_clean, ecg_normal, 'b', 'LineWidth', 1);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Amplitude (mV)', 'FontSize', 12);
title('Clean ECG Recording (NOrmalized)', 'FontSize', 14);
grid on;
xlim([0 5]);

save("ecg.mat","ecg_normal","ecg_clean","t_clean","fs");