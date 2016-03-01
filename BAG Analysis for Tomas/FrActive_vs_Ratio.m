% plots fraction of active worms from imaging:
% 
% figure
% pp=nansum(PauseMatrix,1)/F;
% pp=1-pp;
% pp=medfilt1(pp);
% plot([tv tv2], pp(1:end), 'linewidth',2)
% hold on
% plot ([4.63*60 4.63*60], [0 1],'g')
% ylabel('fraction animals active')
% xlabel( 'sec')
% ylim([0 1])
% title(dirname(cd))

%Cumsum:
figure
subtightplot(1,2,1)
plot(nfc'/30,CumSumN','b')
hold on
plot(nfc'/30,nanmean(CumSumN),'b','Linewidth',3)
ylim([0.5 4])
title([dirname(cd) ': ratio cumsum no CO2'])
xlabel('sec')
subtightplot(1,2,2)
plot(nfc1'/30,CumSumS','b')
hold on
plot(nfc'/30,nanmean(CumSumS),'b','Linewidth',3)
ylim([0.5 4])
title([dirname(cd) ': ratio cumsum 1% CO2'])
xlabel('sec')

% %----Cumsum Ratio Vs Activity
% 
for i=1:size(CumSumS,1)
data=CumSumS(i,:);
y=filter(ones(1,10), 10, data);
CSb(i,:)=y(10:10:end);
end

for i=1:size(CumSumS,1)
data=PauseMatrix(i,7281:end);
y=filter(ones(1,10), 10, data);
Pb(i,:)=y(10:10:end);
end
% 
for i=1:size(CumSumS,1)
data=SpeedMatrix(i,7281:end);
y=filter(ones(1,10), 10, data);
Sb(i,:)=y(10:10:end);
end


figure
subtightplot(1,2,1,0.09)
pi=find(Pb>=0.3);
gi=find(Pb<0.3);
pd=[CSb(pi); CSb(gi)];
grp = [zeros(1,length(pi)),ones(1,length(gi))];
boxplot(pd,grp,'labels',{'still','active'})
title('cumsum values prelethargus')
a=CumSumS(pi);
a=a(~isnan(a));
b=CumSumS(gi);
b=b(~isnan(b));
[p h]=ranksum(a,b)
text(1.4,3.5,num2str(p))
ylabel('cumsum ratio')

subtightplot(1,2,2,0.09)
gi=find(Sb>=0.03);
pi=find(Sb<0.03);
pd=[CSb(pi); CSb(gi)];
grp = [zeros(1,length(pi)),ones(1,length(gi))];
boxplot(pd,grp,'labels',{'still','moving'})
title('cumsum values prelethargus, speed cutoff=0.03')
a=CumSumS(pi);
a=a(~isnan(a));
b=CumSumS(gi);
b=b(~isnan(b));
[p h]=ranksum(a,b)
text(1.4,3.5,num2str(p))

