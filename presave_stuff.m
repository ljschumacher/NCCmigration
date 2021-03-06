%% save parameters in otherwise empty results file while simulation is running %%
if isstruct(in)&&ismember('saveInfo',fields(in))
    saveInfo = in.saveInfo;
else
    if exist('conversionType','var')&&conversionType~=0
        if conversionType==4
            saveInfo = [datestr(now,'yyyy_mm_dd-HH_MM'),'_exp_',num2str(param.experiment),'_foll_',num2str(followerFraction,2),'_convert_',mat2str(conversionType),'_steps_',num2str(param.numSteps(1)),'_',num2str(param.numSteps(2)),...
                '_eatRate_',num2str(param.eatRate),'_diff_',num2str(param.diffus)];
        else
            saveInfo = [datestr(now,'yyyy_mm_dd-HH_MM'),'_exp_',num2str(param.experiment),'_foll_',num2str(followerFraction,2),'_convert_',mat2str(conversionType),'_steps_',num2str(param.numSteps),...
                '_eatRate_',num2str(param.eatRate),'_diff_',num2str(param.diffus)];
        end
    else
        saveInfo = [datestr(now,'yyyy_mm_dd-HH_MM'),'_exp_',num2str(param.experiment),'_foll_',num2str(followerFraction,2),...
            '_eatRate_',num2str(param.eatRate),'_diff_',num2str(param.diffus)];
    end
end
% don't overwrite existing file
if isempty(dir(['results/',saveInfo,'.mat'])) % check if this run hasn't been done, if previous sweeps have been aborted
    
    % save parameters in output structure
    out.param = param; 
    out.domainLengths = domainLengths;
    out.saveInfo = saveInfo;
    out.numTsteps = numTsteps;
    out.growingDomain = param.growingDomain;
    out.followerFraction = followerFraction;
    out.tstep = param.tstep;
    out.cellRadius = cellRadius;
    out.domainHeight = param.domainHeight;
    out.filolength = filolength;
    out.leadSpeed = leadSpeed;
    out.followSpeed = followSpeed;
    out.numFilopodia = numFilopodia;
    out.growingDomain = param.growingDomain;
    out.followerFraction = followerFraction;
    out.divide_cells = divide_cells;
    out.experiment = param.experiment;
    [~, computerName] = system('hostname -s');
    computerName = computerName(1:end-1); % remove newline character
    save(['results/',saveInfo,'_running_on_',computerName,'.mat'],'out')
    fprintf(['created results file at results/',saveInfo,'_running_on_',computerName,'.mat \n'])
else
    fprintf(['error in creating results file: results/',saveInfo,'.mat already exists \n'])
end