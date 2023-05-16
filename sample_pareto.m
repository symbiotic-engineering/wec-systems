theta = linspace(0,90,30);
x = cosd(theta);
y = sind(theta);

figure
plot(x,y,'o','MarkerFaceColor','b')
hold on
xlabel('Net Value of Energy ($/kWh)')
ylabel('Net EcoValue ($/kWh)')
set(gca,'YTickLabel',[],'XTickLabel',[],'XTick',[],'YTick',[])
title('Example Pareto Front')
improvePlot
plot(1,1,'pg','MarkerFaceColor','g','MarkerSize',40)