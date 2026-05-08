function updateCustomDataFields(iTrial)
% This function updates the custom data fields for our TwoAFC task
% Take the current trial and the previous trials and calculates a bunch of
% stats etc.

%% Load global variables
global BpodSystem
global TaskParameters

% Cache GUI parameter handle indices on first call — these never change
% during a session and find/strcmp over ~20 names is otherwise repeated
% every trial.
persistent hCache lastRewardMode lastAlphaMode lastMinSampleMode lastTrialSelection;
if isempty(hCache)
    pNames = BpodSystem.GUIData.ParameterGUI.ParamNames;
    hCache.rdTable   = find(strcmp(pNames,'RewardDelayTable'));
    hCache.rdTarget  = find(strcmp(pNames,'RewardDelayTargetTable'));
    hCache.rdInc     = find(strcmp(pNames,'RewardDelayIncrementTable'));
    hCache.alphaInc  = find(strcmp(pNames,'AlphaIncrementTable'));
    hCache.alphaTab  = find(strcmp(pNames,'AlphaTable'));
    hCache.leftBias  = find(strcmp(pNames,'LeftBias'));
    hCache.futBias   = find(strcmp(pNames,'FutureLeftBias'));
    hCache.minSampleInc = find(strcmp(pNames,'MinSampleIncrementTable'));
    hCache.minSampleTab = find(strcmp(pNames,'MinSampleTable'));
    
    lastRewardMode     = '';
    lastAlphaMode      = []; % Use empty to force first-trial update
    lastMinSampleMode  = [];
    lastTrialSelection = '';
end

%% Standard values
BpodSystem.Data.Custom.trialNumber(iTrial)      = iTrial;

BpodSystem.Data.Custom.rewarded(iTrial)         = false;
BpodSystem.Data.Custom.brokeFixation(iTrial)    = false;
BpodSystem.Data.Custom.earlyWithdrawal(iTrial)  = false;

BpodSystem.Data.Custom.choiceLeft(iTrial)       = NaN;
BpodSystem.Data.Custom.choiceCorrect(iTrial)    = NaN;

BpodSystem.Data.Custom.waitDuration(iTrial)     = NaN;
BpodSystem.Data.Custom.fixationTime(iTrial)     = NaN;
BpodSystem.Data.Custom.movementDuration(iTrial)     = NaN;
BpodSystem.Data.Custom.samplingDuration(iTrial) = NaN;
BpodSystem.Data.Custom.lingerDuration(iTrial)   = NaN;

%% Checking states and rewriting standard
statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}...
    (BpodSystem.Data.RawData.OriginalStateData{iTrial});

% Cache the States struct once to avoid repeated deep struct navigation
trialStates = BpodSystem.Data.RawEvents.Trial{end}.States;

for stateI = statesThisTrial
    switch stateI{:}
        case 'stay_Cin'
            BpodSystem.Data.Custom.fixationTime(iTrial) = ...
                diff(trialStates.stay_Cin(1,:));

        case 'stimulus_delivery_min'
            BpodSystem.Data.Custom.samplingDuration(iTrial) = ...
                diff(trialStates.stimulus_delivery_min(1,:));

        case 'stimulus_delivery'
            BpodSystem.Data.Custom.samplingDuration(iTrial) = ...
                trialStates.stimulus_delivery(end,end) - ...
                trialStates.stimulus_delivery_min(1,1);

        case 'wait_Sin'
            BpodSystem.Data.Custom.movementDuration(iTrial) = ...
                diff(trialStates.wait_Sin(1,:));

        case 'rewarded_Lin'
            BpodSystem.Data.Custom.choiceLeft(iTrial)    = 1;
            BpodSystem.Data.Custom.choiceCorrect(iTrial) = 1;
            BpodSystem.Data.Custom.waitDuration(iTrial)  = ...
                trialStates.rewarded_Lin(end,end) - trialStates.rewarded_Lin(1,1);

        case 'rewarded_Rin'
            BpodSystem.Data.Custom.choiceLeft(iTrial)    = 0;
            BpodSystem.Data.Custom.choiceCorrect(iTrial) = 1;
            BpodSystem.Data.Custom.waitDuration(iTrial)  = ...
                trialStates.rewarded_Rin(end,end) - trialStates.rewarded_Rin(1,1);

        case 'lingersInPort_L'
            BpodSystem.Data.Custom.lingerDuration(iTrial) = ...
                trialStates.lingersInPort_L(end,end) - trialStates.lingersInPort_L(1,1);

        case 'lingersInPort_R'
            BpodSystem.Data.Custom.lingerDuration(iTrial) = ...
                trialStates.lingersInPort_R(end,end) - trialStates.lingersInPort_R(1,1);

        case 'unrewarded_Lin'
            BpodSystem.Data.Custom.choiceLeft(iTrial)    = 1;
            BpodSystem.Data.Custom.choiceCorrect(iTrial) = 0;
            BpodSystem.Data.Custom.waitDuration(iTrial)  = ...
                trialStates.unrewarded_Lin(end,end) - trialStates.unrewarded_Lin(1,1);

        case 'unrewarded_Rin'
            BpodSystem.Data.Custom.choiceLeft(iTrial)    = 0;
            BpodSystem.Data.Custom.choiceCorrect(iTrial) = 0;
            BpodSystem.Data.Custom.waitDuration(iTrial)  = ...
                trialStates.unrewarded_Rin(end,end) - trialStates.unrewarded_Rin(1,1);

        case 'broke_fixation'
            BpodSystem.Data.Custom.brokeFixation(iTrial) = true;

        case 'early_withdrawal'
            BpodSystem.Data.Custom.earlyWithdrawal(iTrial) = true;

        case {'water_L','water_R'}
            BpodSystem.Data.Custom.rewarded(iTrial) = true;
    end
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
BpodSystem.Data.Custom.nClicksLeft(iTrial)  = playedLeft;
BpodSystem.Data.Custom.nClicksRight(iTrial) = playedRight;

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
BpodSystem.Data.Custom.fixationDuration(iTrial) = TaskParameters.GUI.StimDelay;
BpodSystem.Data.Custom.rewardDelay(iTrial)  = TaskParameters.GUI.RewardDelay;
BpodSystem.Data.Custom.minSamplingTime(iTrial) = TaskParameters.GUI.MinSampleAud;

BpodSystem.Data.Custom.rewardAmount(iTrial+1,:) = ...
    [TaskParameters.GUI.RewardAmountTable.Left TaskParameters.GUI.RewardAmountTable.Right];


%% Updating Delays - Minimal Sampling Time

if TaskParameters.GUI.MinSampleAudAutoincrement

    history = 50;
    criticalValue = 0.8;

    if iTrial < history
        considerTrials = [];
    else
        idxStart = max(iTrial - history + 1,1);
        considerTrials = idxStart:iTrial;
    end

    minSample  = TaskParameters.GUI.MinSampleTable.Min;
    maxSample  = TaskParameters.GUI.MinSampleTable.Max;
    thisSample = BpodSystem.Data.Custom.minSamplingTime(iTrial);
    increase   = TaskParameters.GUI.MinSampleIncrementTable.Increase;
    decrease   = TaskParameters.GUI.MinSampleIncrementTable.Decrease;

    if ~isempty(considerTrials)
        performance = mean(BpodSystem.Data.Custom.samplingDuration(considerTrials) > TaskParameters.GUI.MinSampleAud);
        completedSampling = ~BpodSystem.Data.Custom.earlyWithdrawal(iTrial) && ...
                            ~BpodSystem.Data.Custom.brokeFixation(iTrial);

        if performance > criticalValue && completedSampling
            TaskParameters.GUI.MinSampleAud = min(maxSample, max(minSample, thisSample + increase));
        elseif performance < criticalValue/2
            TaskParameters.GUI.MinSampleAud = max(minSample, min(maxSample, thisSample - decrease));
        elseif performance < criticalValue && ~completedSampling
            TaskParameters.GUI.MinSampleAud = max(minSample, min(maxSample, thisSample - decrease));
        else
            TaskParameters.GUI.MinSampleAud = max(minSample, min(maxSample, thisSample));
        end
    else
        TaskParameters.GUI.MinSampleAud = max(minSample, min(maxSample, thisSample));
    end
else
    TaskParameters.GUI.MinSampleAud = TaskParameters.GUI.MinSampleTable.Min;
end

%% Updating Delays - Pre Stimulus Delay
TaskParameters.GUI.StimDelay = TruncatedExponential(TaskParameters.GUI.StimDelayTable.Min,...
                                    TaskParameters.GUI.StimDelayTable.Max, ...
                                    TaskParameters.GUI.StimDelayTable.Tau);


%% Updating Delays - Reward delay
% Use cached handle indices; skip Enable/ColumnEditable GUI calls if mode
% hasn't changed — these fire Java repaint listeners even for no-op sets.
params = BpodSystem.GUIHandles.ParameterGUI.Params;
currentMode = TaskParameters.GUIMeta.RewardDelaySelection.String{TaskParameters.GUI.RewardDelaySelection};
modeChanged = ~strcmp(currentMode, lastRewardMode);
lastRewardMode = currentMode;

switch currentMode
    case 'AutoIncrease'
        if modeChanged
            for j = [hCache.rdTable, hCache.rdTarget, hCache.rdInc]
                params(j).Enable = 'on';
                params(j).ColumnEditable(:) = true;
            end
        end

        distHandle   = params(hCache.rdTable);
        targetHandle = params(hCache.rdTarget);
        incHandle    = params(hCache.rdInc);

        TaskParameters.GUI.RewardDelayTable.Min = distHandle.Data(1);
        TaskParameters.GUI.RewardDelayTable.Tau = distHandle.Data(2);
        TaskParameters.GUI.RewardDelayTable.Max = distHandle.Data(3);
        TaskParameters.GUI.RewardDelayTargetTable.Min = targetHandle.Data(1);
        TaskParameters.GUI.RewardDelayTargetTable.Tau = targetHandle.Data(2);
        TaskParameters.GUI.RewardDelayTargetTable.Max = targetHandle.Data(3);
        TaskParameters.GUI.RewardDelayIncrementTable.Min = incHandle.Data(1);
        TaskParameters.GUI.RewardDelayIncrementTable.Tau = incHandle.Data(2);
        TaskParameters.GUI.RewardDelayIncrementTable.Max = incHandle.Data(3);

        if ~BpodSystem.Data.Custom.rewarded(iTrial)
            TaskParameters.GUI.RewardDelay = TruncatedExponential( ...
                TaskParameters.GUI.RewardDelayTable.Min,...
                TaskParameters.GUI.RewardDelayTable.Max, ...
                TaskParameters.GUI.RewardDelayTable.Tau);
        else
            if TaskParameters.GUI.RewardDelayTable.Min < TaskParameters.GUI.RewardDelayTargetTable.Min
                TaskParameters.GUI.RewardDelayTable.Min = ...
                    TaskParameters.GUI.RewardDelayTable.Min + TaskParameters.GUI.RewardDelayIncrementTable.Min;
            end
            if TaskParameters.GUI.RewardDelayTable.Tau < TaskParameters.GUI.RewardDelayTargetTable.Tau
                TaskParameters.GUI.RewardDelayTable.Tau = ...
                    TaskParameters.GUI.RewardDelayTable.Tau + TaskParameters.GUI.RewardDelayIncrementTable.Tau;
            end
            if TaskParameters.GUI.RewardDelayTable.Max < TaskParameters.GUI.RewardDelayTargetTable.Max
                TaskParameters.GUI.RewardDelayTable.Max = ...
                    TaskParameters.GUI.RewardDelayTable.Max + TaskParameters.GUI.RewardDelayIncrementTable.Max;
            end
            distHandle.Data(1) = TaskParameters.GUI.RewardDelayTable.Min;
            distHandle.Data(2) = TaskParameters.GUI.RewardDelayTable.Tau;
            distHandle.Data(3) = TaskParameters.GUI.RewardDelayTable.Max;
        end
        TaskParameters.GUI.RewardDelay = TruncatedExponential(TaskParameters.GUI.RewardDelayTable.Min,...
            TaskParameters.GUI.RewardDelayTable.Max, TaskParameters.GUI.RewardDelayTable.Tau);

    case 'TruncatedExp'
        if modeChanged
            params(hCache.rdTarget).Enable = 'off';
            params(hCache.rdInc).Enable    = 'off';
            params(hCache.rdTable).Enable  = 'on';
            params(hCache.rdTable).ColumnEditable(:) = true;
        end

        distHandle = params(hCache.rdTable);
        TaskParameters.GUI.RewardDelayTable.Min = distHandle.Data(1);
        TaskParameters.GUI.RewardDelayTable.Tau = distHandle.Data(2);
        TaskParameters.GUI.RewardDelayTable.Max = distHandle.Data(3);
        TaskParameters.GUI.RewardDelay = TruncatedExponential(TaskParameters.GUI.RewardDelayTable.Min,...
            TaskParameters.GUI.RewardDelayTable.Max, TaskParameters.GUI.RewardDelayTable.Tau);

    case 'Fix'
        if modeChanged
            params(hCache.rdTarget).Enable = 'off';
            params(hCache.rdInc).Enable    = 'off';
            handle = params(hCache.rdTable);
            handle.ColumnEditable([1 2]) = false;
        end
        TaskParameters.GUI.RewardDelay = TaskParameters.GUI.RewardDelayTable.Max;
end

%% Drawing future trials - Are we in the 'easy trials' at the beginning of a session?

BpodSystem.Data.Custom.startEasyTrials(iTrial) = TaskParameters.GUI.StartEasyTrials;
BpodSystem.Data.Custom.isEasyTrial(iTrial)     = (iTrial <= TaskParameters.GUI.StartEasyTrials);

%% Drawing future trials - Catch trial determination

if ~BpodSystem.Data.Custom.isEasyTrial(iTrial)
    if BpodSystem.Data.Custom.catchTrial(iTrial)
        BpodSystem.Data.Custom.catchTrial(iTrial+1) = false;
    elseif iTrial > 4 && sum(BpodSystem.Data.Custom.rewarded(iTrial-2:iTrial)) == 0
        BpodSystem.Data.Custom.catchTrial(iTrial+1) = false;
    else
        BpodSystem.Data.Custom.catchTrial(iTrial+1) = rand(1,1) < TaskParameters.GUI.ProportionCatch;
    end
else
    BpodSystem.Data.Custom.catchTrial(iTrial+1) = false;
end

%% Drawing future trials - Auditory Stimuli
if iTrial > numel(BpodSystem.Data.Custom.evidenceStrength) - 5

    % Determine the alpha
    if iTrial <= TaskParameters.GUI.StartEasyTrials
        TaskParameters.GUI.AuditoryAlpha = 0.1;
    else
        history = 50;
        currentAlphaMode = TaskParameters.GUI.AlphaAutoincrement && ...
                           iTrial > history && iTrial > TaskParameters.GUI.StartEasyTrials;
        alphaModeChanged = isempty(lastAlphaMode) || (currentAlphaMode ~= lastAlphaMode);
        lastAlphaMode = currentAlphaMode;

        if currentAlphaMode
            if alphaModeChanged
                params(hCache.alphaInc).Enable = 'on';
                params(hCache.alphaTab).ColumnEditable(2) = true;
            end

            idxStart = max(iTrial - history + 1,1);
            considerTrials = idxStart:iTrial;

            correctProportion = sum(BpodSystem.Data.Custom.choiceCorrect(considerTrials), 'omitnan') ...
                                ./ length(considerTrials);
            performanceMet = correctProportion >= 0.80;

            if performanceMet
                if BpodSystem.Data.Custom.rewarded(iTrial)
                    TaskParameters.GUI.AuditoryAlpha = min(max( ...
                        TaskParameters.GUI.AuditoryAlpha + TaskParameters.GUI.AlphaIncrementTable.Increase,...
                        TaskParameters.GUI.AlphaTable.Min),...
                        TaskParameters.GUI.AlphaTable.Max);
                end
            else
                if ~BpodSystem.Data.Custom.rewarded(iTrial) && ...
                   ~BpodSystem.Data.Custom.catchTrial(iTrial)
                    TaskParameters.GUI.AuditoryAlpha = max(min( ...
                        TaskParameters.GUI.AuditoryAlpha - TaskParameters.GUI.AlphaIncrementTable.Decrease, ...
                        TaskParameters.GUI.AlphaTable.Max),...
                        TaskParameters.GUI.AlphaTable.Min);
                end
            end
        else
            if alphaModeChanged
                params(hCache.alphaInc).Enable = 'off';
                params(hCache.alphaTab).ColumnEditable(2) = false;
            end
            TaskParameters.GUI.AuditoryAlpha = TaskParameters.GUI.AlphaTable.Min;
        end
    end

    AuditoryAlpha = TaskParameters.GUI.AuditoryAlpha;

    %% Drawing future trials - Trial bias control

    history = 50;
    idxStart = max(iTrial - history + 1,1);
    considerTrials = idxStart:iTrial;

    try
        rewardIdx       = BpodSystem.Data.Custom.rewarded(considerTrials) == 1;
        rewardCount     = sum(rewardIdx);
        sideProg        = BpodSystem.Data.Custom.sideProgrammed(considerTrials);
        leftIdx         = strcmp(sideProg, 'left');
        leftRewardRatio = sum(rewardIdx & leftIdx) / rewardCount;
    catch
        leftRewardRatio = nan;
    end

    if sum(BpodSystem.Data.Custom.rewarded) > 10
        params(hCache.leftBias).String = num2str(leftRewardRatio);
        TaskParameters.GUI.LeftBias = leftRewardRatio;
    end

    currentTrialSelection = TaskParameters.GUIMeta.TrialSelection.String{TaskParameters.GUI.TrialSelection};
    if iTrial < history
        currentTrialSelection = 'FixedEven'; % Force Even during start
    end
    trialSelectionChanged = ~strcmp(currentTrialSelection, lastTrialSelection);
    lastTrialSelection = currentTrialSelection;

    if iTrial < history
        TaskParameters.GUI.FutureLeftBias = 0.5;
        if trialSelectionChanged
            params(hCache.futBias).Enable = 'off';
            params(hCache.futBias).String = num2str(0.5);
        end
    else
        switch currentTrialSelection
            case 'Even'
                if trialSelectionChanged
                    params(hCache.futBias).String = num2str(0.5);
                    params(hCache.futBias).Enable = 'off';
                end
                TaskParameters.GUI.FutureLeftBias = 0.5;

            case 'Manual'
                if trialSelectionChanged
                    params(hCache.futBias).Enable = 'on';
                end
                TaskParameters.GUI.FutureLeftBias = str2num(params(hCache.futBias).String); %#ok<ST2NM>

            case 'BiasCorrecting'
                if trialSelectionChanged
                    params(hCache.futBias).Enable = 'off';
                end
                desiredBias = min(0.9, max(0.1, (1 - TaskParameters.GUI.LeftBias)));
                TaskParameters.GUI.FutureLeftBias = desiredBias;
                params(hCache.futBias).String = num2str(desiredBias);
        end
    end

    %% Drawing future trials - Draw from the alpha distribution
    generateAuditoryStimuli(5, AuditoryAlpha)

end

% Send auditory stimuli to PulsePal for next trial
if ~BpodSystem.EmulatorMode
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.clickTrainRight{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.clickTrainRight{iTrial+1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.clickTrainLeft{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.clickTrainLeft{iTrial+1}))*5);
end

%% update hidden TaskParameter fields
TaskParameters.Figures.OutcomePlot.Position  = BpodSystem.ProtocolFigures.SideOutcomePlotFig.Position;
TaskParameters.Figures.ParameterGUI.Position = BpodSystem.ProtocolFigures.ParameterGUI.Position;


end % End function updateCustomDataFields



%% Sub functions
function Exp = TruncatedExponential(varargin)

min_value = varargin{1};
max_value = varargin{2};
tau = varargin{3};
if length(varargin) > 3
    m = varargin{4}(1); n = varargin{4}(2);
else
    m = 1; n = 1;
end

Exp = max_value*ones(m*n,1) + 1;
counter = 1;
while any(Exp > (max_value-min_value)) && counter < 10000
    Exp(Exp > (max_value-min_value)) = exprnd(tau, sum(Exp > (max_value-min_value)), 1);
    counter = counter + 1;
end
Exp = Exp + min_value;
Exp = reshape(Exp, m, n);

end % End function TruncatedExponential
