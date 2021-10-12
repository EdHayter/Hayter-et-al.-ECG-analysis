%{
Run this file to load in example data, extract ECG parameters and
produce a summary plot.
main outputs: 
mIBI : RR interval
params : PR interval, P width, PR seg, QRS, QT
mBeatWf : average sweep waveforms
%}
species = 'human'; %Change this to 'mouse' from 'human' to view mouse summary

load([species '_example_data'])
[DN, mIBI, sdIBI, params, mBeatWf, Criteria, Quality, Diagnostic,points]=processECGexp_v2(data, ts,species);
figure
subplot(3,3,[1 4 7])
plot(DN,mIBI),hold on, plot(DN,params)
legend('RR','PRint','Pw','PRseg','QRS','QT')
title('ECG parameters'), xlabel('Time (min)'), ylabel('duration (s)')
use = randi(length(data)/1e4,[6,1]); %select sweeps at random for example 
x = (1:size(mBeatWf,2))/round(1/(ts(2)-ts(1)));
if size(points,2)==8,points = points(:,[1 2 3 4 6 8]);end
wins = [2 3 5 6 8 9];
for i = 1:6
subplot(3,3,wins(i))
plot(x,mBeatWf(use(i),:))
hold on
scatter(x(points(use(i),:)),mBeatWf(use(i),points(use(i),:)))
end
xlabel('Time(s)')
subplot(3,3,2)
title('Example sweeps + feature detection')