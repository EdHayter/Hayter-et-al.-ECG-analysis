function idx=checkcriteria(Criteria,Quality,mIBI,sdIBI,Params)
% find traces that fit within quality criteria
%INPUTS
%Criteria = list of allowed values for the various parameters [min max]
    %1=Quality
    %2=mean IBI
    %3=sd IBI
    %4=PR
    %5=QRS
    %6=QT
%Quality - quality values
%mIBI - mean interbeat interval
%sdIBI - s.d. of the ibi.
%Params - ECG waveform components

Qrng=Criteria(:,1);
mIBIrng=Criteria(:,2);
sdIBIrng=Criteria(:,3);
PRrng=Criteria(:,4);
QRSrng=Criteria(:,5);
QTrng=Criteria(:,6);
PR=Params(:,1);
QRS=Params(:,3);
QT=Params(:,5);


if max(Qrng)>-1
    idx1=Quality(:,5)>=Qrng(1) & Quality(:,5)<=Qrng(2);
else
    idx1=ones(size(Quality,1),1);
end
if max(mIBIrng)>-1
    idx2=mIBI>=mIBIrng(1) & mIBI<=mIBIrng(2);
else
    idx2=ones(size(Quality,1),1);
end
if max(sdIBIrng)>-1
    idx3=sdIBI>=sdIBIrng(1) & sdIBI<=sdIBIrng(2);
else
    idx3=ones(size(Quality,1),1);
end
if max(PRrng)>-1
    idx4=PR>=PRrng(1) & PR<=PRrng(2);
else
    idx4=ones(size(Quality,1),1);
end
if max(QRSrng)>-1
    idx5=QRS>=QRSrng(1) & QRS<=QRSrng(2);
else
    idx5=ones(size(Quality,1),1);
end
if max(QTrng)>-1
    idx6=QT>=QTrng(1) & QT<=QTrng(2);
else
    idx6=ones(size(Quality,1),1);
end


idx=idx1==1&idx2==1&idx3==1&idx4==1&idx5==1&idx6==1;
