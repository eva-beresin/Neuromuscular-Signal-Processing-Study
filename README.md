# Neuromuscular-Signal-Processing-Study
34-participant human subjects study using sEMG sensors and Arduino to quantify grip strength and reaction time under cognitive load. 

OVERVIEW

--------

This repository contains the code and methodology for analyzing how dual task cognitive load affects auditory reaction time, grip strength, and forearm muscle activation in young adults. The primary experiment compares single task performance (dynamometer squeezes) against dual task performance (dynamometer squeezes while taking the Stroop Color Word Test).



AUTHORS

-------

Team: The Flow State

Georgia Institute of Technology, BMED 3110, Section A04

- Eva Beresin

- Grace Boerner

- Joshua McNulty

- Alexandra Yuan



FILE DESCRIPTIONS

-----------------

MVC_Trial.m

This script acts as the master experiment controller for the Maximum Voluntary Contraction (MVC) baseline trial. It initializes the BMED3110ECGEMG toolbox, plays auditory cues at 2 and 5 seconds, automates the DAQ run sequence, measures the hardware latency using a background microphone, and saves the resulting ECGEMG_data to an Excel file appended with the measured delay time.



AudioFile1.m & AudioFile1_2.m

These MATLAB scripts construct mono audio timelines using specific frequencies (1000 Hz for starting, 500 Hz for stopping). They interface with the BMED3110ECGEMG class to start automated experiments, record the first beep via microphone, and measure the exact hardware latency between the programmed start and actual microphone detection.



AudioFile2.m

This script generates a stereo (2-column) audio timeline. Channel 1 delivers variable pitch audio (1000 Hz to start, 500 Hz to stop) to the human subject, while Channel 2 simultaneously outputs a constant 1000 Hz trigger signal for the DAQ system.



CalibrationCode.m

A dedicated script for measuring audio hardware latency. It generates a short 100ms beep, uses a microphone to detect when the sound crosses a 50% volume threshold, calculates the exact millisecond delay, and plots a visual confirmation of the trigger moment.



Calibrationtrial1.m

A master experiment controller that runs a full 60-second audio protocol with auditory cues at 5, 8, 19, 22, 31, 34, 45, 48, 57, and 60 seconds. It handles the automated start/stop of the Arduino DAQ, calculates mic detection delay, and automatically exports the trial data to an Excel file.



Calibrationtrial2.m & Calibratedruns2.m

These scripts run a modified 60-second protocol with auditory cue timestamps at 3, 6, 16, 19, 27, 30, 39, 42, 54, and 57 seconds. Like the other master controllers, they automate the DAQ interface, compute hardware latency, and save the experimental data to your local folder.



HARDWARE AND EQUIPMENT

----------------------

- Handgrip dynamometer

- Three surface electromyography (sEMG) electrodes including a grounding lead

- BMED 3110 BioAmp 24 microcontroller with alligator clips

- Two laptops (one for microcontroller connectivity and audio, one for the Stroop test)



SETUP AND EXECUTION

-------------------

1. Connect the handgrip dynamometer and sEMG electrodes to the BioAmp 24 microcontroller.

2. Place the sEMG electrodes over the flexor digitorum superficialis of the dominant arm.

3. Open MATLAB and ensure the BMED3110ECGEMG toolbox is installed.

4. For standard trials, run the desired master controller script (e.g., MVC_Trial.m or Calibrationtrial1.m).

5. Ensure the room is quiet. The script will pause to calculate hardware latency using the microphone, then continue playing the background audio protocol.

6. The scripts will automatically control the DAQ GUI, wait for the protocol to finish, and export your data as an Excel file.
