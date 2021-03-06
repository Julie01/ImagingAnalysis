%Julia code

clear
rValues=NaN;
cc=1;
prune=1;
dirList=dir('*BAGxAFD.mat');
m=1;
% prune=1;
for i=1:length(dirList)
    
    fileData{i}=load(dirList(i).name);
    thisFieldNames=fieldnames(fileData{i}.Data);
    for j=1:length(thisFieldNames);
         for k=1:length( fileData{i}.Data.(thisFieldNames{j}))
             
             if isfield(fileData{i}.Data.(thisFieldNames{j})(k), 'CO2')==1 
                if ~isempty(fileData{i}.Data.(thisFieldNames{j})(k).CO2)
             inputTrace{m}=fileData{i}.Data.(thisFieldNames{j})(k).CO2(prune:end);
             outputTrace{m}=fileData{i}.Data.(thisFieldNames{j})(k).ratio(prune:end);   
             XYTrace{m}=fileData{i}.Data.(thisFieldNames{j})(k).XY(prune:end,:)';            
             
             trialLabel{m}=[ dirList(i).name(1:8) '-' thisFieldNames{j} '-T' num2str(k)  ];
                 
                  m=m+1;
                 end
             end
            
         end
        
    end

end


%%%%%%%%%

%%
figure('Position',[0 0 1200 800]);

fps=30;
numTrials=length(inputTrace);
nc=5;
nr=ceil(numTrials/nc);



for i=1:numTrials
    
    subtightplot(nr,nc,i);

    goodFrames=1:min([length(inputTrace{i}) length(outputTrace{i}) ]);

    thisInputTrace=inputTrace{i}(goodFrames);
    thisOutputTrace=outputTrace{i}(goodFrames);

    tv=(1:length(goodFrames))/fps;

    thisInputTrace_cent=thisInputTrace-nanmean(thisInputTrace);
    thisOutputTrace_cent=thisOutputTrace-nanmean(thisOutputTrace);

    thisInputTrace_norm=thisInputTrace_cent/rms(thisInputTrace_cent);
    thisOutputTrace_norm=thisOutputTrace_cent/rms(thisOutputTrace_cent);

    plot(tv,thisInputTrace_norm,'r');
    hold on;
    plot(tv,thisOutputTrace_norm,'b');
    rValues(i)=round(nancorr(thisInputTrace_norm,thisOutputTrace_norm)*100)/100;
    intitle(['r=' num2str(rValues(i)) ' .. ' trialLabel{i}]);
  


end

%input v output plots with correlation

figure('Position',[0 0 1200 800]);
fps=30;
numTrials=length(inputTrace);
nc=5;
nr=ceil(numTrials/nc);



for i=1:numTrials
    
    subtightplot(nr,nc,i);

    goodFrames=1:min([length(inputTrace{i}) length(outputTrace{i}) ]);

    thisInputTrace=inputTrace{i}(goodFrames);
    thisOutputTrace=outputTrace{i}(goodFrames);

    tv=mtv(goodFrames,fps);

    thisInputTrace_cent=thisInputTrace-nanmean(thisInputTrace);
    thisOutputTrace_cent=thisOutputTrace-nanmean(thisOutputTrace);

    thisInputTrace_norm=thisInputTrace_cent/rms(thisInputTrace_cent);
    thisOutputTrace_norm=thisOutputTrace_cent/rms(thisOutputTrace_cent);

    plot(thisInputTrace_norm,thisOutputTrace_norm,'b');
    
    rValues(i)=nancorr(thisInputTrace_norm,thisOutputTrace_norm);
    intitle(['r=' num2str(rValues(i)) ' .. ' trialLabel{i}]);


end

correlation=nanmean(rValues)



