% plots fraction of active worms from imaging:

figure
pp=nansum(PauseMatrix,1)/(CC-1);
pp=1-pp;
pp=medfilt1(pp);
plot([tv tv2], pp(1:end), 'linewidth',2)
hold on
plot ([4.63*60 4.63*60], [0 1],'g')
ylabel('fraction animals active')
xlabel( 'sec')
ylim([0 1])
title(dirname(cd))