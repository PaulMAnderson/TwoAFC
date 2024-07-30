function updateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters

%% Standard values
BpodSystem.Data.Custom.ChoiceLeft(iTrial) = NaN;
BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = NaN;
BpodSystem.Data.Custom.Reward(iTrial) = true;
BpodSystem.Data.Custom.RewardTime(iTrial) = NaN;
BpodSystem.Data.Custom.FixBroke(iTrial) = false;
BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = false;
BpodSystem.Data.Custom.FixDur(iTrial) = NaN;
BpodSystem.Data.Custom.MT(iTrial) = NaN;
BpodSystem.Data.Custom.ST(iTrial) = NaN;
BpodSystem.Data.Custom.Rewarded(iTrial) = false;
BpodSystem.Data.Custom.TrialNumber(iTrial) = iTrial;

%RMM 16.05.23
BpodSystem.Data.Custom.StartEasyTrial(iTrial) = TaskParameters.GUI.StartEasyTrials;
if iTrial <= TaskParameters.GUI.StartEasyTrials
    BpodSystem.Data.Custom.IsEasyTrial(iTrial) = true;
else
    BpodSystem.Data.Custom.IsEasyTrial(iTrial) = false;
end
%RMM

%% Checking states and rewriting standard
statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});
if any(strcmp('stay_Cin',statesThisTrial))
    BpodSystem.Data.Custom.FixDur(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stay_Cin);
end
if any(strcmp('stimulus_delivery_min',statesThisTrial))
    if any(strcmp('stimulus_delivery',statesThisTrial))
        BpodSystem.Data.Custom.ST(iTrial) = BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery(1,2) - BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min(1,1);
    else
        BpodSystem.Data.Custom.ST(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min);
    end
end
if any(strcmp('wait_Sin',statesThisTrial))
    BpodSystem.Data.Custom.MT(end) = diff(BpodSystem.Data.RawEvents.Trial{end}.States.wait_Sin);
end
if any(strcmp('rewarded_Lin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
    RewardPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin;
    BpodSystem.Data.Custom.RewardTime(iTrial) = RewardPortTimes(end,end)-RewardPortTimes(1,1);
    % RMM 17.05.23 - Previous to this date, time spent on the port after
    % receiving reward was not being saved in SessionData (but it can be
    % retrieved from the spike2 file)
    if any(strcmp('lingersInPort_L',statesThisTrial))
        RewardPortLingerTimes = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin;
        BpodSystem.Data.Custom.timeLingersInPort(iTrial) = RewardPortLingerTimes(end,end)-RewardPortLingerTimes(1,1);
    else
        BpodSystem.Data.Custom.timeLingersInPort(iTrial) = nan;
    end
    % RMM
elseif any(strcmp('rewarded_Rin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
    RewardPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin;
    BpodSystem.Data.Custom.RewardTime(iTrial) = RewardPortTimes(end,end)-RewardPortTimes(1,1);
    % RMM 17.05.23 - Previous to this date, time spent on the port after
    % receiving reward was not being saved in SessionData (but it can be
    % retrieved from the spike2 file)
    if any(strcmp('lingersInPort_R',statesThisTrial))
        RewardPortLingerTimes = BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin;
        BpodSystem.Data.Custom.timeLingersInPort(iTrial) = RewardPortLingerTimes(end,end)-RewardPortLingerTimes(1,1);
    else
        BpodSystem.Data.Custom.timeLingersInPort(iTrial) = nan;
    end
    % RMM
elseif any(strcmp('unrewarded_Lin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
    RewardPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Lin;
    BpodSystem.Data.Custom.RewardTime(iTrial) = RewardPortTimes(end,end)-RewardPortTimes(1,1);
elseif any(strcmp('unrewarded_Rin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
    RewardPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Rin;
    BpodSystem.Data.Custom.RewardTime(iTrial) = RewardPortTimes(end,end)-RewardPortTimes(1,1);
elseif any(strcmp('broke_fixation',statesThisTrial))
    BpodSystem.Data.Custom.FixBroke(iTrial) = true;
elseif any(strcmp('early_withdrawal',statesThisTrial))
    BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = true;
end

% RMM
if any(strcmp('skipped_feedbackCorrectChoice',statesThisTrial))
    BpodSystem.Data.Custom.Reward(iTrial) = false;
end
% RMM

if any(strcmp('missed_choice',statesThisTrial))
    BpodSystem.Data.Custom.Reward(iTrial) = false;
end
if any(strcmp('skipped_reward',statesThisTrial))
    BpodSystem.Data.Custom.Reward(iTrial) = false;
end
if any(strncmp('water_',statesThisTrial,6))
    BpodSystem.Data.Custom.Rewarded(iTrial) = true;
end

%% State-independent fields
BpodSystem.Data.Custom.StimDelay(iTrial) = TaskParameters.GUI.StimDelay;
BpodSystem.Data.Custom.RewardDelay(iTrial) = TaskParameters.GUI.RewardDelay;
BpodSystem.Data.Custom.MinSampleAud(iTrial) = TaskParameters.GUI.MinSampleAud;

BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,1) = TaskParameters.GUI.RewardAmountL;

BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,2) = TaskParameters.GUI.RewardAmountR;

%% Updating Delays
%stimulus delay

TaskParameters.GUI.StimDelay  = TruncatedExponential(TaskParameters.GUI.StimDelayMin,...
                TaskParameters.GUI.StimDelayMax, TaskParameters.GUI.StimDelayTau);

%min sampling time auditory
if TaskParameters.GUI.MinSampleAudAutoincrement 
    History = 50;
    Crit = 0.8;
    if length(BpodSystem.Data.Custom.ChoiceLeft)<10
        ConsiderTrials = iTrial;
    else
        idxStart = iTrial - History + 1;
        if idxStart < 1
            ConsiderTrials = 1:iTrial;
        else
            ConsiderTrials = idxStart:iTrial;
        end
    end

    ConsiderTrials = ConsiderTrials((~isnan(BpodSystem.Data.Custom.ChoiceLeft(ConsiderTrials))...
                    |BpodSystem.Data.Custom.EarlyWithdrawal(ConsiderTrials))); %choice + early withdrawal + auditory trials
    if ~isempty(ConsiderTrials)
        if mean(BpodSystem.Data.Custom.ST(ConsiderTrials)>TaskParameters.GUI.MinSampleAud) > Crit
            if ~BpodSystem.Data.Custom.EarlyWithdrawal(iTrial)
                TaskParameters.GUI.MinSampleAud = min(TaskParameters.GUI.MinSampleAudMax,...
                    max(TaskParameters.GUI.MinSampleAudMin,BpodSystem.Data.Custom.MinSampleAud(iTrial) + TaskParameters.GUI.MinSampleAudIncr));
            end
        elseif mean(BpodSystem.Data.Custom.ST(ConsiderTrials)>TaskParameters.GUI.MinSampleAud) < Crit/2
            if BpodSystem.Data.Custom.EarlyWithdrawal(iTrial)
                TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
                	min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.MinSampleAud(iTrial) - TaskParameters.GUI.MinSampleAudDecr));
            end
        else
            TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
                	min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.MinSampleAud(iTrial)));
        end
    else
        TaskParameters.GUI.MinSampleAud = max(TaskParameters.GUI.MinSampleAudMin,...
                	min(TaskParameters.GUI.MinSampleAudMax,BpodSystem.Data.Custom.MinSampleAud(iTrial)));
    end
else
    TaskParameters.GUI.MinSampleAud = TaskParameters.GUI.MinSampleAudMin;
end

%% Reward delay
switch TaskParameters.GUIMeta.RewardDelaySelection.String{TaskParameters.GUI.RewardDelaySelection}
    case 'AutoIncrease'
        % Activate Increment and target fields
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMin') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTau') | ...     
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMinTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTauTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMaxTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrMinTau') | ...    
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrMax') );
        for hI = 1:length(handleIdx)
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx(hI)).Enable = 'on';
        end

        if ~BpodSystem.Data.Custom.Reward(iTrial) % If animal dropped out, do not increase
            TaskParameters.GUI.RewardDelay = TruncatedExponential(TaskParameters.GUI.RewardDelayMin,...
                TaskParameters.GUI.RewardDelayMax,TaskParameters.GUI.RewardDelayTau);
        else % Otherwise increase the current set times
            if TaskParameters.GUI.RewardDelayMin < TaskParameters.GUI.RewardDelayMinTarget
                % Update value
                TaskParameters.GUI.RewardDelayMin = ...
                    TaskParameters.GUI.RewardDelayMin + TaskParameters.GUI.RewardDelayIncrMinTau;
                % Update GUI    
                paramIdx    = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMin');
                paramHandle = BpodSystem.GUIHandles.ParameterGUI.Params{paramIdx};
                paramHandle.String = num2str(TaskParameters.GUI.RewardDelayMin);                
            end
            if TaskParameters.GUI.RewardDelayTau < TaskParameters.GUI.RewardDelayTauTarget
                TaskParameters.GUI.RewardDelayTau = ...
                    TaskParameters.GUI.RewardDelayTau + TaskParameters.GUI.RewardDelayIncrMinTau;
                % Update GUI    
                paramIdx    = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTau');
                paramHandle = BpodSystem.GUIHandles.ParameterGUI.Params{paramIdx};
                paramHandle.String = num2str(TaskParameters.GUI.RewardDelayTau);    
            end   
            if TaskParameters.GUI.RewardDelayMax < TaskParameters.GUI.RewardDelayMaxTarget
                TaskParameters.GUI.RewardDelayMax = ...
                    TaskParameters.GUI.RewardDelayMax + TaskParameters.GUI.RewardDelayIncrMax;
                if TaskParameters.GUI.RewardDelayMax == TaskParameters.GUI.RewardDelayMin
                    TaskParameters.GUI.RewardDelayMin = TaskParameters.GUI.RewardDelayMin - TaskParameters.GUI.RewardDelayIncrMinTau;
                end
                % Update GUI    
                paramIdx    = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMax');
                paramHandle = BpodSystem.GUIHandles.ParameterGUI.Params{paramIdx};
                paramHandle.String = num2str(TaskParameters.GUI.RewardDelayMax); 
            end   
            % And generate a new Reward Delay value
             TaskParameters.GUI.RewardDelay = TruncatedExponential(TaskParameters.GUI.RewardDelayMin,...
                TaskParameters.GUI.RewardDelayMax,TaskParameters.GUI.RewardDelayTau);
        end
    case 'TruncatedExp'
        %     ATTEMPT TO GRAY OUT FIELDS
        % Activate Increment and target fields
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMinTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTauTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMaxTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrMinTau') | ...    
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrMax') );
        for hI = 1:length(handleIdx)
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx(hI)).Enable = 'off';
        end
        
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMin') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTau') );
        for hI = 1:length(handleIdx)
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx(hI)).Enable = 'on';
        end
        
            TaskParameters.GUI.RewardDelay = TruncatedExponential(TaskParameters.GUI.RewardDelayMin,...
                TaskParameters.GUI.RewardDelayMax,TaskParameters.GUI.RewardDelayTau);
    case 'Fix'
        %     ATTEMPT TO GRAY OUT FIELDS
        % De-activate Increment and target fields
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMin') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTau') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMinTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTauTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayMaxTarget') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrMinTau') | ...    
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrMax') );
                      
        for hI = 1:length(handleIdx)
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx(hI)).Enable = 'off';
        end
        
        TaskParameters.GUI.RewardDelay = TaskParameters.GUI.RewardDelayMax;
end

%% Drawing future trials

% Catch trial calculations


% (RMM) Creating a better strategy for catch trials:
% The problem here is that the result of the current trial is not yet
% known, as the animal is still on it. So the rule must rely on the results
% of trials previous to the current one (iTrial(-N:-1).

%determine if catch trial
if iTrial > TaskParameters.GUI.StartEasyTrials
    
    if BpodSystem.Data.Custom.CatchTrial(iTrial)
        % Don't have two catch trials in a row
        BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;
        
    % (RMM) If 3 (or 4) unrewarded trials in a row, then no catch on the next trial
    elseif iTrial > 5 && sum(BpodSystem.Data.Custom.Rewarded(iTrial-3:iTrial-1))==0 %no catch on iTrial+1 if Reward(0,0,0) on iTrial(-3:-1)
        % THere is still a chance of eg Reward(1,0,0) on iTrial(-3:-1) and
        % Reward (0) on iTrial to produce a catch on (iTrial+1). In that
        % case, it would be Reward (0,0,0) and catch on the new iTrial.
        % Because that would rarely occur, it's OK.
        BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;
    
    else
        BpodSystem.Data.Custom.CatchTrial(iTrial+1) = rand(1,1) < TaskParameters.GUI.PercentCatch;
    end
    
else
    BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;
end


%create future trials
if iTrial > numel(BpodSystem.Data.Custom.DV) - 5
    
    lastidx = numel(BpodSystem.Data.Custom.DV);
    
    switch TaskParameters.GUIMeta.TrialSelection.String{TaskParameters.GUI.TrialSelection}
        case 'Even'
            TaskParameters.GUI.LeftBiasAud = 0.5;
        case 'Manual'
        case 'BiasCorrecting' % Favors side with fewer rewards. Contrast drawn flat & independently.
            %auditory
            ndxRewd = BpodSystem.Data.Custom.Rewarded(1:iTrial) == 1;
            if sum(ndxRewd)>10
                TaskParameters.GUI.LeftBiasAud = sum(BpodSystem.Data.Custom.MoreLeftClicks(1:iTrial)==1&ndxRewd) / sum(ndxRewd);
            else
                TaskParameters.GUI.LeftBiasAud = 0.5;
            end
    end
        
    % make future auditory trials
    if iTrial > TaskParameters.GUI.StartEasyTrials
        AuditoryAlpha = TaskParameters.GUI.AuditoryAlpha;
    else
        AuditoryAlpha = TaskParameters.GUI.AuditoryAlpha/4;
    end
    
    BetaRatio = (1 - min(0.9,max(0.1,TaskParameters.GUI.LeftBiasAud))) / min(0.9,max(0.1,TaskParameters.GUI.LeftBiasAud)); %use a = ratio*b to yield E[X] = LeftBiasAud using Beta(a,b) pdf
                                                                                          %cut off between 0.1-0.9 to prevent extreme values (only one side) and div by zero
    BetaA =  (2*AuditoryAlpha*BetaRatio) / (1+BetaRatio); %make a,b symmetric around AuditoryAlpha to make B symmetric
    BetaB = (AuditoryAlpha-BetaA) + AuditoryAlpha;
    for a = 1:5
        if rand(1,1) < TaskParameters.GUI.Proportion50Fifty && iTrial > TaskParameters.GUI.StartEasyTrials
            BpodSystem.Data.Custom.AuditoryOmega(lastidx+a) = 0.5;
        else
            BpodSystem.Data.Custom.AuditoryOmega(lastidx+a) = betarnd(max(0,BetaA),max(0,BetaB),1,1); %prevent negative parameters
        end
        % RMM 16.05.23 - Adding a new field to record the effective
        %alpha (which depends on the StartEasyTrial)
        BpodSystem.Data.Custom.EffectiveAlpha(lastidx+a) = AuditoryAlpha;
        % RMM
        BpodSystem.Data.Custom.LeftClickRate(lastidx+a) = round(BpodSystem.Data.Custom.AuditoryOmega(lastidx+a).*TaskParameters.GUI.SumRates); 
        BpodSystem.Data.Custom.RightClickRate(lastidx+a) = round((1-BpodSystem.Data.Custom.AuditoryOmega(lastidx+a)).*TaskParameters.GUI.SumRates);
        BpodSystem.Data.Custom.LeftClickTrain{lastidx+a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(lastidx+a), TaskParameters.GUI.AuditoryStimulusTime);
        BpodSystem.Data.Custom.RightClickTrain{lastidx+a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(lastidx+a), TaskParameters.GUI.AuditoryStimulusTime);
        %correct left/right click train
        if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
            BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1),BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1));
            BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1),BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1));
        elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
            BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1) = BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1);
        elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) &&  isempty(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
            BpodSystem.Data.Custom.RightClickTrain{lastidx+a}(1) = BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}(1);
        else
            BpodSystem.Data.Custom.LeftClickTrain{lastidx+a} = round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
            BpodSystem.Data.Custom.RightClickTrain{lastidx+a} = round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
        end
        if length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) > length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
            BpodSystem.Data.Custom.MoreLeftClicks(lastidx+a) = 1;
        elseif length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) < length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a})
            BpodSystem.Data.Custom.MoreLeftClicks(lastidx+a) = 0;
        else
            BpodSystem.Data.Custom.MoreLeftClicks(lastidx+a) = NaN;
        end
    end%for a=1:5
    
    % cross-modality difficulty for plotting
    for a = 1 : 5       
        BpodSystem.Data.Custom.DV(lastidx+a) = (length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) - length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a}))./(length(BpodSystem.Data.Custom.LeftClickTrain{lastidx+a}) + length(BpodSystem.Data.Custom.RightClickTrain{lastidx+a}));
    end
    
end%if trial > - 5

% send auditory stimuli to PulsePal for next trial
if ~BpodSystem.EmulatorMode
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}))*5);
end

%%update hidden TaskParameter fields
TaskParameters.Figures.OutcomePlot.Position = BpodSystem.ProtocolFigures.SideOutcomePlotFig.Position;
TaskParameters.Figures.ParameterGUI.Position = BpodSystem.ProtocolFigures.ParameterGUI.Position;

end
