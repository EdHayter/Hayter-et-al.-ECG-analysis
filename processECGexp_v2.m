function [DN, mIBI, sdIBI, params, mBeatWf, Criteria, Quality, Diagnostic,points]=processECGexp_v2(data, timestamps, species)
%{
process a series of 10s ECG sweep data to extract beats and basic parameters
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
%}
msg=[];
if strcmp(species, 'mouse')
    dp = [60 60]; %datapoints for wf
    Fs = 1000;
elseif strcmp(species,'human')
    dp = [80 120];
    Fs = 256; 
else
    error('Please specify ''mouse'' or ''human''.')
end

Criteria(:,1)=[0.66 1]; %quality threshold
Criteria(:,2)=[-1 -1]; %mean interbeat interval ('RR')
Criteria(:,3)=[-1 -1]; %SD interbeat interval
Criteria(:,4)=[-1 -1]; %PR
Criteria(:,5)=[-1 -1]; %QRS
Criteria(:,6)=[-1 -1]; %QT
DN=[];
mIBI=[];
sdIBI=[];
mBeatWf=[];
Quality=[];
Diagnostic=[];
params=[];
c=0;
data = data(:)';

for sctr=1:length(data)/10000
    try
        temporary_ts = timestamps((sctr-1)*10000+1:sctr*10000)';
        dn = temporary_ts(1);
        val = data((sctr-1)*10000+1:sctr*10000)';
        ts = (1:10000)'/Fs;
        threshold = [prctile(val,98),5];
        if strcmp(species, 'mouse')
            [mibi, sdibi, beats, Q, Diag, Oparams, t]=extractbeatsmouse(val,ts,threshold, dp,0);
        else
            [mibi, sdibi, beats, Q, Diag, Oparams, ~, ~, ~,t]=extractbeatshuman_v2(val,ts,threshold, dp,0);
        end
        if isempty(mibi)==0
            DN(sctr) = dn;
            mIBI(sctr)=mibi;
            sdIBI(sctr)=sdibi;
            mBeatWf(sctr,:)=mean(beats);
            Quality(sctr,:)=Q;
            Diagnostic(sctr,:)=Diag;
            params(sctr,:)=Oparams;
            points(sctr,:)=t;
        else
            DN(sctr) = nan;
            mIBI(sctr)=nan;
            sdIBI(sctr)=nan;
            mBeatWf(sctr,:)=nan;
            Quality(sctr,:)=nan;
            Diagnostic(sctr,:)=nan;
            params(sctr,:)=nan;
            points(sctr,:)=nan;
        end
    catch
            c = c+1;
    end
    if sctr ~=1, fprintf(repmat('\b',1,numel(msg))); end
    msg = ['Sample: ',num2str(sctr),' of ',num2str(length(data)/10000),' complete.'];
    fprintf(msg);
    
end

fprintf('\n %i Files skipped. \n',sum(isnan(mIBI)))

idx=checkcriteria(Criteria,Quality,mIBI,sdIBI,params);

end


