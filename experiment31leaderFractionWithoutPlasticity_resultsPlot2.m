% load
% L.J. Schumacher 28.10.13

close all
clear

time = 18;
numRepeats = 20;

precision = 2; % significant figures for filenames and plot labels etc.
paramCtr = 1;

followFracValues = [0, 3/4, 7/8, 15/16, 1];
sensingAccuracy = 0.1;
needNeighbours = 0;

% to calculate the density profile of cells along the x-direction
xBins = 0:50:800; % bins for counting cell num vs. x profiles
cellDistributions = NaN(length(followFracValues),numRepeats,3,length(xBins));

% preallocate variables for saving collated results
actualLeaderFraction = NaN(length(followFracValues),numRepeats);

figure
hold all
for followFracCtr = length(followFracValues):-1:1
    followerFraction = followFracValues(followFracCtr);
    for repCtr = 1:numRepeats
        loadInfo = ['experiment31/exp31_followFrac_' num2str(followerFraction,precision) ...
            '_sensingAcc_' num2str(sensingAccuracy) '_needNeighbours_' num2str(needNeighbours) ...
            '_Run_' num2str(repCtr)];
        try % sometimes we get corrupt files, which crashes the script
            load(['results/' loadInfo '.mat'])
        catch
            delete(['results/' loadInfo '.mat']) % delete the corrupt file
            experiment31leaderFractionWithoutPlasticity; % recreate the missing results file
            load(['results/' loadInfo '.mat']) % load again
        end
        
        % load cell positions into variables
        cells = out.cells_save{end}; % all cells
        numberOfCells = size(cells,2);
        followIdcs = out.cellsFollow{end}(1:numberOfCells);
        attachIdcs = out.attach_save{end}(1:numberOfCells);
        leaders = cells(:,followIdcs==0);
        followers = cells(:,followIdcs==1&attachIdcs~=0);
        losts = cells(:,followIdcs==1&attachIdcs==0);
        
        actualLeaderFraction(followFracCtr,repCtr) = size(leaders,2)/numberOfCells;

        % calculate migration profile
        numberOfCells = size(out.cells_save{end},2);
        cellDistributions(followFracCtr,repCtr,1,:) = histc(leaders(1,:),xBins); % leaders
        cellDistributions(followFracCtr,repCtr,2,:) = histc(followers(1,:),xBins); % followers, attached
        cellDistributions(followFracCtr,repCtr,3,:) = histc(losts(1,:),xBins); % followers, attached
    end
    % plot migration profile
    f_L = mean(actualLeaderFraction(followFracCtr,:));
    plotColor = f_L*[251 101 4]/255 + (1 - f_L)*[113 18 160]/255;
%     stairs(xBins,squeeze(mean(sum(cellDistributions(followFracCtr,:,:,:),3),2)),'Color',plotColor)
    h = bar(xBins + 25,squeeze(mean(sum(cellDistributions(followFracCtr,:,:,:),3),2)),1,...
        'FaceColor', plotColor, 'EdgeColor', 'none');
%     h = area(xBins + 25,squeeze(mean(sum(cellDistributions(followFracCtr,:,:,:),3),2)),...
%         'FaceColor', plotColor, 'EdgeColor', plotColor);
%     alpha(get(h,'children'),0.5)
end
xlabel('x/\mum'), ylabel('# cells / 50\mu m'), 
legend(num2str(flipud(mean(actualLeaderFraction,2)),precision))
ylim([0 16]), xlim([0 800]), set(gca,'YTick',[0 4 8 12 16])
grid on, set(gca,'Layer','top')

%% export figure
exportOptions = struct('Format','eps2',...
    'Width','18.0',...
    'Color','rgb',...
    'Resolution',300,...
    'FontMode','fixed',...
    'FontSize',10,...
    'LineWidth',2);

pos = get(gcf,'Position');
%     pos(4) = 3/2*pos(3);% adjust height to 3/2 width
set(gcf,'PaperUnits','centimeters','Position',pos);
filename = ['manuscripts/subpopulations/figures/resultsFig1C'];
exportfig(gcf,[filename '.eps'],exportOptions);
system(['epstopdf ' filename '.eps']);