
function [projectionsCBW2,projectionsRBW2,coefs,scoresAcc,Variances] = PrinCompDecomp(allangles)
%this function performs eigenworm decompositiopn and returns the
%reconstructed body wave (EW1 + EW2) and residuals (SUM of EW3-AngNum) of a track from variable WormGeomTracks.
% Rows of X correspond to observations, columns to variables



SmoothFactor = 1; %smooth factor for raw wormangle data


NumFrames = size(allangles,1);
AngNum = size(allangles,2);

projectionsCBW = NaN(AngNum,NumFrames,'single');
projectionsCBW2 = NaN(AngNum,NumFrames,'single')';
 
projectionsRBW = zeros(AngNum,NumFrames,'single');
projectionsRBW2 = zeros(AngNum,NumFrames,'single')';


msgid = 'stats:princomp:colRankDefX';
 warning('off', msgid);
 
 
%          allangles = nanmoving_average(allangles,SmoothFactor,1,1);

%        [coefs,scoresAcc,Variances,~] = princomp(allangles);
         [coefs,scoresAcc,Variances,~] = princomp(fixnanC(allangles));
        % PRINCOMP assumes: Rows of X correspond to observations, columns to variables
        % COEFF is a P-by-P matrix, each column containing coefficients
        % for one principal component.  The columns are in order of decreasing
        % component variance. Rows of SCORE correspond to observations, columns to components.
        % coefs = PCs or eigenvectors (columns)
        % scoresAcc = projection amplitude (columns), representation of X in the principal component space
        % variances = eigenvalues of covariances matrix
        
        % there is a slight difference between the 2 different calculation
        % methods ; probably depends on precision of nanmean(allangles)
        % i.e. all data are slightly (up or downwards) shifted, however diff(data) stays the same!!

        
      % CBW is made up by first 2 EW (independent of total number of EW) 
      
        projectionsCBW(:,:) = coefs(:,1) * scoresAcc(:,1)' + coefs(:,2) * scoresAcc(:,2)';
        projectionsCBW(isnan(allangles)') = NaN;
        % figure;imagesc(1:1000,1:27,projectionsCBW);

        
        finaldata = [coefs(:,1) coefs(:,2)]' * (fixnanC(allangles) - repmat(nanmean(allangles),NumFrames,1))';
        projectionsCBW2(:,:) = finaldata' * [coefs(:,1) coefs(:,2)]' + repmat(nanmean(allangles),NumFrames,1);
        projectionsCBW2 = projectionsCBW2';
        projectionsCBW2(isnan(allangles)') = NaN;
        % figure;imagesc(1:1000,1:27,projectionsCBW2);


      % RBW is made up from all remaining EW (or can possibly be restricted
      % to 3-4 or 3-9 or 3-whatever, as the lower EW have very little eigenvalues)

       for n = 3: AngNum   
           projectionsRBW(:,:) = coefs(:,n) * scoresAcc(:,n)' + projectionsRBW;
       end
       projectionsRBW(isnan(allangles)') = NaN;
       % figure;imagesc(1:1000,1:27,projectionsRBW);

       featurevector = [];
       for n = 3: AngNum   
           featurevector = [featurevector coefs(:,n)];
       end
       
        finaldata = featurevector' * (fixnanC(allangles) - repmat(nanmean(allangles),NumFrames,1))';
        projectionsRBW2(:,:) = finaldata' * featurevector' + repmat(nanmean(allangles),NumFrames,1);
        projectionsRBW2 = projectionsRBW2';
        projectionsRBW2(isnan(allangles)') = NaN;
        % figure;imagesc(1:1000,1:27,projectionsRBW2);
        
    end
    


 