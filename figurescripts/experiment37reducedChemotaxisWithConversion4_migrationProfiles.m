% plot migration profiles for simulated NRP1 knockdown.
% L.J. Schumacher 05.09.14

close all
clear all

time = 18;
numRepeats = 20;

precision = 2; % significant figures for filenames and plot labels etc.

conversionType = 4;
defaultFollowValues = [2];
sensingAccuracyValues = [0.1, 0.01];
numParamCombinations = length(defaultFollowValues)*length(sensingAccuracyValues);
timePoints2plot = [16, 24, 36];
tstep = 1/60;                   % time step in hours
plotColors = [linspace(0.5,1,length(timePoints2plot))'*[0 0 1];
               linspace(0.5,1,length(timePoints2plot))'*[1 0 0]];
plotStyles = {':','--','-'};
xBins = 0:50:1000; % bins for counting cell num vs. x profiles
% parameters for neighbourhood analysis
neighbourCutoff = 84.34;
cellRadius = 7.5;

for defaultFollow = defaultFollowValues
    for sensAccCtr = 1:length(sensingAccuracyValues)
        sensingAccuracy = sensingAccuracyValues(sensAccCtr);
        for lead2follow = [4 8]
            for follow2lead = [4 8]
                numSteps = [lead2follow, follow2lead];
                migrationProfilesFig = figure;
                hold on
                for perturbation = 0:1
                    % preallocate variables for saving collated results
                    cellDistributions = NaN(length(defaultFollowValues),length(sensingAccuracyValues),...
                        numRepeats,3,length(xBins),length(timePoints2plot));
                    actualLeaderFraction = NaN(length(defaultFollowValues),length(sensingAccuracyValues),...
                        numRepeats,length(timePoints2plot));
                    numCells = NaN(length(defaultFollowValues),length(sensingAccuracyValues),...
                        numRepeats,length(timePoints2plot));
                    neighbourAreas = NaN(length(defaultFollowValues),length(sensingAccuracyValues),...
                        numRepeats,21,length(timePoints2plot));
                    neighbourDistances = NaN(length(defaultFollowValues),length(sensingAccuracyValues),...
                        numRepeats,length(2*cellRadius:cellRadius:neighbourCutoff),length(timePoints2plot));
                    
                    %% load data
                    numSteps = [lead2follow, follow2lead];
                    for repCtr = 1:numRepeats
                        if perturbation==0 % load control simulation
                            loadInfo = ['experiment31conversion4/exp31'...
                                '_conversion_4_defaultFollow_' num2str(defaultFollow) ...
                                '_numSteps_' num2str(numSteps(1)) '_' num2str(numSteps(2)) ...
                                '_sensingAcc_' num2str(sensingAccuracy) '_Run_' num2str(repCtr)];
                            try % sometime we get corrupt files, which crashes the script
                                load(['results/' loadInfo '.mat'])
                            catch
                                delete(['results/' loadInfo '.mat']) % delete the corrupt file
                                experiment31leaderFractionWithConversion4; % recreate the missing results file
                                load(['results/' loadInfo '.mat']) % load again
                            end
                        else % load transplant simulations
                            loadInfo = ['experiment37reducedChemotaxis/exp37' ...
                                '_conversion_' num2str(conversionType) '_defaultFollow_' num2str(defaultFollow) ...
                                '_numSteps_' num2str(numSteps(1)) '_' num2str(numSteps(2)) ...
                                '_sensingAcc_' num2str(sensingAccuracy) '_Run_' num2str(repCtr)];
                            try % sometime we get corrupt files, which crashes the script
                                load(['results/' loadInfo '.mat'])
                            catch
                                delete(['results/' loadInfo '.mat']) % delete the corrupt file
                                experiment37reducedChemotaxisWithConversion4; % recreate the missing results file
                                load(['results/' loadInfo '.mat']) % load again
                            end
                        end
                        for timeCtr = 1:length(timePoints2plot)
                            timeIdx = find(out.t_save >= timePoints2plot(timeCtr),1,'first');
                            % load cell positions into variables
                            cells = out.cells_save{timeIdx}; % all cells
                            numberOfCells = size(cells,2);
                            followIdcs = out.cellsFollow_save{timeIdx}(1:numberOfCells);
                            attachIdcs = out.attach_save{timeIdx}(1:numberOfCells);
                            leaders = cells(:,followIdcs==0);
                            followers = cells(:,followIdcs==1&attachIdcs~=0);
                            losts = cells(:,followIdcs==1&attachIdcs==0);
                            
                            actualLeaderFraction(defaultFollow + 1,sensAccCtr,repCtr,timeCtr) =...
                                size(leaders,2)/numberOfCells;
                            numCells(defaultFollow + 1,sensAccCtr,repCtr,timeCtr) = numberOfCells;
                            
                            % calculate migration profile
                            cellDistributions(defaultFollow + 1,sensAccCtr,repCtr,1,:,timeCtr) =...
                                histc(leaders(1,:),xBins); % leaders
                            cellDistributions(defaultFollow + 1,sensAccCtr,repCtr,2,:,timeCtr) =...
                                histc(followers(1,:),xBins); % followers, attached
                            cellDistributions(defaultFollow + 1,sensAccCtr,repCtr,3,:,timeCtr) =...
                                histc(losts(1,:),xBins); % followers, attached
                        end
                    end
                    %% plot migration profile
                    for timeCtr = 1:length(timePoints2plot)
                        f_L = mean(actualLeaderFraction(defaultFollow + 1,sensAccCtr,:,timeCtr));
                        n_C = mean(numCells(defaultFollow + 1,sensAccCtr,:),timeCtr);
                        % plot migration profile
                        set(0,'CurrentFigure',migrationProfilesFig);
                        % plot leaders + followers
                        plotHandles(timeCtr,perturbation + 1) = ...
                            plot(xBins,squeeze(mean(sum(cellDistributions(defaultFollow + 1,sensAccCtr,:,:,:,timeCtr),4),3)),...
                            'LineWidth',2,'LineStyle',plotStyles{timeCtr},'color',...
                            plotColors(timeCtr + perturbation*length(timePoints2plot),:));
%                         % plot leaders
%                         plotHandles(timeCtr,perturbation + 1) = ...
%                             plot(xBins,squeeze(mean(cellDistributions(defaultFollow + 1,sensAccCtr,:,1,:,timeCtr),3)),...
%                             'LineWidth',2,'LineStyle','-','color',...
%                             plotColors(timeCtr + perturbation*length(timePoints2plot),:));
%                         % plot followers
%                         plot(xBins,squeeze(mean(sum(cellDistributions(defaultFollow + 1,sensAccCtr,:,2:3,:,timeCtr),4),3)),...
%                             'LineWidth',2,'LineStyle','--','Color',get(plotHandles(timeCtr,perturbation+1),'Color'));
                    end
                end
                set(0,'CurrentFigure',migrationProfilesFig);
                grid off
                set(gca,'GridLineStyle','-')
                legend(plotHandles(:),[[num2str(timePoints2plot'),...
                    repmat('h control',length(timePoints2plot),1)];...
                    [num2str(timePoints2plot'),repmat('h perturb',length(timePoints2plot),1)]]);
                xlabel('distance along stream (\mum)')
                ylabel('number of cell (per 50\mum)')
                ylim([0 16])
                
                %% export figure
                exportOptions = struct('Format','eps2',...
                    'Width','15.0',...
                    'Color','rgb',...
                    'Resolution',300,...
                    'FontMode','fixed',...
                    'FontSize',10,...
                    'LineWidth',2);
                
                filename = ['results/experiment37reducedChemotaxis/figures/'...
                    'migrationProfiles_defaultFollow_' num2str(defaultFollow)...
                    'numSteps' num2str(numSteps(1)) '_' num2str(numSteps(2)) ...
                    '_sensAcc_' num2str(sensingAccuracy)];
                set(migrationProfilesFig,'PaperUnits','centimeters');
                exportfig(migrationProfilesFig,[filename '.eps'],exportOptions);
                system(['epstopdf ' filename '.eps']);
                close(migrationProfilesFig)
            end
        end
    end
end