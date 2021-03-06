% plot migration outcome for continuous vs discrete states

close all
clear all
addpath('../')

time = 18;
numRepeats = 40;

% simulation parameters
sensingAccuracy = 0.1;
needNbrsValues = [0:4];
nVals = length(needNbrsValues);
guidanceModes = {'choice','combination'};

% auxiliary variables for plotting and loading
cellRadius = 7.5;
time2plot = [24];
precision = 2; % significant figures for filenames and plot labels etc.
loadpath = '../results/';
lineStyles = {'-','--'};
plotColors = lines(2);
migrationProfilesFig = figure;
hold on
for gdmCtr = 1:length(guidanceModes)
    guidanceMode = guidanceModes{gdmCtr};
    % preallocate variables for saving collated results
    numCells = NaN(length(needNbrsValues),numRepeats);
    xMax = NaN(length(needNbrsValues),numRepeats);
    hold on
    for nNbrCtr = 1:nVals
        needNbrs = needNbrsValues(nNbrCtr);
        
        %% load data
        for repCtr = 1:numRepeats
            filename = ['experiment31contStates_needNbrs/exp31' ...
                '_contStates_' guidanceMode '_needNbrs_' num2str(needNbrs,precision) ...
                '_sensingAcc_' num2str(sensingAccuracy,precision) '_Run_' num2str(repCtr)];
            load([loadpath filename '.mat'])
            
            % load cell positions into variables
            timeIdx = find(out.t_save >= time2plot,1,'first');
            cells = out.cells_save{timeIdx}; % all cells
            
            numCells(nNbrCtr,repCtr) = size(cells,2);
            xMax(nNbrCtr,repCtr) = max(cells(1,:));
            
        end
    end
    yyaxis left
    plot(needNbrsValues,mean(numCells,2),...
        lineStyles{gdmCtr},'Color',plotColors(1,:),'LineWidth',2);
    yyaxis right
    plot(needNbrsValues,mean(xMax,2),...
        lineStyles{gdmCtr},'Color',plotColors(2,:),'LineWidth',2);
end
box on
xlabel('neighbour requirement')
xticks(needNbrsValues)
yyaxis left
ylim([20 130])
ylabel('number of cells')
yyaxis right
ylim([100 1000]);
ylabel('max. dist. migrated (\mum)')

%% export figure
exportOptions = struct('Format','eps2',...
    'Width','8.0',...
    'Color','rgb',...
    'Resolution',300,...
    'FontMode','fixed',...
    'FontSize',10,...
    'LineWidth',2);

filename = ['../manuscripts/JTB/figures/FigS2_contStates_needNbrs_'...
    'sensAcc_' num2str(100*sensingAccuracy)];
set(migrationProfilesFig,'PaperUnits','centimeters');
exportfig(migrationProfilesFig,[filename '.eps'],exportOptions);
system(['epstopdf ' filename '.eps']);
