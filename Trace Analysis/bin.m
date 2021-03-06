
mBAG=NaN(1,10);
mSens=NaN(1,10);
mDC=NaN(1,10);
mDR=NaN(1,10);

%% bin for dCdt
binsize=0.0015;

cc=1;
for i=-0.025 :binsize:(0.025-binsize)
    
    bin_idx= find(dCdTAll>i & dCdTAll<=i+binsize);
    
    if length(bin_idx)>50
        
        bV=bagAll(bin_idx);
        %         aV=afdAll(bin_idx);
        sV=SensNormAll(bin_idx);
        dCV=dCdTAll(bin_idx);
        dRV=dRdTAll(bin_idx);
        
        mBAG(1,cc)=nanmedian(bV);
        %         mAFD(1,cc)=nanmedian(aV);
        mSens(1,cc)=nanmean(sV);
        mDC(1,cc)=nanmedian(dCV);
        mDR(1,cc)=nanmedian(dRV);
        if  isnan(mDR(1,cc))
            mDR(1,cc)=nanmean(dRV);
        end
            
        
    end
    cc=cc+1;
end
%% plot  bins:
figure
%%
subtightplot(1,2,1)
bar(mDR(1,:))
set(gca,'XTick',[1:3:length(mDC(1,:))])
set(gca,'XTickLabel',round(mDC(1,1:3:end)*1000)/1000);
title(' dRdT')
xlabel( 'dCdT')

subtightplot(1,2,2)
bar(mBAG(1,:))
set(gca,'XTick',[1:3:length(mDC(1,:))])
set(gca,'XTickLabel',round(mDC(1,1:3:end)*1000)/1000);
title('norm BAG')
xlabel( 'dCdT')
