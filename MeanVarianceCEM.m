sigma = [.34 .34 .24 .21 .17 .21, ...
         .32 .33 .215 .18 .15 .185, ...
         .29 .20 .21 .16, .14, .182];
LCOE_2030 = [50 50 52 53 54 54, ...
             53 55 55 56 59 58, ...
             56 61 57 60 59 57];

colors = {'r','b','g','k','c','m'};

close all
figure
hold on
num_portfolios = length(sigma)/3;
slope = zeros(1,num_portfolios);
for i=1:num_portfolios
    idxs = [i,i+num_portfolios,i+2*num_portfolios];
    plot(sigma(idxs), LCOE_2030(idxs),['*-',colors{i}])

    X = [ones(3,1),sigma(idxs)'];
    Y = LCOE_2030(idxs)';
    regression = X\Y;
    slope(i) = regression(2);
end
xlabel('\sigma_{CF}: Std. Dev. of Capacity Factor (-)')
ylabel('Breakeven LCOE in 2030 ($/MWh)')
leg_text = {'600-00-0; ','300-0-0; ','600-0-200; ','300-0-200; ','300-150-200; ','600-150-200; '};
slope_cell = strtrim(cellstr(num2str(slope','%.0f'))');
leg = legend(strcat(leg_text', slope_cell'));
title(leg,'X_{wi}-X_{wa}-X_{c}; LCOE/\sigma_{CF}')
title('Sensitivities from de Faria et. al.')

text(.16,52,['Average Slope: ' num2str(mean(slope),'%.0f')] )
improvePlot