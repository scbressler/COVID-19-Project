% covid_19.m
%
% Tracking the COVID-19 pandemic
%
% Created: 2020-04-01 Scott Bressler
%
% Datasets:
%   United States: https://github.com/scbressler/covid-19
%   World: https://covid.ourworldindata.org/data/ecdc/full_data.csv

clear all; close all; clc;

mvw = 3; % moving average window (days)

% Which STATE(S) to highlight
x = {'Massachusetts'};

%% Import STATE data
%   Data from the New York Times COVID-19 database from Github

[~,~,rawS] = xlsread('covid-19-spreadsheet.xlsx','byState');

header = rawS(1,:);
dates = cellstr(datestr(cell2mat(rawS(2:end,1))-1));
states = rawS(2:end,2);
casesStateRAW = cell2mat(rawS(2:end,4));
deathsStateRAW = cell2mat(rawS(2:end,5));

allStates = sort(unique(states));
allST = {'AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','GU','HI','ID',...
         'IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT',...
         'NE','NV','NH','NJ','NM','NY','NC','ND','NMI','OH','OK','OR','PA',...
         'PR','RI','SC','SD','TN','TX','UT','VT','VI','VA','WA','WV','WI','WY'}';
     
allDates = cellstr(datestr(sort(unique(cell2mat(rawS(2:end,1))-1))));

%% Compile CASES and DEATHS by STATE
for d = 1:length(allDates)
    idxDate = strcmp(dates,allDates(d));
    for st = 1:length(allStates)
        idxState = strcmp(states,allStates(st));
        
        CASES(d,st) = sum(casesStateRAW(idxDate & idxState));
        DEATHS(d,st) = sum(casesStateRAW(idxDate & idxState));
        
    end
end

dCASES = diff(CASES);
d7CASES = movmean(dCASES,[mvw-1 0]);
dDEATHS = diff(DEATHS,2);
d7DEATHS = movmean(dDEATHS,[mvw-1 0]);

%% Figure 1: Trajectory of COVID-19 Cases in the US by State
f1 = figure('Position',[113 146 1234 643]);
for n = 2:length(allDates)
  
p11 = plot(CASES(2:n,:),d7CASES(1:n-1,:),'-','Color',0.65*ones(1,3),'LineWidth',0.5);
hold on;
p12 = plot(CASES(n,:),d7CASES(n-1,:),'r.','MarkerSize',10);

txt0 = text(120,60000,sprintf('%s-2020',datestr(allDates(n),'mmm-dd')),...
    'HorizontalAlignment','left','FontSize',14);

ax1 = gca;
ax1.XLim = [1 100000]; ax1.YLim = [0.1 100000];
% ax1.XTick = [1 10 100 1000 10000 100000];
% ax1.YTick = ax1.XTick;
ax1.XScale = 'log'; ax1.YScale = 'log';
ax1.XTickLabel = {'1','10','100','1k','10k','100k'};
ax1.YTickLabel = {'0.1','1','10','100','1k','10k','100k'};
ax1.XGrid = 'on'; ax1.YGrid = 'on';
ax1.XMinorGrid = 'off'; ax1.YMinorGrid = 'off';
ax1.XLabel.String = 'Total Confirmed Cases';
ax1.XLabel.FontSize = 12;
ax1.YLabel.String = sprintf('Average New Cases Across Previous %d Days',mvw);
ax1.YLabel.FontSize = 12;
ax1.Title.String = 'Trajectory of COVID-19 Confirmed Cases';
ax1.Title.FontSize = 14;
ax1.NextPlot = 'replacechildren';

% L1 = line(ax1.XLim,ax1.YLim,'LineWidth',1,'LineStyle','--','Color','k');
L1 = line([1 1e5],[0.1 1e4],'LineWidth',1,'LineStyle','--','Color','k');


for k = 1:length(allStates)
    TXT(k) = text((10^0.02)*CASES(n,k),d7CASES(n-1,k),allStates{k},'FontSize',6);
end

drawnow;
F(n-1) = getframe;
pause(0.1);

end

[~,idx] = ismember(x,allStates);

for k = 1:length(idx)
    p11(idx(k)).Color = [199,21,133]/255;
    p11(idx(k)).LineWidth = 3;
    uistack(p11(idx(k)));
end

% Highlight New York for reference?
if 1
    p11(strcmp(allStates,'New York')).Color = [0 0.4470 0.7410];
    p11(strcmp(allStates,'New York')).LineWidth = 1;
end

drawnow;
F(end+1) = getframe;

print(f1,'Figures/New Cases vs Total Cases.eps','-depsc')

%% Figure 2: New cases per day by STATE
f2 = figure('Position',[1 472 560 333]);
p2 = plot(2:length(allDates),d7CASES,'.-'); %,'Color',0.6*ones(1,3));

%% Movie
% movie(f1,F)