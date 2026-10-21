# Neuromuscular-Signal-Processing-Study
34-participant human subjects study using sEMG sensors and Arduino to quantify grip strength and reaction time under cognitive load. 

%
% OVERVIEW
% This repository contains the code and methodology for analyzing how dual
% task cognitive load affects auditory reaction time, grip strength, and
% forearm muscle activation in young adults. The primary experiment
% compares single task performance (dynamometer squeezes) against dual
% task performance (dynamometer squeezes while taking the Stroop Color
% Word Test).

% AUTHORS
% Team: The Flow State
% Georgia Institute of Technology, BMED 3110, Section A04
% * Eva Beresin
% * Grace Boerner
% * Joshua McNulty
% * Alexandra Yuan

% FILE DESCRIPTIONS
% AudioFile1.m
% This MATLAB script controls the auditory cues for the experiment and
% calculates hardware latency. It interfaces with the BMED3110ECGEMG
% class to start the automated experiment. The script generates specific
% frequencies (1000 Hz to start squeezing, 500 Hz to stop) at precise
% timestamps and records the first beep to measure the exact delay
% between the programmed start and the actual microphone detection.

% HARDWARE AND EQUIPMENT
% * Handgrip dynamometer
% * Three surface electromyography (sEMG) electrodes including a grounding
%   lead
% * BMED 3110 BioAmp 24 microcontroller with alligator clips
% * Two laptops (one for microcontroller connectivity and audio, one for
%   the Stroop test)

% SETUP AND EXECUTION
% 1. Connect the handgrip dynamometer and sEMG electrodes to the BioAmp 24
%    microcontroller.
% 2. Place the sEMG electrodes over the flexor digitorum superficialis of
%    the dominant arm.
% 3. Open MATLAB and ensure the BMED3110ECGEMG toolbox is installed and
%    correctly named in the script.
% 4. Run AudioFile1.m.
% 5. Ensure the room is quiet. The script will pause for 3 seconds before
%    starting the acquisition.
% 6. The script will calculate the hardware latency using the microphone,
%    then continue playing the 60 second audio protocol in the background.
