%peak quantification
% figure
% CuS=CumSumS(:,end-2)';
% notBoxPlot([P1 ;P2;CuS]');
% set(gca, 'xticklabel', {'abs max in window', 'mean 6 sec window', 'cumsum stimulus episode'});
% title(dirname(cd))
% ylim([2 11])


%% activity vs peak cumsum value
clear r1 p1 r2 p2 r3 p3 r4 p4
f1=figure;
cc=1;
%peak R value
for  sp=6000
    
FrA=nansum(PauseMatrix(:,sp:(sp+3000)),2)/length(PauseMatrix(1,sp:(sp+3000)));
%FrA=nansum(PauseMatrix(:,sp:end),2)/length(PauseMatrix(1,sp:end));
 [r1(cc),p1(cc)]=corr(P2',FrA);
scatter(P2,FrA)
yfit=linfit(P2,FrA);
legend(['r=' num2str(r1) ' ,p=' num2str(p1)])

cc=cc+1;
end
xlabel('peak value')
ylabel(' Active')
ylim([0 1])
title(dirname(cd))

%% cumsum
f2=figure;
cc=1;
%peak R value
for  sp=6000
 FrA=nansum(PauseMatrix(:,sp:(sp+3000)),2)/length(PauseMatrix(1,sp:(sp+3000)));
%FrA=nansum(PauseMatrix(:,sp:end),2)/length(PauseMatrix(1,sp:end));
FrA=1-FrA;
CuS=CumSumS(:,end-2);
scatter(CuS,FrA)
 [r2(cc),p2(cc)]=corr(CuS,FrA);
yfit=linfit(CuS',FrA);
legend(['r=' num2str(r2) ' ,p=' num2str(p2)])
cc=cc+1;
end
xlabel('cumsum value')
ylabel(' Active')
ylim([0 1])
title (dirname(cd))

% figure
% plot(r1)
% hold on
% plot(r2,'r')
% legend('P1','cumsum')
%%  compare pre and post stimulus:
figure
FrA1=nansum(PauseMatrix(:,1:8000),2)/length(PauseMatrix(1,1:8000));
FrA2=nansum(PauseMatrix(:,8000:end),2)/length(PauseMatrix(1,8000:end));
notBoxPlot([FrA1 FrA2])
[h p] = ttest2(FrA1,FrA2)
legend(['p=' num2str(p)])
set(gca,'xticklabel',{'pre stim', 'post stim'})
title(dirname(cd))
% 
QValues.P1=P1;
QValues.P2=P2;
QValues.CumSumR=CuS';
QValues.FrA=FrA;
save QValues QValues

%% cumsum rim:
% cc=1;
% CsRim=CumSumRIMpos(:,end-2)';
% CuS=QValues.CumSumR;
% figure
% scatter(CsRim,CuS)
% [r3(cc),p3(cc)]=corr(CuS',CsRim');
% yfit=linfit(CsRim,CuS);
% legend(['r=' num2str(r3) ' ,p=' num2str(p3)])
% ylabel('cumsum R/R0')
% xlabel(' cumsum  rim rise')


%% reversals:
% cc=1;
% for  sp=5000
%     
%     FrRev=nansum(RevMatrix(:,sp:(sp+8000)),2)/length(RevMatrix(1,sp:(sp+8000)));    
%    FrRev(FrRev==0)=NaN;
%  
%     CuS=QValues.CumSumR';
%     figure
%     scatter(FrRev,CuS)
%     [r4(cc),p4(cc)]=corr(FrRev,CuS);
%     yfit=linfit(FrRev,CuS);
%     legend(['r=' num2str(r4) ' ,p=' num2str(p4)])
%     cc=cc+1;
% end
% 
% ylabel('cumsum R/R0')
% xlabel(' fraction reversing')
% % ylim([0 1])
% title (dirname(cd))






