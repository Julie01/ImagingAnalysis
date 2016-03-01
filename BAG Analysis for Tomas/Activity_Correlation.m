%peak quantification
% figure
% CuS=CumSumS(:,end-2)';
% notBoxPlot([P1 ;P2;CuS]');
% set(gca, 'xticklabel', {'abs max in window', 'mean 6 sec window', 'cumsum stimulus episode'});
% title(dirname(cd))
% ylim([2 11])
CC=1;
for win=3000
%% activity vs peak cumsum value
clear r1 p1 r2 p2 r3 p3 r4 p4
cc=1;
%peak R value
for  sp=1:1000:9400
if (sp+win)<14560    
FrA=nansum(PauseMatrix(:,sp:(sp+win)),2)/length(PauseMatrix(1,sp:(sp+win)));
%FrA=nansum(PauseMatrix(:,sp:end),2)/length(PauseMatrix(1,sp:end));
 [r1(cc),p1(cc)]=corr(P1',FrA);
cc=cc+1;
end

end

%% cumsum

cc=1;
%peak R value
for  sp=1:1000:10000
    if (sp+win)<14560    
 FrA=nansum(PauseMatrix(:,sp:(sp+win)),2)/length(PauseMatrix(1,sp:(sp+win)));
%FrA=nansum(PauseMatrix(:,sp:end),2)/length(PauseMatrix(1,sp:end));
FrA=1-FrA;
CuS=CumSumS(:,end-2);
[r2(cc),p2(cc)]=corr(CuS,FrA);
cc=cc+1;
    end
end


subtightplot(1,5,CC)
plot(r1)
hold on
plot(r2,'r')
legend('P1','cumsum')
title(win)
CC=CC+1;
end

%%  compare pre and post stimulus:
% figure
% notBoxPlot([FrA1 FrA])
% [h p] = ttest2(FrA1,FrA)
% legend(['p=' num2str(p)])
% set(gca,'xticklabel',{'pre stim', 'post stim'})
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






