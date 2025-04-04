function TwoAFC
% 2-AFC discrimination task implemented for latest Bpod https://github.com/sanworks/Bpod
% Designed to be a cleaner and simpler version for just audio decision for
% use in the Klausberger lab

set(0,'defaultfigurecolor',[1 1 1])
global BpodSystem

%% Task parameters
global TaskParameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    %% General
    TaskParameters.GUI.ITI = 0; % (s)
    TaskParameters.GUI.TimeToChoose = 20;
    TaskParameters.GUIMeta.TimeToChoose.Label = 'Time to make choice';
    TaskParameters.GUI.TimeOutIncorrect = 3; % (s)
    TaskParameters.GUIMeta.TimeOutIncorrect.Label = 'Timeout for Incorrect';
    TaskParameters.GUI.TimeOutBrokeFixation = 3; % (s)
    TaskParameters.GUIMeta.TimeOutBrokeFixation.Label = 'Timeout for Sampling Dropout';
    TaskParameters.GUI.TimeOutSkippedReward = 0; % (s) 
    TaskParameters.GUIMeta.TimeOutSkippedReward.Label = 'Timeout for Skipping Reward';
    TaskParameters.GUI.StartEasyTrials = 50;
    TaskParameters.GUIMeta.StartEasyTrials.Label = '# Easier Trials at Start';
    TaskParameters.GUI.Proportion50Fifty = 0;
    TaskParameters.GUIMeta.Proportion50Fifty.Label = 'Proportion Equal Trials';
    TaskParameters.GUI.ProportionCatch = 0;
    TaskParameters.GUIMeta.ProportionCatch.Label = 'Proportion of Catch Trials';
    TaskParameters.GUI.IndicateError = false;
    TaskParameters.GUIMeta.IndicateError.Style = 'checkbox';
    TaskParameters.GUIMeta.IndicateError.Label = 'Indicate Error';
    TaskParameters.GUI.Ports_LMR = 123;
    TaskParameters.GUIMeta.Ports_LMR.Label = 'Port Numbers';
    TaskParameters.GUIPanels.General = {'ITI','TimeToChoose',...
        'TimeOutIncorrect','TimeOutBrokeFixation','TimeOutSkippedReward', ...
        'StartEasyTrials','Proportion50Fifty','ProportionCatch', ...
        'IndicateError','Ports_LMR'};    

    %% BiasControl
    TaskParameters.GUI.TrialSelection = 1;
    TaskParameters.GUIMeta.TrialSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.TrialSelection.String = {'Even','Manual','BiasCorrecting'};
    TaskParameters.GUIMeta.TrialSelection.Label = 'Trial Selection Method';
    
    TaskParameters.GUI.LeftBias = 0.5;
    TaskParameters.GUIMeta.LeftBias.Style = 'text';
    TaskParameters.GUIMeta.LeftBias.Label = 'Current Left Trial Bias';

    TaskParameters.GUI.FutureLeftBias = 0.5;
    TaskParameters.GUIMeta.FutureLeftBias.Label = 'Future Trial Left Bias';
        
    TaskParameters.GUI.RewardAmountTable.Left = 12;  
    TaskParameters.GUI.RewardAmountTable.Right = 12;  
    TaskParameters.GUIMeta.RewardAmountTable.Style = 'table';
    TaskParameters.GUIMeta.RewardAmountTable.Label = 'Reward Volumes';
    TaskParameters.GUIMeta.RewardDelayTable.ColumnLabel = {'Left','Right'};
    
    TaskParameters.GUIPanels.BiasControl = {'TrialSelection',...
        'LeftBias','FutureLeftBias','RewardAmountTable'};

    %% StimDelay
    % Stimulus Delay Distribution Parameters
    TaskParameters.GUI.StimDelayTable.Min = 0.06;
    TaskParameters.GUI.StimDelayTable.Tau = 0.1;    
    TaskParameters.GUI.StimDelayTable.Max = 0.1;
    TaskParameters.GUIMeta.StimDelayTable.Style = 'table';
    TaskParameters.GUIMeta.StimDelayTable.Label = 'Stimulus Delay Distribution';
    TaskParameters.GUIMeta.StimDelayTable.ColumnLabel = {'Min','Tau','Max'};

    TaskParameters.GUI.StimDelay = TaskParameters.GUI.StimDelayTable.Min;
    TaskParameters.GUIMeta.StimDelay.Style = 'text';
    TaskParameters.GUIMeta.StimDelay.Label = 'Current Stimulus Delay';
    TaskParameters.GUIPanels.StimulusDelay = {'StimDelayTable','StimDelay'};


    %% RewardDelay
    % Changed this from FeedbackDelay
    TaskParameters.GUI.RewardDelaySelection = 1;
    TaskParameters.GUIMeta.RewardDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.RewardDelaySelection.String = {'TruncatedExp','AutoIncrease','Fix'};
    TaskParameters.GUIMeta.RewardDelaySelection.Label = 'Reward Delay Selection';

    % Reward Delay Distribution Parameters
    TaskParameters.GUI.RewardDelayTable.Min = 0.5;
    TaskParameters.GUI.RewardDelayTable.Tau = 0.75;    
    TaskParameters.GUI.RewardDelayTable.Max = 1.5;
    TaskParameters.GUIMeta.RewardDelayTable.Style = 'table';
    TaskParameters.GUIMeta.RewardDelayTable.Label = 'Reward Delay Distribution';
    TaskParameters.GUIMeta.RewardDelayTable.ColumnLabel = {'Min','Tau','Max'};

    TaskParameters.GUI.RewardDelayTargetTable.Min = 1;
    TaskParameters.GUI.RewardDelayTargetTable.Tau = 1.5;    
    TaskParameters.GUI.RewardDelayTargetTable.Max = 6;
    TaskParameters.GUIMeta.RewardDelayTargetTable.Style = 'table';
    TaskParameters.GUIMeta.RewardDelayTargetTable.Label = 'Reward Delay Targets';
    TaskParameters.GUIMeta.RewardDelayTargetTable.ColumnLabel = {'Min','Tau','Max'};

    TaskParameters.GUI.RewardDelayIncrementTable.Min = 0.01;
    TaskParameters.GUI.RewardDelayIncrementTable.Tau = 0.01;    
    TaskParameters.GUI.RewardDelayIncrementTable.Max = 0.05;
    TaskParameters.GUIMeta.RewardDelayIncrementTable.Style = 'table';
    TaskParameters.GUIMeta.RewardDelayIncrementTable.Label = 'Target Step Size';
    TaskParameters.GUIMeta.RewardDelayIncrementTable.ColumnLabel = {'Min','Tau','Max'};

    TaskParameters.GUI.RewardDelayGrace = 0.3;
    TaskParameters.GUIMeta.RewardDelayGrace.Label = 'Grace Period for Reward';   

    TaskParameters.GUI.RewardDelay = TaskParameters.GUI.RewardDelayTable.Min;
    TaskParameters.GUIMeta.RewardDelay.Label = 'Current Reward Delay';    
    TaskParameters.GUIMeta.RewardDelay.Style = 'text';

    TaskParameters.GUIPanels.RewardDelay = {'RewardDelaySelection',...
        'RewardDelayTable','RewardDelayTargetTable','RewardDelayIncrementTable',...
        'RewardDelayGrace','RewardDelay'};

    %% Auditory Parameters

    % General
    TaskParameters.GUI.SumRates = 100;
    TaskParameters.GUI.AuditoryStimulusTime = 3;

    % Alpha
    TaskParameters.GUI.AlphaTable.Min = 0.5;
    TaskParameters.GUI.AlphaTable.Max = 1;
    TaskParameters.GUIMeta.AlphaTable.Style = 'table';
    TaskParameters.GUIMeta.AlphaTable.Label = 'Auditory Alpha';
    TaskParameters.GUIMeta.AlphaTable.ColumnLabel = {'Min','Max'};

    TaskParameters.GUI.AlphaIncrementTable.Increase = 0.025;
    TaskParameters.GUI.AlphaIncrementTable.Decrease = 0.05;
    TaskParameters.GUIMeta.AlphaIncrementTable.Style = 'table';
    TaskParameters.GUIMeta.AlphaIncrementTable.Label = 'Auto Adjust Values';
    TaskParameters.GUIMeta.AlphaIncrementTable.ColumnLabel = {'Increase','Decrease'};

    TaskParameters.GUI.AlphaAutoincrement = false;
    TaskParameters.GUIMeta.AlphaAutoincrement.Style = 'checkbox';
    TaskParameters.GUIMeta.AlphaAutoincrement.Label = 'Auto Increment Alpha';
    TaskParameters.GUI.AuditoryAlpha = TaskParameters.GUI.AlphaTable.Min;
    TaskParameters.GUIMeta.AuditoryAlpha.Style = 'text';
    TaskParameters.GUIMeta.AuditoryAlpha.Label = 'Current Alpha';
    % TaskParameters.GUI.ActualEvidence = 0.1; % Place holder until trial is generated
    % TaskParameters.GUIMeta.ActualEvidence.Style = 'text';
    % TaskParameters.GUIMeta.ActualEvidence.Label = 'Actual Evidence';
    
    % Minimum Sampling
    TaskParameters.GUI.MinSampleTable.Min = 0.1;
    TaskParameters.GUI.MinSampleTable.Max = 0.3;
    TaskParameters.GUIMeta.MinSampleTable.Style = 'table';
    TaskParameters.GUIMeta.MinSampleTable.Label = 'Minimum Sampling';
    TaskParameters.GUIMeta.MinSampleTable.ColumnLabel = {'Min','Max'};

    TaskParameters.GUI.MinSampleIncrementTable.Increase = 0.01;
    TaskParameters.GUI.MinSampleIncrementTable.Decrease = 0.02;
    TaskParameters.GUIMeta.MinSampleIncrementTable.Style = 'table';
    TaskParameters.GUIMeta.MinSampleIncrementTable.Label = 'Auto Adjust Values';
    TaskParameters.GUIMeta.MinSampleIncrementTable.ColumnLabel = {'Increase','Decrease'};

    TaskParameters.GUI.MinSampleAudAutoincrement = true;
    TaskParameters.GUIMeta.MinSampleAudAutoincrement.Style = 'checkbox';
    TaskParameters.GUIMeta.MinSampleAudAutoincrement.Label = 'Auto Increment Min Sample';
    TaskParameters.GUI.MinSampleAud = TaskParameters.GUI.MinSampleTable.Min;
    TaskParameters.GUIMeta.MinSampleAud.Style = 'text';
    TaskParameters.GUIMeta.MinSampleAud.Label = 'Current Minimum Sample';

    % Assign the variables to panels   
    TaskParameters.GUIPanels.AudGeneral = {'SumRates','AuditoryStimulusTime'};
    TaskParameters.GUIPanels.AudAlpha = {'AlphaTable','AlphaAutoincrement','AlphaIncrementTable','AuditoryAlpha'};
    % TaskParameters.GUIPanels.AudAlpha = {'AlphaTable','AlphaAutoincrement','AlphaIncrementTable','AuditoryAlpha','ActualEvidence'};
    TaskParameters.GUIPanels.AudMinSample = {'MinSampleTable','MinSampleAudAutoincrement','MinSampleIncrementTable','MinSampleAud'};
    %% Plots
    %Show Plots
    TaskParameters.GUI.ShowPsycAud = 1;
    TaskParameters.GUIMeta.ShowPsycAud.Style = 'checkbox';
    TaskParameters.GUI.ShowVevaiometric = 1;
    TaskParameters.GUIMeta.ShowVevaiometric.Style = 'checkbox';
    TaskParameters.GUI.ShowTrialRate = 1;
    TaskParameters.GUIMeta.ShowTrialRate.Style = 'checkbox';
    TaskParameters.GUI.ShowFix = 1;
    TaskParameters.GUIMeta.ShowFix.Style = 'checkbox';
    TaskParameters.GUI.ShowST = 1;
    TaskParameters.GUIMeta.ShowST.Style = 'checkbox';
    TaskParameters.GUI.ShowReward = 1;
    TaskParameters.GUIMeta.ShowReward.Style = 'checkbox';
    TaskParameters.GUIPanels.ShowPlots = {'ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowReward'};
    %Vevaiometric
    TaskParameters.GUI.VevaiometricMinWT = 2;
    TaskParameters.GUI.VevaiometricNBin = 8;
    TaskParameters.GUI.VevaiometricShowPoints = 1;
    TaskParameters.GUIMeta.VevaiometricShowPoints.Style = 'checkbox';
    TaskParameters.GUIPanels.Vevaiometric = {'VevaiometricMinWT','VevaiometricNBin','VevaiometricShowPoints'};
    %Plot Ranges
    TaskParameters.GUI.PlotRangeStart = -50;
    TaskParameters.GUI.PlotRangeEnd = 0;
    TaskParameters.GUI.PlotRestrictRange = 0;
    TaskParameters.GUIMeta.PlotRestrictRange.Style = 'checkbox';
    TaskParameters.GUIPanels.PlotRange= {'PlotRangeStart','PlotRangeEnd','PlotRestrictRange'};
    
    %%
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    %% Tabs
    TaskParameters.GUITabs.General = {'StimulusDelay','BiasControl','General','RewardDelay'};
    TaskParameters.GUITabs.Auditory = {'AudGeneral','AudAlpha','AudMinSample'};
    TaskParameters.GUITabs.Plots = {'ShowPlots','Vevaiometric','PlotRange'};
    %%Non-GUI Parameters (but saved)
    TaskParameters.Figures.OutcomePlot.Position = [900, 50, 1000, 400];
    TaskParameters.Figures.ParameterGUI.Position =  [300, 550, 1360, 410];
    

end

BpodParameterGUI('init', TaskParameters);

%% Initializing data (trial type) vectors
BpodSystem.Data.Custom.TrialNumber      = 1;

BpodSystem.Data.Custom.ChoiceLeft       = NaN;
BpodSystem.Data.Custom.ChoiceCorrect    = NaN;
BpodSystem.Data.Custom.Rewarded         = false;
BpodSystem.Data.Custom.BrokeFixation    = false;
BpodSystem.Data.Custom.EarlyWithdrawal  = false;

BpodSystem.Data.Custom.CatchTrial       = false;

BpodSystem.Data.Custom.ChoicePortTime   = NaN;
BpodSystem.Data.Custom.FixationTime     = NaN;
BpodSystem.Data.Custom.MovementTime     = NaN;
BpodSystem.Data.Custom.SamplingTime     = NaN;
BpodSystem.Data.Custom.LingersTime      = NaN;

BpodSystem.Data.Custom.RewardMagnitude = ...
    [TaskParameters.GUI.RewardAmountTable.Left TaskParameters.GUI.RewardAmountTable.Right];

BpodSystem.Data.Custom.TrialNumber = [];
BpodSystem.Data.Custom.StartEasyTrials = TaskParameters.GUI.StartEasyTrials;

% make auditory stimuli for first trials
% Draw 2 trials, from trial 0, with auditory alpha 0.1 and even (0.5) bias
generateAuditoryStimuli(2,0.1,0.5);

BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';

%server data
BpodSystem.Data.Info.Rig = getenv('computername');
% [~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
BpodSystem.Data.Info.Subject = BpodSystem.GUIData.SubjectName;

% Protocol Version Data 
BpodSystem.Data.Info.ProtocolName    = 'TwoAFC';
BpodSystem.Data.Info.ProtocolVersion = '2.0';

%% Configuring PulsePal

% Added PMA 20-07-2021 % Code to intialise the PulsePal seems to be missing?
global PulsePalSystem
if  isempty(PulsePalSystem) || (ishandle(PulsePalSystem) && ~isvalid(PulsePalSystem))
    try
        PulsePal 
    catch
        % error('Can''t initalise Pulsepal...')
    end
end  

temp = load('PulsePalParamStimulus.mat','PulsePalParamStimulus');
PulsePalParamStimulus = temp.PulsePalParamStimulus;
temp = load('PulsePalParamFeedback.mat','PulsePalParamFeedback');
PulsePalParamFeedback = temp.PulsePalParamFeedback;

BpodSystem.Data.Custom.PulsePalParamStimulus=PulsePalParamStimulus;
BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
clear PulsePalParamFeedback PulsePalParamStimulus
if ~BpodSystem.EmulatorMode
    ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{1}))*5);
end

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = ...
    figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
BpodSystem.GUIHandles.OutcomePlot = [];
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .055          .15 .81 .3]);
BpodSystem.GUIHandles.OutcomePlot.TextPanel     = axes('Position',    [  .87          .15 .10 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud = axes('Position',    [2*.05 + 1*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position',        [4*.05 + 3*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',         [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleReward = axes('Position',   [6*.05 + 5*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');
MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
BpodSystem.ProtocolFigures.ParameterGUI.Position = TaskParameters.Figures.ParameterGUI.Position;
%BpodNotebook('init');

%% Run here! 

RunSession = true;

%% Main loop

iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    sma = stateMatrix(iTrial);
    SendStateMatrix(sma);
    
    % Wrapping the RunStateMatrix Function in a try loop function 
    % Helps with occasional errors due to a time out in Bpod
    RawEvents = try_RunStateMatrix();
    % RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        BpodSystem.Data.TrialSettings(iTrial) = TaskParameters;
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
    
    updateCustomDataFields(iTrial);
    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    iTrial = iTrial + 1;

end

end % End TwoAFC Protocol

function [RawEvents] = try_RunStateMatrix()
    
    try
        RawEvents = RunStateMatrix;
    catch
        disp('RunStateMatrix Failed. Trying again...')
        RawEvents = RunStateMatrix();
    end % End try

end % End try_RunStateMatrix