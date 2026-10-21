% Audio Hardware Latency Calibration Script
% Measures the delay between software command and physical sound output

fs = 44100; 
beep_duration = 0.1; % Short 100ms beep

% 1. Create the beep
t = (0:1/fs:beep_duration)';
beep_wave = sin(2*pi*1000*t) .* hann(length(t));
player = audioplayer(beep_wave, fs);

% 2. Setup the microphone (1 channel, standard sample rate)
recObj = audiorecorder(fs, 16, 1);

disp('Ensure volume is up and the room is quiet.');
disp('Starting calibration in 3 seconds...');
pause(3);

% 3. Start recording background noise
disp('Listening...');
record(recObj);
pause(1); % Give the mic 1 second to fully initialize and stabilize

% =========================================================================
% THE CRITICAL MEASUREMENT WINDOW
% =========================================================================
% Mark the exact sample the microphone is currently on
start_sample = recObj.CurrentSample; 

% Instantly send the command to play the audio
play(player); 
% =========================================================================

% Wait for the sound to play and be recorded, then stop
pause(0.5); 
stop(recObj);
disp('Processing data...');

% 4. Analyze the recorded data
audio_data = getaudiodata(recObj);

% Isolate only the audio recorded AFTER the play command was sent
search_data = audio_data(start_sample:end);

% Find the first moment the sound crosses 50% of its maximum volume
threshold = max(abs(search_data)) * 0.5; 

% max() on a logical array returns the index of the first 'true' value
[~, relative_trigger_idx] = max(abs(search_data) > threshold);

% 5. Calculate the delay
% Convert the sample delay into milliseconds
delay_ms = (relative_trigger_idx / fs) * 1000;

disp(' ');
disp(['--> Estimated Hardware Delay: ', num2str(delay_ms, '%.1f'), ' milliseconds']);
disp(' ');

% 6. Plot the results for visual confirmation
figure;
time_axis_ms = (0:length(search_data)-1) / fs * 1000; 
plot(time_axis_ms, search_data, 'Color', [0 0.4470 0.7410]);
hold on;
xline(delay_ms, 'r', 'Sound Detected', 'LineWidth', 2, 'LabelOrientation', 'horizontal');
title(['System Audio Latency: ', num2str(delay_ms, '%.1f'), ' ms']);
xlabel('Time after code execution (ms)');
ylabel('Microphone Amplitude');
xlim([0, delay_ms + 50]); % Zoom in on the trigger moment
grid on;