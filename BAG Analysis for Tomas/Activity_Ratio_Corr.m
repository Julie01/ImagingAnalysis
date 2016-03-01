% correlate BAG activity with behavioral Activity:

figure
% scatter(presActivity,P1)
hold on
h1=scatter(1-postsActivity,P1,'filled');
h2=scatter(1-postsActivity,P2,'filled');
% [r,h]=corr(presActivity',P1');
[r(1),h(1)]=corr(1-postsActivity',P1');
[r(2),h(2)]=corr(1-postsActivity',P2');
xlabel('fraction time active')
ylabel('median peak R value')
legend(['median first peak, r=' num2str(r(1)) '; p=' num2str(h(1))],['median upper std dev, r=' num2str(r(2)) '; p=' num2str(h(2))])
title(dirname(cd))

%cumsum:

figure
% scatter(presActivity,P1)
hold on
h1=scatter(1-postsActivity,CumSumS(:,end),'filled');
% [r,h]=corr(presActivity',P1');
[rc(1),hc(1)]=corr(1-postsActivity',P1')
xlabel('fraction time active')
ylabel('median peak R value')
legend(['CumSum R/T, r=' num2str(rc(1)) '; p=' num2str(hc(1))])
title(dirname(cd))



