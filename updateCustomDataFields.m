function updateCustomDataFields(iTrial)
% This function updates the custom data fields for our TwoAFC task
% Take the current trial and the previous trials and calculates a bunch of
% stats etc.

% Currently it is very complicated and long - Am in the process of
% refactoring it to be more readable and clear

%% Load global variables
% Would like to remove this and have it take the BpodSystem as in input
% variable, or else be a method of an object

global BpodSystem
global TaskParameters


%% Standard values
% We set a range of values to be their defaults, they only change if
% neccessary
% Logical or numeric values
BpodSystem.Data.Custom.TrialNumber(iTrial)      = iTrial;

BpodSystem.Data.Custom.ChoiceLeft(iTrial)       = false;
BpodSystem.Data.Custom.ChoiceCorrect(iTrial)    = false;
BpodSystem.Data.Custom.Rewarded(iTrial)         = false;
BpodSystem.Data.Custom.BrokeFixation(iTrial)    = false;
BpodSystem.Data.Custom.EarlyWithdrawal(iTrial)  = false;

% Times
BpodSystem.Data.Custom.ChoicePortTime(iTrial)   = NaN;
BpodSystem.Data.Custom.FixationTime(iTrial)     = NaN;
BpodSystem.Data.Custom.MovementTime(iTrial)     = NaN;
BpodSystem.Data.Custom.SamplingTime(iTrial)     = NaN;
BpodSystem.Data.Custom.LingersTime(iTrial)      = NaN;

%% Checking states and rewriting standard

statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}...
    (BpodSystem.Data.RawData.OriginalStateData{iTrial});

% Now loop through states and set values depending on state
for stateI = statesThisTrial
    switch stateI{:}
        case 'stay_Cin' % If animal entered centre port, measure fixation time
            BpodSystem.Data.Custom.FixationTime(iTrial) = ...
                diff(BpodSystem.Data.RawEvents.Trial{end}.States.stay_Cin(1,:));
        
        % If stimulus was triggered
        case 'stimulus_delivery_min'
            BpodSystem.Data.Custom.SamplingTime(iTrial) = ...
                diff(BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min(1,:));
        % If the animal made the full stimulus it is a different state
        case 'stimulus_delivery'
            BpodSystem.Data.Custom.SamplingTime(iTrial) = ...
                diff(BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery(1,:));

         % How long did the animal take to make a decision (movement time0
        case 'wait_Sin'
            BpodSystem.Data.Custom.MovementTime(end) = ...
                diff(BpodSystem.Data.RawEvents.Trial{end}.States.wait_Sin(1,:));

            % Did the animal get a reward>
        case 'rewarded_Lin'
            BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
            BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
            BpodSystem.Data.Custom.ChoicePortTime(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin(1,1);
        case 'rewarded_Rin'
            BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
            BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 1;
            BpodSystem.Data.Custom.ChoicePortTime(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin(1,1);

        % Did the animal stay in the port post reward?
        case 'lingersInPort_L'
            BpodSystem.Data.Custom.LingersTime(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.lingersInPort_L(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.lingersInPort_L(1,1);
        case 'lingersInPort_R'
            BpodSystem.Data.Custom.LingersTime(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.lingersInPort_R(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.lingersInPort_R(1,1);

        case 'unrewarded_Lin'
            BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
            BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
            BpodSystem.Data.Custom.ChoicePortTime(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Lin(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Lin(1,1);

        case 'unrewarded_Rin'
            BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
            BpodSystem.Data.Custom.ChoiceCorrect(iTrial) = 0;
            BpodSystem.Data.Custom.ChoicePortTime(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Rin(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Rin(1,1);

        case 'broke_fixation'
            BpodSystem.Data.Custom.BrokeFixation(iTrial) = true;

        case 'early_withdrawal'
            BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = true;

        case {'water_L','water_R'}
            BpodSystem.Data.Custom.Rewarded(iTrial) = true;
    end
end

if any(strncmp('water_',statesThisTrial,6))
    BpodSystem.Data.Custom.Rewarded(iTrial) = true;
end

%% State-independent fields
BpodSystem.Data.Custom.StimDelay(iTrial) = TaskParameters.GUI.StimDelay;
BpodSystem.Data.Custom.RewardDelay(iTrial) = TaskParameters.GUI.RewardDelay;
BpodSystem.Data.Custom.MinSampleAud(iTrial) = TaskParameters.GUI.MinSampleAud;

BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,:) = ...
    [TaskParameters.GUI.RewardAmountTable.Left TaskParameters.GUI.RewardAmountTable.Right];

%% Are we in the 'easy trials' at the beginning of a session?

BpodSystem.Data.Custom.StartEasyTrials(iTrial) = TaskParameters.GUI.StartEasyTrials;

if iTrial <= TaskParameters.GUI.StartEasyTrials
    BpodSystem.Data.Custom.IsEasyTrial(iTrial) = true;
else
    BpodSystem.Data.Custom.IsEasyTrial(iTrial) = false;
end


%% Updating Delays
% min sampling time auditory
if TaskParameters.GUI.MinSampleAudAutoincrement 

    % Check the recent trials
    history = 50;
    criticalValue = 0.8;

    idxStart = max(iTrial - history + 1,1);
    considerTrials = idxStart:iTrial;    

    minSample  = TaskParameters.GUI.MinSampleTable.Min;
    maxSample  = TaskParameters.GUI.MinSampleTable.Max;
    thisSample = BpodSystem.Data.Custom.MinSampleAud(iTrial);
    increase   = TaskParameters.GUI.MinSampleIncrementTable.Increase;
    decrease   = TaskParameters.GUI.MinSampleIncrementTable.Decrease;

    if ~isempty(considerTrials)
        % Did they meet the current sampling minimum on the last 50 trials
        performance = mean(BpodSystem.Data.Custom.SamplingTime(considerTrials)>TaskParameters.GUI.MinSampleAud);
        completedSampling = ~BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) && ...
                            ~BpodSystem.Data.Custom.BrokeFixation(iTrial);

        if performance > criticalValue && completedSampling % We increase the minimum
            TaskParameters.GUI.MinSampleAud = min(maxSample,...
                    max(minSample,thisSample + increase));
        elseif performance < criticalValue/2
          % If performance if quite bad we always decrease 
            TaskParameters.GUI.MinSampleAud = max(minSample,...
                    min(maxSample,thisSample - decrease));            
        elseif performance < criticalValue && ~completedSampling
          % If not we decrease (but only if the animal failed sampling)
            TaskParameters.GUI.MinSampleAud = max(minSample,...
                    min(maxSample,thisSample - decrease));        
        else % Default behaviour
            TaskParameters.GUI.MinSampleAud = max(minSample,...
                    min(maxSample,thisSample));
        end
    else % Default behaviour
                  TaskParameters.GUI.MinSampleAud = max(minSample,...
                    min(maxSample,thisSample));
    end
else
    TaskParameters.GUI.MinSampleAud = TaskParameters.GUI.MinSampleTable.Min;
end

TaskParameters.GUI.StimDelay  = TruncatedExponential(TaskParameters.GUI.StimDelayTable.Min,...
                TaskParameters.GUI.StimDelayTable.Max, TaskParameters.GUI.StimDelayTable.Tau);

% Update GUI
paramIdx    = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'StimDelay');
paramHandle = BpodSystem.GUIHandles.ParameterGUI.Params(paramIdx);
paramHandle.String = num2str(TaskParameters.GUI.StimDelay);


% Reward delay
switch TaskParameters.GUIMeta.RewardDelaySelection.String{TaskParameters.GUI.RewardDelaySelection}
    % Change depending on the reward delay method
    case 'AutoIncrease'
        % Activate Increment and target fields        
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTable') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTargetTable') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrementTable') );
        for j = 1:length(handleIdx)
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx(j)).Enable = 'on';
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx(j)).ColumnEditable(:) = true;
        end
        
        % Get the handles to the table
        paramIdx     = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTable');
        distHandle   = BpodSystem.GUIHandles.ParameterGUI.Params(paramIdx);
        
        paramIdx     = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTargetTable');
        targetHandle = BpodSystem.GUIHandles.ParameterGUI.Params(paramIdx);

        paramIdx     = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrementTable');
        incHandle    = BpodSystem.GUIHandles.ParameterGUI.Params(paramIdx);

        % Update the internal values to match the GUI
        % Distribution
        TaskParameters.GUI.RewardDelayTable.Min = distHandle.Data(1);
        TaskParameters.GUI.RewardDelayTable.Tau = distHandle.Data(2);
        TaskParameters.GUI.RewardDelayTable.Max = distHandle.Data(3);
        % Target
        TaskParameters.GUI.RewardDelayTargetTable.Min = targetHandle.Data(1);
        TaskParameters.GUI.RewardDelayTargetTable.Tau = targetHandle.Data(2);
        TaskParameters.GUI.RewardDelayTargetTable.Max = targetHandle.Data(3);
        % Increment
        TaskParameters.GUI.RewardDelayIncrementTable.Min = incHandle.Data(1);
        TaskParameters.GUI.RewardDelayIncrementTable.Tau = incHandle.Data(2);
        TaskParameters.GUI.RewardDelayIncrementTable.Max = incHandle.Data(3);
        

        if ~BpodSystem.Data.Custom.Rewarded(iTrial) % If animal was not rewarded we do not increase
            TaskParameters.GUI.RewardDelay = TruncatedExponential(TaskParameters.GUI.RewardDelayTable.Min,...
                TaskParameters.GUI.RewardDelayTable.Max,TaskParameters.GUI.RewardDelayTable.Tau);
        else % Otherwise increase the current set times
            if TaskParameters.GUI.RewardDelayTable.Min < TaskParameters.GUI.RewardDelayTargetTable.Min
                % Update value
                TaskParameters.GUI.RewardDelayTable.Min = ...
                    TaskParameters.GUI.RewardDelayTable.Min + TaskParameters.GUI.RewardDelayIncrementTable.Min;             
            end
            if TaskParameters.GUI.RewardDelayTable.Tau < TaskParameters.GUI.RewardDelayTargetTable.Tau
                % Update value
                TaskParameters.GUI.RewardDelayTable.Tau = ...
                    TaskParameters.GUI.RewardDelayTable.Tau + TaskParameters.GUI.RewardDelayIncrementTable.Tau;
            end
            if TaskParameters.GUI.RewardDelayTable.Max < TaskParameters.GUI.RewardDelayTargetTable.Max
                % Update value
                TaskParameters.GUI.RewardDelayTable.Max = ...
                    TaskParameters.GUI.RewardDelayTable.Max + TaskParameters.GUI.RewardDelayIncrementTable.Max;           
            end 
            
            % Update GUI - Min
            distHandle.Data(1) = TaskParameters.GUI.RewardDelayTable.Min;  
            % Tau
            distHandle.Data(2) = TaskParameters.GUI.RewardDelayTable.Tau;    
            % Max
            distHandle.Data(3) = TaskParameters.GUI.RewardDelayTable.Max;

        end
        % And generate a new Reward Delay value
        TaskParameters.GUI.RewardDelay = TruncatedExponential(TaskParameters.GUI.RewardDelayTable.Min,...
            TaskParameters.GUI.RewardDelayTable.Max,TaskParameters.GUI.RewardDelayTable.Tau);
        
    case 'TruncatedExp'
        %  Deactivate Fields
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTargetTable') | ...
                     strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrementTable') );
        for hI = 1:length(handleIdx)
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx(hI)).Enable = 'off';            
        end
        
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTable') );
        BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx).Enable = 'on';
        BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx).ColumnEditable(:) = true;

        % Get the handles to the table
        paramIdx     = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTable');
        distHandle   = BpodSystem.GUIHandles.ParameterGUI.Params(paramIdx);
    
        % Update the internal values to match the GUI
        % Distribution
        TaskParameters.GUI.RewardDelayTable.Min = distHandle.Data(1);
        TaskParameters.GUI.RewardDelayTable.Tau = distHandle.Data(2);
        TaskParameters.GUI.RewardDelayTable.Max = distHandle.Data(3);

        % Actual delay is from a truncated exp.
        TaskParameters.GUI.RewardDelay = TruncatedExponential(TaskParameters.GUI.RewardDelayTable.Min,...
            TaskParameters.GUI.RewardDelayTable.Max,TaskParameters.GUI.RewardDelayTable.Tau);

    case 'Fix'
        % Deactivate Fields
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTargetTable') | ...
                          strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayIncrementTable') );
                      
        for hI = 1:length(handleIdx)
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx(hI)).Enable = 'off';
        end

        % Now disable the other cells on this table
        handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelayTable'));
        handle = BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx);
        handle.ColumnEditable([1 2]) = false;

        % Actual delay is simply the max
        TaskParameters.GUI.RewardDelay = TaskParameters.GUI.RewardDelayTable.Max;
end


% Update Displayed Current Value
paramIdx    = strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'RewardDelay');
paramHandle = BpodSystem.GUIHandles.ParameterGUI.Params(paramIdx);
paramHandle.String = num2str(TaskParameters.GUI.RewardDelay);

%% Drawing future trials

% Catch trial calculations
% determine if catch trial
if iTrial > TaskParameters.GUI.StartEasyTrials
    
    if BpodSystem.Data.Custom.CatchTrial(iTrial)
        % Don't have two catch trials in a row
        BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;     
    % (RMM) If 3 unrewarded trials in a row, then no catch on the next trial
    elseif iTrial > 4 && sum(BpodSystem.Data.Custom.Rewarded(iTrial-2:iTrial))==0 
        %no catch on iTrial+1 if Reward(0,0,0) on iTrial(-2:0)
        BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;    
    else
        BpodSystem.Data.Custom.CatchTrial(iTrial+1) = rand(1,1) < TaskParameters.GUI.ProportionCatch;
    end
else
    BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;     
end

%% create future trials

% Trial bias control
% Get handles for trial selection control
leftBiasH    = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'LeftBias') );                
futureBiasH  = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'FurtureLeftBias') ); 

% Get trial index
history = 100;        
idxStart = max(iTrial - history + 1,1);
considerTrials = idxStart:iTrial; 

% Calculate the reward bias
try
    rewardIdx  = BpodSystem.Data.Custom.Rewarded(considerTrials) == 1;     
    rewardCount = sum(rewardIdx);
    leftIdx    = BpodSystem.Data.Custom.MoreLeftClicks(considerTrials) == 1;
    leftCount  = sum(leftIdx);
    leftRewardIdx = rewardIdx & leftIdx;
    leftRewardRatio = sum(leftRewardIdx) / rewardCount;
catch
    leftRewardRatio = nan;
end

% First we update the rewarded proportion
if sum(BpodSystem.Data.Custom.Rewarded) > 10 
    % but only if at least 10 trials have been rewarded
    BpodSystem.GUIHandles.ParameterGUI.Params(leftBiasH).String = ...
        num2str(leftRewardRatio);
    TaskParameters.GUI.LeftBias = leftRewardRatio;
end

% We make new trials if there is less than 5 to come...
if iTrial > numel(BpodSystem.Data.Custom.DV) - 5
    latestTrial = numel(BpodSystem.Data.Custom.DV);   

    switch TaskParameters.GUIMeta.TrialSelection.String{TaskParameters.GUI.TrialSelection}
        case 'Even'         
            BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).String = num2str(0.5); 
            BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).Enable = 'off';       
            TaskParameters.GUI.FurtureLeftBias = 0.5;

        case 'Manual'          
            BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).Enable = 'on';    
            TaskParameters.GUI.FurtureLeftBias = str2num(...
                BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).String);
        
        case 'BiasCorrecting' % Favors side with fewer rewards. Contrast drawn flat & independently.
            % We look only at the last 100 trials
            BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).Enable = 'off';   
            % Calculate the desired bias here 
            % Inverse of left bias with a min of 0.1, max of 0.9
            desiredBias = min(0.9,max(0.1,(1-TaskParameters.GUI.LeftBias)));
            TaskParameters.GUI.FurtureLeftBias = desiredBias;
            BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).String = ...
                num2str(desiredBias);
    end
        
    % make future trials
    if iTrial > TaskParameters.GUI.StartEasyTrials
        AuditoryAlpha = TaskParameters.GUI.AuditoryAlpha;
    else
        AuditoryAlpha = TaskParameters.GUI.AuditoryAlpha/4;
        % AuditoryAlpha = 0.1;
    end
    
    BetaRatio = TaskParameters.GUI.FurtureLeftBias / ...
                (1 - TaskParameters.GUI.FurtureLeftBias);
    
    % BetaRatio = (1 - min(0.9,max(0.1,TaskParameters.GUI.LeftBias))) / ...
    %                  min(0.9,max(0.1,TaskParameters.GUI.LeftBias)); 

    % use a = ratio*b to yield E[X] = LeftBiasAud using Beta(a,b) pdf
    % cut off between 0.1-0.9 to prevent extreme values (only one side) and div by 
    
    BetaA =  (2*AuditoryAlpha*BetaRatio) / (1+BetaRatio); %make a,b symmetric around AuditoryAlpha to make B symmetric
    BetaB = (AuditoryAlpha-BetaA) + AuditoryAlpha;

    for a = 1:5
        if rand(1,1) < TaskParameters.GUI.Proportion50Fifty && iTrial > TaskParameters.GUI.StartEasyTrials
            BpodSystem.Data.Custom.AuditoryOmega(latestTrial+a) = 0.5;
        else
            BpodSystem.Data.Custom.AuditoryOmega(latestTrial+a) = betarnd(max(0,BetaA),max(0,BetaB),1,1); %prevent negative parameters
        end
        % RMM 16.05.23 - Adding a new field to record the effective
        %alpha (which depends on the StartEasyTrial)
        BpodSystem.Data.Custom.EffectiveAlpha(latestTrial+a) = AuditoryAlpha;
        % RMM
        BpodSystem.Data.Custom.LeftClickRate(latestTrial+a) = ...
            round(BpodSystem.Data.Custom.AuditoryOmega(latestTrial+a).*TaskParameters.GUI.SumRates); 
        BpodSystem.Data.Custom.RightClickRate(latestTrial+a) = ...
            round((1-BpodSystem.Data.Custom.AuditoryOmega(latestTrial+a)).*TaskParameters.GUI.SumRates);
        BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a} = ...
            GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(latestTrial+a), TaskParameters.GUI.AuditoryStimulusTime);
        BpodSystem.Data.Custom.RightClickTrain{latestTrial+a} = ...
            GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(latestTrial+a), TaskParameters.GUI.AuditoryStimulusTime);
        
        %correct left/right click train
        if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{latestTrial+a})
            BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}(1),BpodSystem.Data.Custom.RightClickTrain{latestTrial+a}(1));
            BpodSystem.Data.Custom.RightClickTrain{latestTrial+a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}(1),BpodSystem.Data.Custom.RightClickTrain{latestTrial+a}(1));
        elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{latestTrial+a})
            BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}(1) = BpodSystem.Data.Custom.RightClickTrain{latestTrial+a}(1);
        elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}) &&  isempty(BpodSystem.Data.Custom.RightClickTrain{latestTrial+a})
            BpodSystem.Data.Custom.RightClickTrain{latestTrial+a}(1) = BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}(1);
        else
            BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a} = round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
            BpodSystem.Data.Custom.RightClickTrain{latestTrial+a} = round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
        end
        if length(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}) > length(BpodSystem.Data.Custom.RightClickTrain{latestTrial+a})
            BpodSystem.Data.Custom.MoreLeftClicks(latestTrial+a) = 1;
        elseif length(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}) < length(BpodSystem.Data.Custom.RightClickTrain{latestTrial+a})
            BpodSystem.Data.Custom.MoreLeftClicks(latestTrial+a) = 0;
        else
            BpodSystem.Data.Custom.MoreLeftClicks(latestTrial+a) = NaN;
        end
        BpodSystem.Data.Custom.DV(latestTrial+a) = (length(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}) - length(BpodSystem.Data.Custom.RightClickTrain{latestTrial+a}))./(length(BpodSystem.Data.Custom.LeftClickTrain{latestTrial+a}) + length(BpodSystem.Data.Custom.RightClickTrain{latestTrial+a}));
    end   
end 

% send auditory stimuli to PulsePal for next trial
if ~BpodSystem.EmulatorMode
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}))*5);
end

%%update hidden TaskParameter fields
TaskParameters.Figures.OutcomePlot.Position  = BpodSystem.ProtocolFigures.SideOutcomePlotFig.Position;
TaskParameters.Figures.ParameterGUI.Position = BpodSystem.ProtocolFigures.ParameterGUI.Position;


end
