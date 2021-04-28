README

Tested on: Windows 10 x64 (Intel(R) Core(TM) i7-6700, 16GB RAM); MATLAB R2019a 

To use this example code:
1. Extract zip file to a location of your choice.
2. Navigate to the extracted folder in MATLAB
3. Run 'Run_for_summary'

This will produce a figure containing extracted ECG parameters from ~1hr of human baseline recording and 
6 randomly chosen sweeps with feature detection (p onset, p offset, q onset, r peak, s, t offset).

Run time approx. 10s

To run with your own data:
Import raw data & timestamps into MATLAB into row vectors named 'data' and 'timestamps' respectively. 
then run the following:

[DN, mIBI, sdIBI, params, mBeatWf, Criteria, Quality, Diagnostic,points]=processECGexp_v2(data, timestamps);


Sampling rate may need to be altered on line 37 of processECGexp_v2. 

Main outputs:
mIBI - mean RR interval across each sweep
sdIBI - RR interval standard deviation
params(:,1) - PR interval
params(:,2) - PR segment
params(:,3) - P width
params(:,4) - QRS duration
params(:,5) - QT interval
mBeatWf - mean ECG waveforms for each sweep 
Quality - sweep quality

In order to use this code for mouse ECG, replace line 39 of processECGexp_v2 (extractbeatshuman_v2) with the following:

[mibi, sdibi, beats, Q, Diag, Oparams, t]=extractbeatsmouse(val,ts,threshold, dp,0);

The final input argument (0) can be changed to '1' to produce diagnostic plots - only use this will small amounts of data as a new plot will be produced for each 10s sweep.

You will also need to adjust Fs on line 37, and 'dp' on line 16, which selects the window around each R peak to search. [60 60] is a good place to start for 1000Hz recording.

Mouse example data.mat contains sweeps of example mouse ECG. 10s sweeps were collected every 5 minutes and stitched together. 

Finally, Quality control can be adjusted on lines 17-22. It's currently set to exclude very little for ease of use. 






