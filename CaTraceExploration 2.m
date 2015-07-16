%Julia code

change 22
% a better way to structure your data: 
% Trial().CO2
% Trial().Ratio
% Trial().X
% Trial().Y
% Trial().WormNum
% Trial().TrialNum
%



dirList=dir('*BAGxAFD.mat');
m=1;

for i=1:length(dirList)
    fileData{i}=load(dirList(i).name);

    thisFieldNames=fieldnames(fileData{i}.Data);
    for j=1:length(thisFieldNames);
         for k=1:length( fileData{i}.Data.(thisFieldNames{j}))
                         
             inputTrace{m}=fileData{i}.Data.(thisFieldNames{j})(k).CO2;
             outputTrace{m}=fileData{i}.Data.(thisFieldNames{j})(k).ratio;            
             
             trialLabel{m}=[ dirList(i).name(1:8) '-' thisFieldNames{j} '-T' num2str(k)  ];
             
             m=m+1;
         end
        
    end

end




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

    tv=mtv(goodFrames,1/fps);

    thisInputTrace_cent=thisInputTrace-nanmean(thisInputTrace);
    thisOutputTrace_cent=thisOutputTrace-nanmean(thisOutputTrace);

    thisInputTrace_norm=thisInputTrace_cent/rms(zeronan(thisInputTrace_cent));
    thisOutputTrace_norm=thisOutputTrace_cent/rms(zeronan(thisOutputTrace_cent));

    plot(tv,thisInputTrace_norm,'r');
    hold on;
    plot(tv,thisOutputTrace_norm,'b');
    intitle(trialLabel{i});


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

    thisInputTrace_norm=thisInputTrace_cent/rms(zeronan(thisInputTrace_cent));
    thisOutputTrace_norm=thisOutputTrace_cent/rms(zeronan(thisOutputTrace_cent));

    plot(thisInputTrace_norm,thisOutputTrace_norm,'b');
    
    rValues=corrcoef(zeronan(thisInputTrace_norm),zeronan(thisOutputTrace_norm));
    intitle([num2str(rValues(1,2)) ' ' trialLabel{i}]);


end



