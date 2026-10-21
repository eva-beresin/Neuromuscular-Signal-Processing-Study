% =========================================================================
% MASTER EXPERIMENT CONTROLLER
% =========================================================================

% 1. INITIALIZE THE TEACHER'S TOOLBOX
myDaq = BMED3110ECGEMG();

% 2. BUILD THE AUDIO PROTOCOL
timestamps_sec = [2, 5]; 
frequencies_hz = [1000, 500]; 
fs = 44100;           
beep_duration = 1.0;  

total_duration = max(timestamps_sec) + beep_duration + 1.5; 
audio_timeline = zeros(round(total_duration * fs), 1);

for i = 1:length(timestamps_sec)
    t_beep = (0:1/fs:beep_duration)';
    beep_wave = sin(2*pi * frequencies_hz(i) * t_beep) .* hann(length(t_beep)); 
    start_sample = round(timestamps_sec(i) * fs) + 1; 
    end_sample = start_sample + length(beep_wave) - 1;
    audio_timeline(start_sample:end_sample) = audio_timeline(start_sample:end_sample) + beep_wave;
end

if max(abs(audio_timeline)) > 1
    audio_timeline = audio_timeline / max(abs(audio_timeline));
end

player = audioplayer(audio_timeline, fs);
recObj = audiorecorder(fs, 16, 1);

% =========================================================================
% AUTOMATED START SEQUENCE
% =========================================================================
disp('Connecting to Arduino...');
% This pushes "Get Ports" FIRST, so the delay doesn't ruin our audio timing
myDaq.AutomateGetPorts(); 
pause(1.5); % Give the hardware a moment to stabilize

disp('Ensure volume is up. Room should be relatively quiet.');
disp('Starting background microphone recording...');
record(recObj);
pause(1); 

mic_start_sample = max(1, recObj.CurrentSample); 

disp('Firing audio timeline...');
play(player); 

disp('Starting live DAQ plot...');
% This pushes "Run" exactly as the audio timeline begins
myDaq.AutomateRunButton(); 

% =========================================================================
% HOLD 1: WAIT FOR THE FIRST BEEP (YIELDING TO GUI)
% =========================================================================
first_target_sec = timestamps_sec(1);
wait_for_beep = first_target_sec + beep_duration + 0.5;

disp(['Waiting ', num2str(wait_for_beep), ' seconds to capture first beep...']);

% We use a while loop with a 0.1s pause so the live plot can breathe and update
timer1 = tic;
while toc(timer1) < wait_for_beep
    pause(0.1); 
end

% Stop the mic now that we have the first beep
stop(recObj);
disp('First beep recorded. Processing delay while live plot continues...');

% --- PROCESS DELAY ---
audio_data = getaudiodata(recObj);
search_data = audio_data(mic_start_sample:end);
samples_to_check = min(length(search_data), 10 * fs);
first_window = search_data(1:samples_to_check);

threshold = max(abs(first_window)) * 0.2; 
[~, relative_trigger_idx] = max(abs(first_window) > threshold);

measured_time_sec = relative_trigger_idx / fs;
delay_ms = (measured_time_sec - first_target_sec) * 1000;

disp('--------------------------------------------------');
disp(['HARDWARE LATENCY (Delay): ', num2str(delay_ms, '%.1f'), ' ms']);
disp('--------------------------------------------------');

% =========================================================================
% HOLD 2: WAIT FOR THE REST OF THE PROTOCOL
% =========================================================================
remaining_time = total_duration - wait_for_beep;

if remaining_time > 0
    disp(['Waiting ', num2str(remaining_time), ' seconds for the protocol to finish...']);
    timer2 = tic;
    while toc(timer2) < remaining_time
        pause(0.1); % Keep yielding so the plot updates until the end!
    end
end

% =========================================================================
% AUTOMATED STOP SEQUENCE
% =========================================================================
% =========================================================================
% AUTOMATED STOP SEQUENCE
% =========================================================================
disp('Audio protocol complete. Stopping DAQ...');

% Push the Run button one more time to toggle it to "Stop"
myDaq.AutomateRunButton(); 

% Give the toolbox 2 seconds to trim the data and export it to the workspace
pause(2); 

% =========================================================================
% SAVE DATA TO EXCEL
% =========================================================================
disp('Saving data to Excel...');

% 1. Create a dynamic filename that includes the measured delay
% Example output: 'Squeeze_Data_Delay_45.2ms.xlsx'
filename = sprintf('zSqueeze_Data_Delay_%.1fms.xlsx', delay_ms);

% 2. Check if the teacher's code successfully output the data
if exist('ECGEMG_data', 'var')
    % Write the table directly to an Excel file in your current folder
    writetable(ECGEMG_data, filename);
    disp(['Success! Data saved to your current folder as: ', filename]);
else
    disp('Warning: Could not find "ECGEMG_data" in the workspace.');
    disp('If you changed the "Dataset Identifier" in the UI, you will need to save manually.');
end

disp('Experiment fully complete. Great job!');