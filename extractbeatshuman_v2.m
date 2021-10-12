function [mibi, sdibi, beats, Q, Diag, Oparams, bt, params, intervals,t]=extractbeatshuman_v2(val,ts,threshold, dp,plt)
%process a 10s ECG sweep to extract beats and basic parameters
%produces plots for diagnostic purposes!

%v2 builds on reviewers comments to improve t offset
%determinations
%INPUTS:
%val - the 10s sweep 
%ts - the corresponding timestamps
%threshold - [minimal maximal] detectable beat amplitude
%dp - number of dp around peak to save
%plt - logical whether to plot or not

%OUTPUTS
%mibi - mean interbeat interval
%sdibi - s.d. of the ibi.
%beats - waveforms of valid beats
%Q - quality control values
%Diag - diagnostic values
%Oparams - ECG components

i=dp(1)+1;
beats=[];
bt=[];
maxamp=threshold(2);
threshold=threshold(1);
ts(end+1)=nan;
if isempty(val)==1
    ts=[];
end
k=ones(500,1)./500;
vs=convn(val,k');
vv=max(max(vs));
vd=min(min(vs));
Diag(1)=vv; %wobble up
Diag(2)=vd; %wobble down


while i<length(val)-dp(2)
    while val(i)<threshold && i<length(val)-dp(2)
        i=i+1;
    end
    if i<length(val)-dp(2) %beat detected
        while val(i)<val(i+1) && i<length(val)-dp(2)
            i=i+1;
        end
        if val(i)>val(i-1) %valid peak detected
           b=val(i-dp(1):i+dp(2)); %beat wavform
           pp=find(b==max(b),1);
           if pp==dp(1)+1
            beats=cat(2,beats,b); %save beat waveform
            bt=cat(1,bt,ts(i)); %save beat ts
           end
        end
    end
    i=i+1;
end
if plt
    close
    figure, subplot(1,2,1)
    plot(ts(1:end-1),val); %raw
    hold on; 
end
if isempty(beats)==0 %check for and remove obvious noise    
if plt,     scatter(bt, ones(1,length(bt))./4,'r'); end%detected beats
    bwf=beats'./(max(abs(beats))'*ones(1,sum(dp)+1)); %normalise
    mwf=mean(bwf); %normalised mean
    bwf=bsxfun(@minus,bwf,mwf).^2; %squared deviation
    ber=mean(bwf,2); %mean sq.
    mm=max(beats);%beat maxima
    mmm=min(beats);%beat maxima
    idx=isnan(mm)==0 & mm<maxamp & mmm>-maxamp &(ber<median(ber)*7.5|ber<0.012)';%exclude noise
    Diag(3)=length(idx);%total beats
    Diag(4)=sum(idx);%valid beats 
    beats=beats(:,idx)';
    bt=bt(idx,:);
  %  ber=ber(idx);
  if plt,  scatter(bt, ones(1,length(bt))./4,'g'); end%valid beats
else
 % if plt  close(h),clear h, end
end
    
ibis=diff(bt);%find interbeat intervals
idx=ibis<median(ibis)*1.8; %skipped beats;
Diag(5)=sum(idx); %valid intervals
if sum(idx)>20 % at least 30 bpm (excl. invalid beats)
    a=find(idx==1);
    bti(2:2:length(a)*2)=bt(a+1);
    bti(1:2:end)=bt(a);
    bta=ones(1,length(bti))/4;
    bta(1:2:end)=bta(1:2:end)+0.1;
    bta(2:2:end)=bta(1:2:end)-0.1;
 if plt,   plot(bti,bta,'g');end
    mibi=mean(ibis(idx));
    sdibi=std(ibis(idx));
    f(2:sum(idx)+1)=find(idx==1)+1;
    f(1)=f(2)-1;
    beatwf=mean(beats(f,:));
    Diag(6)=max(beatwf);%max amp
    Diag(7)=-min(beatwf);%min amp
    Q(1)=(Diag(5)+1)/Diag(3); %valid intervals
    Q(2)=1-(Diag(1)/threshold); %wobble
    Q(3)=Diag(6)/(threshold*5); %SNR
    Q(4)=Diag(6)/(Diag(7)*3); %negative spikes
    Q(Q>1)=1;
    Q(Q<0)=0;
    Q(3)=Q(3)*1.5;
    Q(5)=mean(Q(1:4));
    bt=bt(f);
   % params = zeros(9,length(f)-2);
    for ctr=2:length(f)-1
        btprev=find(ts==bt(ctr-1),1);
        btcurr=find(ts==bt(ctr),1);
        btnxt=find(ts==bt(ctr+1),1);
        tctr=btcurr;
        while tctr>btprev && val(tctr)>val(tctr-1)
            tctr=tctr-1;
        end
        while val(tctr)<val(tctr-1) 
            tctr=tctr-1;
        end
        qcurr=tctr;
        pcurr=find(val(qcurr-60:qcurr)==max(val(qcurr-60:qcurr)),1,'last')+qcurr-60;
        iso = prctile(val(pcurr:qcurr),50); %Set this on an individual basis for P onset
        if isempty(pcurr) || pcurr>qcurr, iso = median(val(qcurr-10:qcurr)); end
        pon = 0;
        poff= 0;
        tctr = pcurr-3;
        while val(tctr)>iso
            tctr=tctr-1;
            if tctr == pcurr-30
                pon = [];
                break
            end
        end
        if ~isempty(pon), pon = tctr; end
        tctr = pcurr+3;
        iso = median(val(pcurr:qcurr));
        while val(tctr)>iso
            tctr=tctr+1;
             if tctr == pcurr+30
                poff = [];
                break
            end
        end
        if ~isempty(poff), poff = tctr-1; end
        
        
        
        
        tctr=btcurr+1;
        while tctr<btnxt-1 && val(tctr)>val(tctr+1)
            tctr=tctr+1;
        end
        scurr=tctr;
        tctr=scurr+1;
        while tctr<btnxt && val(tctr)<val(tctr+1)
            tctr=tctr+1;
        end
        jcurr=tctr;
        tcurr=find(val(jcurr+10:jcurr+90)==max(val(jcurr+10:jcurr+90)),1,'last')+jcurr+9;
        
        tctr=tcurr+10;
        while val(tctr)>iso %this now goes to iso,  then next upwards deflection
            tctr=tctr+1;
            if tctr == btnxt || tctr == length(val)
                tctr = length(ts);
                break
            end
        end
        try  while val(tctr)>val(tctr+1)
                tctr=tctr+1;
                if tctr == btnxt || tctr == length(val)
                    tctr = length(ts);
                    break
                end
            end
            
        catch
            tctr = length(ts);
        end
        tend=tctr;
        
        if isempty(pon), pon=length(ts); end
        if isempty(poff), poff=length(ts); end
        if isempty(pcurr), pcurr=length(ts); end
        if isempty(qcurr), qcurr=length(ts); end
        if isempty(btcurr), btcurr=length(ts); end
        if isempty(scurr), scurr=length(ts); end
        if isempty(jcurr), jcurr=length(ts); end
        if isempty(tcurr), tcurr=length(ts); end
        if isempty(tend), tend=length(ts); end
        
        if plt
          try  plot([ts(pcurr) ts(pcurr)],[-0.5 0.9],'k')
            text(ts(pcurr),-0.5,'P','VerticalAlignment','bottom'), catch, end
        try    plot([ts(qcurr) ts(qcurr)],[-0.6 1],'k')
            text(ts(qcurr),-0.6,'Q','VerticalAlignment','bottom'), catch, end
        try    plot([ts(jcurr) ts(jcurr)],[-0.8 1.2],'k')
            text(ts(jcurr),-0.8,'J','VerticalAlignment','bottom'), catch, end
        try    plot([ts(btcurr) ts(btcurr)],[-0.7 2],'k')
            text(ts(btcurr),-0.7,'R','VerticalAlignment','bottom'), catch, end
         try   plot([ts(tcurr) ts(tcurr)],[-0.9 1.3],'k')
            text(ts(tcurr),-0.9,'T','VerticalAlignment','bottom'), catch, end
            plot([ts(btcurr-100) ts(btcurr+100)],[iso iso],'k')
        try    plot([ts(tend) ts(tend)],[-1 1.4],'k')
            text(ts(tend),-1,'Tend','VerticalAlignment','bottom'), catch, end
         try   plot([ts(pon) ts(pon)],[-.5 .5],'k')
            text(ts(pon),-.5,'Pon','VerticalAlignment','bottom'), catch, end
         try   plot([ts(poff) ts(poff)],[-.5 .5],'k')
            text(ts(poff),-.5,'Poff','VerticalAlignment','bottom'), catch, end
        end

        vals=[pon,poff,qcurr,btcurr,scurr,jcurr,tcurr,tend];
        params(:,ctr-1)=ts(vals);
    end
    Oparams(1) = nanmedian(params(3,:) - params(1,:)); %pr interval
    Oparams(2) = nanmedian(params(3,:) - params(2,:)); %pr segment
    Oparams(3) = nanmedian(params(2,:) - params(1,:)); %p width
    Oparams(4) = nanmedian(params(6,:) - params(3,:)); %qrs
    Oparams(5) = nanmedian(params(8,:) - params(3,:)); %QT
    t = (params-params(4,:))*1/nanmedian(diff(ts)); %Fs (just for plotting)
    t = round(nanmedian(t,2)+dp(1)+1);
    if plt
        subplot(1,2,2), plot(beatwf), hold on
        scatter(t,beatwf(t))
    end
 bt=bt(2:end-1);
 intervals = ibis(idx);
 intervals = intervals(2:end);
 beats = beats(idx,:);
 beats = beats(2:end,:);
else
    intervals = [];
    mibi=[];
    sdibi=[];
    bt=[];
    params=[];
    beatwf=[];
    Q=[];
    Diag=[];
    Oparams=[];
end















