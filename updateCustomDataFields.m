function updateCustomDataFields(iTrial)
% This function updates the custom data fields for our TwoAFC task
% Take the current trial and the previous trials and calculates a bunch of
% stats etc.

%% Load global variables
global BpodSystem
global TaskParameters

%% Standard values
% We set a range of values to be their defaults, they only change if
% neccessary
% Logical or numeric values
BpodSystem.Data.Custom.trialNumber(iTrial)      = iTrial;

BpodSystem.Data.Custom.rewarded(iTrial)         = false;
BpodSystem.Data.Custom.brokeFixation(iTrial)    = false;
BpodSystem.Data.Custom.earlyWithdrawal(iTrial)  = false;

% Possible NaN values
BpodSystem.Data.Custom.choiceLeft(iTrial)       = NaN;
BpodSystem.Data.Custom.choiceCorrect(iTrial)    = NaN;

% Times
BpodSystem.Data.Custom.waitDuration(iTrial)     = NaN;
BpodSystem.Data.Custom.fixationTime(iTrial)     = NaN;
BpodSystem.Data.Custom.movementTime(iTrial)     = NaN;
BpodSystem.Data.Custom.samplingDuration(iTrial) = NaN;
BpodSystem.Data.Custom.lingerDuration(iTrial)   = NaN;

%% Checking states and rewriting standard
statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}...
    (BpodSystem.Data.RawData.OriginalStateData{iTrial});

% Now loop through states and set values depending on state
for stateI = statesThisTrial
    switch stateI{:}
        case 'stay_Cin' % If animal entered centre port, measure fixation time
            BpodSystem.Data.Custom.fixationTime(iTrial) = ...
                diff(BpodSystem.Data.RawEvents.Trial{end}.States.stay_Cin(1,:));

        % If stimulus was triggered
        case 'stimulus_delivery_min'
            BpodSystem.Data.Custom.samplingDuration(iTrial) = ...
                diff(BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min(1,:));
        % If the animal made the full stimulus it is a different state
        case 'stimulus_delivery'
            % Stimulus starts at stimulus_delivery_min and then continues
            % to the end of stimulus_delivery
            BpodSystem.Data.Custom.samplingDuration(iTrial) = ...
                BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery(end,end) - ...
                BpodSystem.Data.RawEvents.Trial{end}.States.stimulus_delivery_min(1,1);

         % How long did the animal take to make a decision (movement time)
        case 'wait_Sin'
            BpodSystem.Data.Custom.movementTime(iTrial) = ...
                diff(BpodSystem.Data.RawEvents.Trial{end}.States.wait_Sin(1,:));

            % Did the animal get a reward?
        case 'rewarded_Lin'
            BpodSystem.Data.Custom.choiceLeft(iTrial) = 1;
            BpodSystem.Data.Custom.choiceCorrect(iTrial) = 1;
            BpodSystem.Data.Custom.waitDuration(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Lin(1,1);

        case 'rewarded_Rin'
            BpodSystem.Data.Custom.choiceLeft(iTrial) = 0;
            BpodSystem.Data.Custom.choiceCorrect(iTrial) = 1;
            BpodSystem.Data.Custom.waitDuration(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.rewarded_Rin(1,1);

        % Did the animal stay in the port post reward?
        case 'lingersInPort_L'
            BpodSystem.Data.Custom.lingerDuration(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.lingersInPort_L(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.lingersInPort_L(1,1);
        case 'lingersInPort_R'
            BpodSystem.Data.Custom.lingerDuration(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.lingersInPort_R(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.lingersInPort_R(1,1);

        case 'unrewarded_Lin'
            BpodSystem.Data.Custom.choiceLeft(iTrial) = 1;
            BpodSystem.Data.Custom.choiceCorrect(iTrial) = 0;
            BpodSystem.Data.Custom.waitDuration(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Lin(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Lin(1,1);

        case 'unrewarded_Rin'
            BpodSystem.Data.Custom.choiceLeft(iTrial) = 0;
            BpodSystem.Data.Custom.choiceCorrect(iTrial) = 0;
            BpodSystem.Data.Custom.waitDuration(iTrial) = ...
            BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Rin(end,end) - ...
            BpodSystem.Data.RawEvents.Trial{end}.States.unrewarded_Rin(1,1);

        case 'broke_fixation'
            BpodSystem.Data.Custom.brokeFixation(iTrial) = true;

        case 'early_withdrawal'
            BpodSystem.Data.Custom.earlyWithdrawal(iTrial) = true;

        case {'water_L','water_R'}
            BpodSystem.Data.Custom.rewarded(iTrial) = true;
    end
end

% Extra catch for water states
if any(strncmp('water_',statesThisTrial,6))
    BpodSystem.Data.Custom.rewarded(iTrial) = true;
end

%% Mismatch detection - clicks actually played vs programmed
% Count only clicks within the animal's sampling window.
% clickTrainLeft/Right are in seconds (PulsePal format).
sampDur = BpodSystem.Data.Custom.samplingDuration(iTrial);
if ~isnan(sampDur)
    playedLeft  = sum(BpodSystem.Data.Custom.clickTrainLeft{iTrial}  <= sampDur);
    playedRight = sum(BpodSystem.Data.Custom.clickTrainRight{iTrial} <= sampDur);
else
    playedLeft  = 0;
    playedRight = 0;
end
BpodSystem.Data.Custom.nClicksLeftPlayed(iTrial)  = playedLeft;
BpodSystem.Data.Custom.nClicksRightPlayed(iTrial) = playedRight;

totalPlayed = playedLeft + playedRight;
if totalPlayed > 0
    if playedLeft > playedRight
        BpodSystem.Data.Custom.sidePlayed{iTrial} = 'left';
    elseif playedRight > playedLeft
        BpodSystem.Data.Custom.sidePlayed{iTrial} = 'right';
    else
        BpodSystem.Data.Custom.sidePlayed{iTrial} = 'none';
    end
else
    BpodSystem.Data.Custom.sidePlayed{iTrial} = 'none';
end

BpodSystem.Data.Custom.evidenceMismatch(iTrial) = ...
    ~strcmp(BpodSystem.Data.Custom.sideProgrammed{iTrial}, ...
            BpodSystem.Data.Custom.sidePlayed{iTrial});

%% State-independent fields
BpodSystem.Data.Custom.stimDelay(iTrial)    = TaskParameters.GUI.StimDelay;
BpodSystem.Data.Custom.rewardDelay(iTrial)  = TaskParameters.GUI.RewardDelay;
BpodSystem.Data.Custom.minSampleAud(iTrial) = TaskParameters.GUI.MinSampleAud;

BpodSystem.Data.Custom.rewardAmount(iTrial+1,:) = ...
    [TaskParameters.GUI.RewardAmountTable.Left TaskParameters.GUI.RewardAmountTable.Right];


%% Updating Delays - Minimal Sampling Time

% min sampling time auditory
if TaskParameters.GUI.MinSampleAudAutoincrement

    % Check the recent trials
    history = 50;
    criticalValue = 0.8;

    % We will only begin updating the sampling after 50 trials
    if iTrial < history
        considerTrials = [];
    else
        idxStart = max(iTrial - history + 1,1);
        considerTrials = idxStart:iTrial;
    end

    minSample  = TaskParameters.GUI.MinSampleTable.Min;
    maxSample  = TaskParameters.GUI.MinSampleTable.Max;
    thisSample = BpodSystem.Data.Custom.minSampleAud(iTrial);
    increase   = TaskParameters.GUI.MinSampleIncrementTable.Increase;
    decrease   = TaskParameters.GUI.MinSampleIncrementTable.Decrease;

    if ~isempty(considerTrials)
        % Did they meet the current sampling minimum on the last 50 trials
        performance = mean(BpodSystem.Data.Custom.samplingDuration(considerTrials)>TaskParameters.GUI.MinSampleAud);
        completedSampling = ~BpodSystem.Data.Custom.earlyWithdrawal(iTrial) && ...
                            ~BpodSystem.Data.Custom.brokeFixation(iTrial);

        if performance > criticalValue && completedSampling % We increase the minimum
            TaskParameters.GUI.MinSampleAud = min(maxSample,...
                    max(minSample,thisSample + increase));
        elseif performance < criticalValue/2
          % If performance is quite bad we always decrease
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

%% Updating Delays - Pre Stimulus Delay
TaskParameters.GUI.StimDelay  = TruncatedExponential(TaskParameters.GUI.StimDelayTable.Min,...
                                    TaskParameters.GUI.StimDelayTable.Max, ...
                                    TaskParameters.GUI.StimDelayTable.Tau);


%% Updating Delays - % Reward delay
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


        if ~BpodSystem.Data.Custom.rewarded(iTrial) % If animal was not rewarded we do not increase
            TaskParameters.GUI.RewardDelay = TruncatedExponential( ...
                                                TaskParameters.GUI.RewardDelayTable.Min,...
                                                TaskParameters.GUI.RewardDelayTable.Max, ...
                                                TaskParameters.GUI.RewardDelayTable.Tau);
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

%% Drawing future trials - Are we in the 'easy trials' at the beginning of a session?

BpodSystem.Data.Custom.startEasyTrials(iTrial) = TaskParameters.GUI.StartEasyTrials;

if iTrial <= TaskParameters.GUI.StartEasyTrials
    BpodSystem.Data.Custom.isEasyTrial(iTrial) = true;
else
    BpodSystem.Data.Custom.isEasyTrial(iTrial) = false;
end


%% Drawing future trials - Catch trial determination

if ~BpodSystem.Data.Custom.isEasyTrial(iTrial)
    if BpodSystem.Data.Custom.catchTrial(iTrial)
        % Don't have two catch trials in a row
        BpodSystem.Data.Custom.catchTrial(iTrial+1) = false;
        % If 3 unrewarded trials in a row, then no catch on the next trial
    elseif iTrial > 4 && sum(BpodSystem.Data.Custom.rewarded(iTrial-2:iTrial))==0
        %no catch on iTrial+1 if Reward(0,0,0) on iTrial(-2:0)
        BpodSystem.Data.Custom.catchTrial(iTrial+1) = false;
    else
        BpodSystem.Data.Custom.catchTrial(iTrial+1) = rand(1,1) < TaskParameters.GUI.ProportionCatch;
    end
else
    BpodSystem.Data.Custom.catchTrial(iTrial+1) = false;
end

%% Drawing future trials - Auditory Stimuli
% We make new trials if there is less than 5 to come...
if iTrial > numel(BpodSystem.Data.Custom.evidenceStrength) - 5

    % Determine the alpha
    if iTrial <= TaskParameters.GUI.StartEasyTrials
        % Easy trials are hardcoded to 0.1
        TaskParameters.GUI.AuditoryAlpha = 0.1;
    else
        history = 50;
        % Are we are automatically adjusting the alpha?
        if TaskParameters.GUI.AlphaAutoincrement && ...
            iTrial > history && iTrial > TaskParameters.GUI.StartEasyTrials

            % We activate the table
            handleIdx = find(strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'AlphaIncrementTable'));
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx).Enable = 'on';

            % Enable all cells
            handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'AlphaTable'));
            handle = BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx);
            handle.ColumnEditable(2) = true;

            idxStart = max(iTrial - history + 1,1);
            considerTrials = idxStart:iTrial;

            performanceCriteria = 0.80;
            correctProportion = nansum(BpodSystem.Data.Custom.choiceCorrect(considerTrials))...
                                ./ length(considerTrials);

            performanceMet = correctProportion >= performanceCriteria;

            % If animal was performing well
            if performanceMet
                % Only increase if trial was rewarded
                if BpodSystem.Data.Custom.rewarded(iTrial)
                    TaskParameters.GUI.AuditoryAlpha = min(max( ...
                        TaskParameters.GUI.AuditoryAlpha + TaskParameters.GUI.AlphaIncrementTable.Increase,...
                        TaskParameters.GUI.AlphaTable.Min),...
                        TaskParameters.GUI.AlphaTable.Max);
                end
            else % Animal is not performing well
                % We only decrease if this trial wasnt rewarded
                if ~BpodSystem.Data.Custom.rewarded(iTrial) && ...
                   ~BpodSystem.Data.Custom.catchTrial(iTrial)
                    % Decrease
                    TaskParameters.GUI.AuditoryAlpha = max(min( ...
                        TaskParameters.GUI.AuditoryAlpha - TaskParameters.GUI.AlphaIncrementTable.Decrease, ...
                        TaskParameters.GUI.AlphaTable.Max),...
                        TaskParameters.GUI.AlphaTable.Min);
                end
            end
        else % We take the set min and deactivate the table
            % Deactivate Fields
            handleIdx = find(strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'AlphaIncrementTable'));
            BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx).Enable = 'off';

            % Now disable the other cells on this table
            handleIdx = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'AlphaTable'));
            handle = BpodSystem.GUIHandles.ParameterGUI.Params(handleIdx);
            handle.ColumnEditable(2) = false;

            TaskParameters.GUI.AuditoryAlpha = TaskParameters.GUI.AlphaTable.Min;
        end
    end

    AuditoryAlpha = TaskParameters.GUI.AuditoryAlpha;

    %% Drawing future trials - Trial bias control

    % Get handles for trial selection control
    leftBiasH    = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'LeftBias') );
    futureBiasH  = find( strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'FutureLeftBias') );

    % Default is to not have manual bias control
    BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).Enable = 'off';

    % Get trial index
    history = 50;
    idxStart = max(iTrial - history + 1,1);
    considerTrials = idxStart:iTrial;

    % Calculate the reward bias
    try
        rewardIdx  = BpodSystem.Data.Custom.rewarded(considerTrials) == 1;
        rewardCount = sum(rewardIdx);
        sideProg   = BpodSystem.Data.Custom.sideProgrammed(considerTrials);
        leftIdx    = strcmp(sideProg, 'left');
        leftRewardIdx = rewardIdx & leftIdx;
        leftRewardRatio = sum(leftRewardIdx) / rewardCount;
    catch
        leftRewardRatio = nan;
    end

    % First we update the rewarded proportion
    if sum(BpodSystem.Data.Custom.rewarded) > 10
        % but only if at least 10 trials have been rewarded
        BpodSystem.GUIHandles.ParameterGUI.Params(leftBiasH).String = ...
            num2str(leftRewardRatio);
        TaskParameters.GUI.LeftBias = leftRewardRatio;
    end

    if iTrial < history % In the first hundred trials we stay even
        TaskParameters.GUI.FutureLeftBias = 0.5;
        BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).Enable = 'off';
    else
        switch TaskParameters.GUIMeta.TrialSelection.String{TaskParameters.GUI.TrialSelection}
                case 'Even'
                    BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).String = num2str(0.5);
                    BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).Enable = 'off';
                    TaskParameters.GUI.FutureLeftBias = 0.5;

                case 'Manual'
                    BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).Enable = 'on';
                    TaskParameters.GUI.FutureLeftBias = str2num(...
                        BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).String);

                case 'BiasCorrecting' % Favors side with fewer rewards. Contrast drawn flat & independently.
                    % We look only at the last 100 trials
                    BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).Enable = 'off';
                    % Calculate the desired bias here
                    % Inverse of left bias with a min of 0.1, max of 0.9
                    desiredBias = min(0.9,max(0.1,(1-TaskParameters.GUI.LeftBias)));
                    TaskParameters.GUI.FutureLeftBias = desiredBias;
                    BpodSystem.GUIHandles.ParameterGUI.Params(futureBiasH).String = ...
                    num2str(desiredBias);
        end
    end

    %% Drawing future trials - Draw from the alpha distribution

    generateAuditoryStimuli(5, AuditoryAlpha)

end

% send auditory stimuli to PulsePal for next trial
if ~BpodSystem.EmulatorMode
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.clickTrainRight{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.clickTrainRight{iTrial+1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.clickTrainLeft{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.clickTrainLeft{iTrial+1}))*5);
end

%% update hidden TaskParameter fields
TaskParameters.Figures.OutcomePlot.Position  = BpodSystem.ProtocolFigures.SideOutcomePlotFig.Position;
TaskParameters.Figures.ParameterGUI.Position = BpodSystem.ProtocolFigures.ParameterGUI.Position;


end % End function update Custom Data Fields



%% Sub functions
function Exp = TruncatedExponential(varargin)

% input values
min_value = varargin{1};
max_value = varargin{2};
tau = varargin{3};
if length(varargin)>3
    m = varargin{4}(1);n = varargin{4}(2);
else
    m=1;n=1;
end

% Initialize to a large value
Exp = max_value*ones(m*n,1)+1;

% sample until in range
counter = 1;
while any(Exp > (max_value-min_value)) && counter < 10000
    Exp(Exp > (max_value-min_value)) = exprnd(tau,sum(Exp > (max_value-min_value)),1);

    counter = counter + 1;
end

%add the offset
Exp = Exp + min_value;


%reshape
Exp = reshape(Exp,m,n);

end % End function TruncatedExponential
