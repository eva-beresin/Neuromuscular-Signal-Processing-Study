
% 1. INITIALIZE THE TEACHER'S TOOLBOX
% -> CHANGE 'TeacherToolboxName' to the actual name of your teacher's class
myDaq = BMED3110ECGEMG();

% 1. Define your exact timestamps (in seconds)
timestamps_sec = [5, 8, 19, 22, 31, 34, 45, 48, 57, 60]; 

% 2. Define the exact pitch for each timestamp (in Hz)
% 1000 Hz is a high pitch and indicates start squeezing
% 500 Hz is noticeably lower pitched and indicates to stop squeezing.
frequencies_hz = [1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000, 500]; 

fs = 44100;           % Standard audio sample rate
beep_duration = 1.0;  % Duration of each beep in seconds

% Determine the total length of the required audio array
total_duration = max(timestamps_sec) + beep_duration + 0.5; 

% Initialize a completely silent 1-COLUMN array (Mono)
audio_timeline = zeros(round(total_duration * fs), 1);

% Loop through each timestamp and build the specific sounds
for i = 1:length(timestamps_sec)
    
    % --- BUILD THE BEEP ---
    t_beep = (0:1/fs:beep_duration)';
    
    % Use the specific frequency for this current timestamp
    beep_wave = sin(2*pi * frequencies_hz(i) * t_beep); 
    beep_wave = beep_wave .* hann(length(beep_wave)); % Prevent clicking
    
    % Calculate exact start and end sample numbers
    start_sample = round(timestamps_sec(i) * fs) + 1; 
    end_sample = start_sample + length(beep_wave) - 1;
    
    % INSERT INTO MONO CHANNEL
    audio_timeline(start_sample:end_sample) = audio_timeline(start_sample:end_sample) + beep_wave;
end

% Ensure the audio signal doesn't exceed the [-1, 1] range
if max(abs(audio_timeline)) > 1
    audio_timeline = audio_timeline / max(abs(audio_timeline));
end

% Create the player object
player = audioplayer(audio_timeline, fs);

% =========================================================================
% CALIBRATION & PLAYBACK
% =========================================================================
recObj = audiorecorder(fs, 16, 1);

disp('Ensure volume is up. Room should be relatively quiet.');
disp('Starting protocol in 3 seconds...');
pause(3);

%Starting the acquisition
disp('starting acquisition and listening for first beep');

myDaq.StartAutomatedExperiment();
pause(1);
%disp('Listening for the first beep to calculate hardware latency...');
record(recObj);
pause(1); % Give mic time to initialize

% Mark the mic sample right before firing the audio
mic_start_sample = recObj.CurrentSample; 
if mic_start_sample <= 0
    mic_start_sample = 1;
end

% START THE AUDIO
play(player); % Asynchronous play (runs in background)

% Keep recording just long enough to capture the very first beep
first_target_sec = timestamps_sec(1);
pause(first_target_sec + beep_duration + 0.5); 

% Stop the mic (The rest of the beeps will keep playing normally!)
stop(recObj);
disp('First beep recorded. Processing delay...');

% --- PROCESS DELAY ---
audio_data = getaudiodata(recObj);
search_data = audio_data(mic_start_sample:end);

% Find the first moment the sound crosses a 20% volume threshold
threshold = max(abs(search_data)) * 0.2; 
[~, relative_trigger_idx] = max(abs(search_data) > threshold);

% The exact time the mic actually heard the sound
measured_time_sec = relative_trigger_idx / fs;

% The delay is the difference between actual time and the programmed time
delay_ms = (measured_time_sec - first_target_sec) * 1000;

disp('--------------------------------------------------');
disp(['Programmed start for Beep 1: ', num2str(first_target_sec), ' s']);
disp(['Actual mic detection time:   ', num2str(measured_time_sec, '%.4f'), ' s']);
disp(['HARDWARE LATENCY (Delay):    ', num2str(delay_ms, '%.1f'), ' ms']);
disp('--------------------------------------------------');

% Wait for the rest of the 60-second protocol to finish playing
remaining_time = total_duration - (first_target_sec + beep_duration + 0.5);
if remaining_time > 0
    disp('Protocol audio is continuing in the background...');
    pause(remaining_time);
end

disp('Squeeze protocol complete.');