% this comment is outdated
% input: GW wave
% output: dispatch cost, CO2, price capture for all the renewables
% figure 6, 9, 12: dispatch cost and CO2 vs GW wave for each region
% table 2, 4, 6: price capture for all renewables for 1GW wave in ea region

% assume that avoided dispatch cost and avoided CO2 are monetized in market
% so they generate revenue for wave.
% Energy produced = power (1 GW) * wave CF * 8760 hours
% So revenue = price capture * energy produced + 
%              avoided dispatch cost + avoided CO2 * social cost of carbon
% then the breakeven LCOE = revenue / energy produced

%% 100% renewable california Ryan coneference study
close all;clc;clear

zero_thresh = 0.03;

capfactor75 = [0.0995425836773127, 0.991096866096866
0.5051682548536994, 0.991096866096866
1.0028503547283338, 0.6869064577397905
2.010297479714852, 0.6127136752136746
4.029809570185218, 0.13787986704653266
7.2584428005433, 0.019171415004747505
10.054287479166371, 0.019171415004747505];
capfactor75(:,2) = capfactor75(:,2) - capfactor75(1,2) + 1;
capfactor75(capfactor75(:,2)<zero_thresh,2) = 0;

capfactor50 = [0.0995425836773127, 2.230116334283002
0.5027174889001689, 2.230116334283002
1.0028503547283338, 2.0001187084520424
2.0005447516437243, 1.42883428300095
4.029809570185218, 1.3472222222222223
4.919023232570778, 1.2581908831908835
10.054287479166371, 1.2581908831908835];
capfactor50(:,2) = capfactor50(:,2) - capfactor50(1,2) + 1;
capfactor50(capfactor50(:,2)<zero_thresh,2) = 0;

capfactor25 = [0.10002785737554139, 3.461716524216526
0.5002786125570823, 3.335588793922129
1.0028503547283338, 2.786562203228871
2.0005447516437243, 2.667853751187086
3.8760383504424576, 2.4897910731244077
10.054287479166371, 2.4897910731244077];
capfactor25(:,2) = capfactor25(:,2) - capfactor25(1,2) + 1;
capfactor25(capfactor25(:,2)<zero_thresh,2) = 0;

figure
semilogx(capfactor25(:,1),capfactor25(:,2),'bo-')
hold on
semilogx(capfactor50(:,1),capfactor50(:,2),'ro-')
semilogx(capfactor75(:,1),capfactor75(:,2),'go-')

ft = fittype('max(min(-m*log(x)+b,1),0)');
fit25 = fit(capfactor25(:,1),capfactor25(:,2),ft,'StartPoint',[.5,-.5]);
fit50 = fit(capfactor50(:,1),capfactor50(:,2),ft,'StartPoint',[.7,-.5]);
fit75 = fit(capfactor75(:,1),capfactor75(:,2),ft,'StartPoint',[.8,-.4]);
plot(fit25,'b--')
plot(fit50,'r--')
plot(fit75,'g--')

xlabel('Relative Cost of Wave to Wind/Solar, LCOE/LCOE_{ref}')
ylabel('Wave Energy Fraction of New Capacity, X_{wa}/X_{new}')
legend('CF=25%','CF=50%','CF=75%')
improvePlot

figure
CFs = [25 50 75];
values25 = coeffvalues(fit25);
values50 = coeffvalues(fit50);
values75 = coeffvalues(fit75);
bs = [values25(1),values50(1),values75(1)];
ms = [values25(2),values50(2),values75(2)];
plot(CFs,bs,'co',CFs,ms,'mo')
hold on

fitB = fit(CFs',bs','poly2');
fitM = fit(CFs',ms','poly2');
plot(fitB,'c--')
plot(fitM,'m--')

xlabel('Capacity Factor of Wave Energy, CF')
ylabel('Fit Coefficient')
legend('b','m')
improvePlot

CF_test = 20:10:80;
rel_cost_test = logspace(-1,1,100);
b_test = fitB(CF_test);
m_test = fitM(CF_test);

figure
percent_wave_test = zeros(length(CF_test),length(rel_cost_test));
for CFi = 1:length(CF_test)
    percent_wave_test(CFi,:) = max(min(-m_test(CFi).*log(rel_cost_test)+b_test(CFi),1),0);
    semilogx(rel_cost_test,percent_wave_test(CFi,:),'DisplayName',['CF=',num2str(CF_test(CFi))])
    hold on
end
legend
xlabel('Relative Cost of Wave to Wind/Solar, LCOE/LCOE_{ref}')
ylabel('Wave Energy Fraction of New Capacity, X_{wa}/X_{new}')
improvePlot

%% now switch to a countour plot where CF is continuous
CF = 25:75;
rel_cost = linspace(2,7,30);
[CF_mesh,rel_cost_mesh] = meshgrid(CF,rel_cost);
m_mesh = reshape(fitM(CF_mesh),size(CF_mesh));
b_mesh = reshape(fitB(CF_mesh),size(CF_mesh));
pct_wave_mesh = max(min(-m_mesh.*log(rel_cost_mesh)+b_mesh,1),0);
pct_wave_mesh(pct_wave_mesh==0) = NaN;

figure
contourf(CF_mesh,rel_cost_mesh,pct_wave_mesh)
xlabel('Capacity Factor of Wave Energy, CF')
ylabel('Relative Cost of Wave to Wind/Solar, LCOE/LCOE_{ref}')
title('Wave Energy Fraction of New Capacity, X_{wa}/X_{new}')
colorbar
improvePlot

%% go from percent wave new to percent wave total
CF_wind_solar = .25; % table 1 in Coe et al
C_old_wind_solar = 10.44+5.88; % table 1 in Coe et al
C_fossil = 43.74; % table 1 in Coe et al
CF_fossil = .77; % table 1 in Coe et al
% see notebook p170 for math
term = pct_wave_mesh .* CF_mesh/100 + (1-pct_wave_mesh) * CF_wind_solar;
divider = 1 + term * C_old_wind_solar / (C_fossil * CF_fossil);
pct_wave_total = pct_wave_mesh ./ divider;

figure
contourf(CF_mesh,rel_cost_mesh,pct_wave_total)
xlabel('Capacity Factor of Wave Energy, CF')
ylabel('Relative Cost of Wave to Wind/Solar, LCOE/LCOE_{ref}')
title('Wave Energy Fraction of Total Capacity, X_{wa}/X_{tot}')
colorbar
improvePlot

evolve_cost_per_pct_wave = 1.1e9/.04; % pounds per percent, from EVOLVE fig6 2050
dollars_per_pound = 1.2; % USD per pound
cost_solar_wind = 1325; % dollars per kW, from Coe et al p4
evolve_capacity_system = 290e6; % kW, from EVOLVE fig5 2050

cost_per_pct_economic_dispatch = evolve_cost_per_pct_wave / evolve_capacity_system * dollars_per_pound;
cost_per_pct_capacity_expansion = rel_cost_mesh * cost_solar_wind;

avoided_cost = cost_per_pct_economic_dispatch * pct_wave_total + cost_per_pct_capacity_expansion .* pct_wave_mesh;

figure
subplot 121
contourf(CF_mesh,rel_cost_mesh,avoided_cost)
xlabel('Capacity Factor of Wave Energy, CF')
ylabel('Relative Cost of Wave to Wind/Solar, LCOE/LCOE_{ref}')
title('Model Fit')
caxis([0 1500])
improvePlot

idx = ~isnan(avoided_cost);
fitAvoidedCost = fit([CF_mesh(idx),rel_cost_mesh(idx)],avoided_cost(idx),'poly11')
avoided_cost_approx = reshape(fitAvoidedCost(CF_mesh,rel_cost_mesh),size(CF_mesh));
avoided_cost_approx(avoided_cost_approx<=0) = NaN;
subplot 122
contourf(CF_mesh,rel_cost_mesh,avoided_cost_approx)
xlabel('Capacity Factor of Wave Energy, CF')
ylabel('Relative Cost of Wave to Wind/Solar, LCOE/LCOE_{ref}')
title('Linear Approximation')
sgtitle('Avoided Cost ($/kW system capacity)')
colorbar
caxis([0 1500])
improvePlot

ratio_ED = cost_per_pct_economic_dispatch * pct_wave_total ./ avoided_cost;
figure
contourf(CF_mesh,rel_cost_mesh,ratio_ED)
xlabel('Capacity Factor of Wave Energy, CF')
ylabel('Relative Cost of Wave to Wind/Solar, LCOE/LCOE_{ref}')
title('Ratio of ED to Total Avoided Cost')
improvePlot
colorbar

figure
plot(fitAvoidedCost,[CF_mesh(idx),rel_cost_mesh(idx)],avoided_cost(idx))