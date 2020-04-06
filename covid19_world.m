% covid19_world.m
clear all; close all; clc;
printPlots = 1; % Save plot to .eps file? [0=no, 1=yes];
renderMovieFile = 1; % Create animated plot? [0=no, 1=yes]

% World Database: https://covid.ourworldindata.org/data/ecdc/full_data.csv

data = webread('https://covid.ourworldindata.org/data/ecdc/full_data.csv');

allDates = unique(data.date);
allCountries = unique(data.location);

% Pick which countries' data to view
whichCountries = {'United States','France','India','China','Germany','Iran',...
                  'United Kingdom','Turkey','South Korea','Switzerland','World'};

% Moving average parameter for New Cases for previous nDays
nDays = 5;

%% Compile data
for d = 1:length(allDates)
    kD = data.date == allDates(d);
    for c = 1:length(whichCountries)
         kC = strcmp(data.location,whichCountries(c));
         
         newCASES(d,c) = sum(data.new_cases(kD & kC));
         newDEATHS(d,c) = sum(data.new_deaths(kD & kC));
         
         CASES(d,c) = sum(data.total_cases(kD & kC));
         DEATHS(d,c) = sum(data.total_deaths(kD & kC));
    end
end

dNCASES = movmean(newCASES,[nDays-1 0]);
dNDEATHS = movmean(newDEATHS,[nDays-1 0]); 

%% Figure 1: New CoVID-19 Cases (averaged over N days) vs Total Cases
f1 = figure('Position',[113 146 1234 643]);
for n = 1:length(allDates)
p11 = plot(CASES(1:n,:),dNCASES(1:n,:),'-','Color',0.65*ones(1,3),'LineWidth',1);
hold on;
p12 = plot(CASES(n,:),dNCASES(n,:),'r.','MarkerSize',14);

ax1 = gca;
ax1.NextPlot = 'replacechildren';
ax1.XLim = [1 1e7]; ax1.YLim = [0.1 1e6];
ax1.XScale = 'log'; ax1.YScale = 'log';
ax1.XTickLabel = {'1','10','100','1k','10k','100k','1M','10M'};
ax1.YTickLabel = {'0.1','1','10','100','1k','10k','100k','1M'};
ax1.XGrid = 'on'; ax1.YGrid = 'on';
ax1.XMinorGrid = 'off'; ax1.YMinorGrid = 'off';
ax1.XLabel.String = 'Total Confirmed Cases';
ax1.XLabel.FontSize = 12;
ax1.YLabel.String = sprintf('Average New Cases Across Previous %d Days',nDays);
ax1.YLabel.FontSize = 12;
ax1.Title.String = sprintf('Trajectory of COVID-19 Confirmed Cases as of %s',datestr(allDates(n)));
ax1.Title.FontSize = 14;

L1 = line([1 1e7],[0.1 1e6],'LineWidth',1,'LineStyle','--','Color','k');

% Add in Country labels
for k = 1:length(whichCountries)
    TXT(k) = text((10^0.02)*CASES(n,k),dNCASES(n,k),whichCountries{k},'FontSize',12);
end

drawnow;
F(n) = getframe(f1);
pause(0.05);

end

ax2 = axes('Position',[0.18 0.6 0.3 0.3]);
ax2.NextPlot = 'replacechildren';
ax2.ColorOrder = parula(1*(length(whichCountries)-1));
ax2.YLim = [0 1e5];
ax2.XTick = 2:14:length(allDates);
ax2.XTickLabel = datestr(allDates(ax2.XTick),'dd-mmm');
ax2.XTickLabelRotation = 35;
ax2.YLabel.String = sprintf('New Cases (ave. %d days)',nDays);
ax2.XLim = [0 length(allDates)+30];
ax2.YGrid = 'on';
ax2.YLim = [0 40e3];
ax2.YTick = 0:5e3:40e3;
ax2.YTickLabel = {'0','5k','10k','15k','20k','25k','30k','35k','40k'};
p21 = plot(ax2,1:length(allDates),dNCASES(:,1:end-1),'.-');

for k = 1:length(whichCountries)-1
    txt2 = text(length(allDates)+2,dNCASES(end,k),whichCountries{k},'FontSize',6);
end

drawnow;

if printPlots
    print(f1,'Figures/New Cases vs Total Cases-World.eps','-depsc');
end

%% Movie
if renderMovieFile
    v = VideoWriter('Figures/New Cases vs Total Cases World.avi');
    v.FrameRate = 8;
    open(v);
    
    for k = 1:length(F)
        writeVideo(v,F(k));
    end
    close(v);
end