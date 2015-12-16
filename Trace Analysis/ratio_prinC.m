

% ratios principal component analysis:
function [varc,coefs]=ratio_prinC(data)

[projectionsCBW2,projectionsRBW2,coefs,scores,variances] = PrinCompDecomp(data);
scores = scores';
s=sum(variances);
varc=variances./s;
%%
figure;
 for pc = 1:9

   subplot(3,3,pc);
   plot([1:length(coefs)], coefs(:,pc));
   title(['PC' num2str(pc) 'var cont =' num2str(varc(pc))],'Fontsize',10);
   
   ylim([-0.1 0.1]);
   xlim([1 length(coefs)]);
   
 end
 

end