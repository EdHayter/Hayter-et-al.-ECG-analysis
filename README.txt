README

Tested on: Windows 10 x64 (Intel(R) Core(TM) i7-6700, 16GB RAM); MATLAB R2019a 

To use this example code:
1. Extract zip file to a location of your choice.
2. Navigate to the extracted folder in MATLAB
3. Run 'Run_for_summary'

This will produce a figure containing extracted ECG parameters from ~1hr of human baseline recording and 
6 randomly chosen sweeps with feature detection (p onset, p offset, q onset, r peak, s, t offset).

Run time approx. 10s

by default, Run_for_summary will show human data. 
To view mouse example data change line 9 of Run_for_summary from 'human' to 'mouse' and run again. 

To run with your own data:
Import raw data & timestamps into MATLAB into row vectors named 'data' and 'timestamps' respectively. 
create a variable species = 'mouse' or species = 'human'. 
then run the following:

[DN, mIBI, sdIBI, params, mBeatWf, Criteria, Quality, Diagnostic,points]=processECGexp_v2(data, timestamps, species);

Sampling rate 'Fs' and beat window 'dp' (the window around each R peak to search) can be adjusted in lines 17-21 of processECGexp_v2 if required. 

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

On lines 50 & 52 of processECGexp_v2, the final argument in the extractbeats___ function can be adjusted from 0 to 1 to produce diagnostic plots. 
Only use this will small amounts of data as a new plot will be produced for each 10s sweep.


Finally, Quality control can be adjusted on lines 26-31. It's currently set to exclude very little for ease of use. 






