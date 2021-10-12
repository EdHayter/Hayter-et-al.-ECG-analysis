function [mibi, sdibi, beats, Q, Diag, Oparams, t]=extractbeatsmouse(val,ts,threshold, dp,plt)
%process a 10s ECG sweep to extract beats and basic parameters
%produces plots for diagnostic purposes!
%INPUTS:
%val - the 10s sweep 
%ts - the corresponding timestamps
%threshold - [minimal maximal] detectable beat amplitude
%dp - number of dp around peak to save

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
p=[];
maxamp=threshold(2);
threshold=threshold(1);
ts(1)=0;
if isempty(val)==1
    ts=[];
end
k=ones(500,1)./500;
vs=convn(val,k);
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
    figure; subplot(1,2,1)
    plot(ts,val); %raw
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
  if plt  scatter(bt, ones(1,length(bt))./4,'g'); end%valid beats
else
  %if plt  close,clear h, end
end
    
ibis=diff(bt);%find interbeat intervals
idx=ibis<median(ibis)*1.8; %skipped beats;
Diag(5)=sum(idx); %valid intervals
if sum(idx)>33 % at least 200 bpm
    a=find(idx==1);
    bti(2:2:length(a)*2)=bt(a+1);
    bti(1:2:end)=bt(a);
    bta=ones(1,length(bti))/4;
    bta(1:2:end)=bta(1:2:end)+0.1;
    bta(2:2:end)=bta(1:2:end)-0.1;
 if plt,   plot(bti,bta,'g');end
    mibi=mean(ibis(idx));
    sdibi = nanstd(ibis(idx));
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
    Q(4)=Q(4)*0.5;
    Q(5)=mean(Q(1:4));
    bt=bt(f);
    for ctr=2:length(f)-1
        btprev=find(ts==bt(ctr-1),1);
        btcurr=find(ts==bt(ctr),1);
        btnxt=find(ts==bt(ctr+1),1);
        tctr=btcurr;
        while tctr>btprev && val(tctr)>val(tctr-1)
            tctr=tctr-1;
        end
        qcurr=tctr;
        pcurr=find(val(btprev+20:qcurr)==max(val(btprev+20:qcurr)),1,'last')+btprev+19;

        tctr = pcurr-1;
        while val(tctr-1)<val(tctr)
            tctr=tctr-1;
        end
        pon = tctr;
        tctr = pcurr+1;
        while val(tctr+1)<val(tctr)
            tctr=tctr+1;
        end
        poff = tctr;
        %
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
        pnxt=find(val(jcurr+10:btnxt-10)==max(val(jcurr+10:btnxt-10)),1,'last')+jcurr+9;

        iso = median(val(pcurr:pnxt));
        tctr = find(val(jcurr:pnxt) == min(val(jcurr:pnxt))) + jcurr;
        if length(tctr)>1, tctr=tctr(1); end
        if val(tctr) > iso
            toff = nan;
        else
            try
            while val(tctr) < iso && tctr < 10000
                tctr=tctr+1;
            end
            toff = tctr;
            if toff > pnxt
                toff = nan;
            end
            catch
                toff=nan;
                pnxt=nan;
            end
        end
        
        
        vals=[pon,poff,qcurr,btcurr,scurr,jcurr,toff,pnxt];
        if plt,     scatter(ts(vals(~isnan(vals))),val(vals(~isnan(vals))),'m'); end
        ts(10001)=nan;
        vals(isnan(vals))=10001;
        params(:,ctr-1)=ts(vals);
        valtt(ctr,:) = vals;
    end

    Oparams(1) = median(params(3,:) - params(1,:)); %pr interval
    Oparams(2) = median(params(3,:) - params(2,:)); % pr segment
    Oparams(3) = median(params(2,:) - params(1,:)); %p width
    Oparams(4) = median(params(5,:) - params(3,:)); %qrs
    Oparams(5) = median(params(7,:) - params(3,:),'omitnan'); %QT
    t = (params-params(4,:))*1/nanmedian(diff(ts)); %Fs (just for plotting)
    t = round(nanmedian(t,2)+dp(1)+1);
    t=t(1:end-1);
    if plt
        subplot(1,2,2), plot(beatwf), hold on
        scatter(t,beatwf(t))
    end

else
    mibi=[];
    sdibi=[];
    beatwf=[];
    Q=[];
    Diag=[];
    Oparams=[];
end

