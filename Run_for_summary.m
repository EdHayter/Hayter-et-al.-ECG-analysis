%{
Run this file to load in example data (~1hr), extract ECG parameters and
produce a summary plot.
main outputs: 
mIBI : RR interval
params : PR interval, P width, PR seg, QRS, QT
mBeatWf : average sweep waveforms
%}

load('example_data')
[DN, mIBI, sdIBI, params, mBeatWf, Criteria, Quality, Diagnostic,points]=processECGexp_v2(data, ts);
figure
subplot(3,3,[1 4 7])
plot(DN,mIBI),hold on, plot(DN,params)
legend('RR','PRint','Pw','PRseg','QRS','QT')
title('ECG parameters'), xlabel('Time (min)'), ylabel('duration (s)')
use = randi(100,[6,1]); %select sweeps at random for example 
x = (1:201)/256;
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