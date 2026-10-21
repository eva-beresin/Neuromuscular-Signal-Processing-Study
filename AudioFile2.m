% 1. Define your exact timestamps (in seconds)
timestamps_sec = [2, 5]; 

% 2. Define the exact pitch for each timestamp (in Hz)
% 1000 Hz is a high pitch and indicates start squeezing
% 500 Hz is noticeably lower pitched and indicates to stop squeezing.
% NOTE: This array MUST be the exact same length as timestamps_sec!
frequencies_hz = [1000, 500]; 

fs = 44100;           % Standard audio sample rate
beep_duration = 1.0;  % Duration of each beep in seconds

% Determine the total length of the required audio array
total_duration = max(timestamps_sec) + beep_duration + 0.5; 

% Initialize a completely silent 2-COLUMN array (Stereo)
% Column 1 = Left Ear (Subject), Column 2 = Right Ear (DAQ Trigger)
audio_timeline = zeros(round(total_duration * fs), 2);

% Loop through each timestamp and build the specific sounds
for i = 1:length(timestamps_sec)
    
    % --- BUILD THE SUBJECT'S BEEP (Variable Pitch) ---
    t_beep = (0:1/fs:beep_duration)';
    
    % Use the specific frequency for this current timestamp
    subject_wave = sin(2*pi * frequencies_hz(i) * t_beep); 
    subject_wave = subject_wave .* hann(length(subject_wave)); % Prevent clicking
    
    % --- BUILD THE DAQ TRIGGER (Constant Pitch) ---
    % We keep the trigger a uniform 1000 Hz so your data is easy to process later
    trigger_wave = sin(2*pi * 1000 * t_beep);
    trigger_wave = trigger_wave .* hann(length(trigger_wave));
    
    % Calculate exact start and end sample numbers
    start_sample = round(timestamps_sec(i) * fs) + 1; 
    end_sample = start_sample + length(subject_wave) - 1;
    
    % INSERT INTO CHANNEL 1: The subject hears the custom pitch
    audio_timeline(start_sample:end_sample, 1) = audio_timeline(start_sample:end_sample, 1) + subject_wave;
    
    % INSERT INTO CHANNEL 2: The DAQ records the standard trigger
    audio_timeline(start_sample:end_sample, 2) = audio_timeline(start_sample:end_sample, 2) + trigger_wave;
end

% Ensure the audio signal doesn't exceed the [-1, 1] range
if max(max(abs(audio_timeline))) > 1
    audio_timeline = audio_timeline / max(max(abs(audio_timeline)));
end

% Play the constructed stereo timeline
disp('Playing stereo audio timeline...');
player = audioplayer(audio_timeline, fs);
playblocking(player); 
disp('Playback complete.');