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
    TaskParameters.GUI.ChoiceDeadLine = 20;
    TaskParameters.GUI.TimeOutIncorrectChoice = 3; % (s)
    TaskParameters.GUI.TimeOutBrokeFixation = 5; % (s)
    TaskParameters.GUI.TimeOutEarlyWithdrawal = 5; % (s)
    TaskParameters.GUI.TimeOutSkippedFeedback = 3; % (s) 
    TaskParameters.GUI.StartEasyTrials = 75;
    TaskParameters.GUI.Percent50Fifty = 0;
    TaskParameters.GUI.PercentCatch = 0;
    TaskParameters.GUI.CatchError = true;
    TaskParameters.GUIMeta.CatchError.Style = 'checkbox';
    TaskParameters.GUI.Ports_LMR = 123;
    TaskParameters.GUIPanels.General = {'ITI','ChoiceDeadLine','TimeOutIncorrectChoice','TimeOutBrokeFixation','TimeOutEarlyWithdrawal','TimeOutSkippedFeedback','StartEasyTrials','Percent50Fifty','PercentCatch','CatchError','Ports_LMR'};    
    %% BiasControl
    TaskParameters.GUI.TrialSelection = 1;
    TaskParameters.GUI.RewardAmountL = 12;  
    TaskParameters.GUI.RewardAmountR = 12; 
    TaskParameters.GUIMeta.TrialSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.TrialSelection.String = {'Flat','Manual','BiasCorrecting'};
    TaskParameters.GUIPanels.BiasControl = {'TrialSelection','RewardAmountL','RewardAmountR'};
    %% StimDelay
    TaskParameters.GUI.StimDelayMin = 0.06;
    TaskParameters.GUI.StimDelayMax = 0.15;
    TaskParameters.GUI.StimDelayTau = 0.1;
    TaskParameters.GUI.StimDelay = TaskParameters.GUI.StimDelayMin;
    TaskParameters.GUIMeta.StimDelay.Style = 'text';
    TaskParameters.GUIPanels.StimDelay = {'StimDelayMin','StimDelayMax','StimDelayTau','StimDelay'};
    %% FeedbackDelay
    TaskParameters.GUI.FeedbackDelaySelection = 1;
    TaskParameters.GUIMeta.FeedbackDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.FeedbackDelaySelection.String = {'Fix','AutoIncr','TruncExp'};
    TaskParameters.GUI.FeedbackDelayMin = 0.5;
    TaskParameters.GUI.FeedbackDelayTau = 0.75;
    TaskParameters.GUI.FeedbackDelayMax = 1.5;
    TaskParameters.GUI.FeedbackDelayMinTarget = 1;
    TaskParameters.GUI.FeedbackDelayTauTarget = 1.5;        
    TaskParameters.GUI.FeedbackDelayMaxTarget = 6;
    TaskParameters.GUI.FeedbackDelayIncrMinTau = 0.01;
    TaskParameters.GUI.FeedbackDelayIncrMax = 0.05;
    TaskParameters.GUI.FeedbackDelayGrace = 0.3;
    TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
    TaskParameters.GUIMeta.FeedbackDelay.Style = 'text';
    TaskParameters.GUIPanels.FeedbackDelay = {'FeedbackDelaySelection',...
        'FeedbackDelayMin','FeedbackDelayTau','FeedbackDelayMax',...
        'FeedbackDelayMinTarget','FeedbackDelayTauTarget','FeedbackDelayMaxTarget',...        
        'FeedbackDelayIncrMinTau','FeedbackDelayIncrMax',...
        'FeedbackDelayGrace','FeedbackDelay'};
    %% Auditory Params
    TaskParameters.GUI.AuditoryAlpha = 0.5;
    TaskParameters.GUI.LeftBiasAud = 0.5;
    TaskParameters.GUIMeta.LeftBiasAud.Style = 'text';
    TaskParameters.GUI.SumRates = 100;
    TaskParameters.GUI.AuditoryStimulusTime = 3;
    %min auditory stimulus
    TaskParameters.GUI.MinSampleAudMin = 0.2;
    TaskParameters.GUI.MinSampleAudMax = 0.3;
    TaskParameters.GUI.MinSampleAudAutoincrement = true;
    TaskParameters.GUIMeta.MinSampleAudAutoincrement.Style = 'checkbox';
    TaskParameters.GUI.MinSampleAudIncr = 0.01;
    TaskParameters.GUI.MinSampleAudDecr = 0.02;
    TaskParameters.GUI.MinSampleAud = TaskParameters.GUI.MinSampleAudMin;
    TaskParameters.GUIMeta.MinSampleAud.Style = 'text';
    TaskParameters.GUI.JackpotAuditory = false;
    TaskParameters.GUIMeta.JackpotAuditory.Style = 'checkbox';
    TaskParameters.GUI.JackpotAuditoryTime = 10;
    TaskParameters.GUIMeta.JackpotAuditoryTime.Style = 'text';
    TaskParameters.GUIPanels.AudGeneral = {'AuditoryAlpha','LeftBiasAud','SumRates','AuditoryStimulusTime'};
    TaskParameters.GUIPanels.AudMinSample = {'MinSampleAudMin','MinSampleAudMax','MinSampleAudAutoincrement','MinSampleAudIncr','MinSampleAudDecr','MinSampleAud'};
    TaskParameters.GUIPanels.AudJackpot = {'JackpotAuditory','JackpotAuditoryTime'};
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
    TaskParameters.GUI.ShowFeedback = 1;
    TaskParameters.GUIMeta.ShowFeedback.Style = 'checkbox';
    TaskParameters.GUIPanels.ShowPlots = {'ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowFeedback'};
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
    TaskParameters.GUITabs.General = {'StimDelay','BiasControl','General','FeedbackDelay'};
    TaskParameters.GUITabs.Auditory = {'AudGeneral','AudMinSample','AudJackpot'};
    TaskParameters.GUITabs.Plots = {'ShowPlots','Vevaiometric','PlotRange'};
    %%Non-GUI Parameters (but saved)
    TaskParameters.Figures.OutcomePlot.Position = [200, 200, 1000, 400];
    TaskParameters.Figures.ParameterGUI.Position =  [9, 454, 1474, 562];
    
    %% Add a closing function to a figure 
    % Is an attempt to allow Bpod to control external equipment upon
    % protocol end (in the inital case it should send a serial command to
    % an Arduino)
    TaskParameters.CloseFunction = @stopSyncArduino;


end

BpodParameterGUI('init', TaskParameters);

%% Initializing data (trial type) vectors
BpodSystem.Data.Custom.BlockNumber = 1;
BpodSystem.Data.Custom.BlockTrial = 1;
BpodSystem.Data.Custom.ChoiceLeft = [];
BpodSystem.Data.Custom.ChoiceCorrect = [];
BpodSystem.Data.Custom.Feedback = false(0);
BpodSystem.Data.Custom.FeedbackTime = [];
BpodSystem.Data.Custom.FixBroke = false(0);
BpodSystem.Data.Custom.EarlyWithdrawal = false(0);
BpodSystem.Data.Custom.FixDur = [];
BpodSystem.Data.Custom.MT = [];
BpodSystem.Data.Custom.CatchTrial = false;
BpodSystem.Data.Custom.ST = [];
BpodSystem.Data.Custom.Rewarded = false(0);
BpodSystem.Data.Custom.RewardMagnitude = [TaskParameters.GUI.RewardAmountL  TaskParameters.GUI.RewardAmountR];
BpodSystem.Data.Custom.TrialNumber = [];
% BpodSystem.Data.Custom.AuditoryTrial = rand(1,2) < TaskParameters.GUI.PercentAuditory;
%RMM 16.05.23
BpodSystem.Data.Custom.StartEasyTrial = TaskParameters.GUI.StartEasyTrials;
%RMM


% make auditory stimuli for first trials
for a = 1:2
    % RMM 16.05.23
    BpodSystem.Data.Custom.EffectiveAlpha = TaskParameters.GUI.AuditoryAlpha/4; % 'divided by 4' comes from the line below.
    % RMM
    BpodSystem.Data.Custom.AuditoryOmega(a) = betarnd(TaskParameters.GUI.AuditoryAlpha/4,TaskParameters.GUI.AuditoryAlpha/4,1,1);
    BpodSystem.Data.Custom.LeftClickRate(a) = round(BpodSystem.Data.Custom.AuditoryOmega(a)*TaskParameters.GUI.SumRates);
    BpodSystem.Data.Custom.RightClickRate(a) = round((1-BpodSystem.Data.Custom.AuditoryOmega(a))*TaskParameters.GUI.SumRates);
    BpodSystem.Data.Custom.LeftClickTrain{a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(a), TaskParameters.GUI.AuditoryStimulusTime);
    BpodSystem.Data.Custom.RightClickTrain{a} = GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(a), TaskParameters.GUI.AuditoryStimulusTime);
    %correct left/right click train
    if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{a})
        BpodSystem.Data.Custom.LeftClickTrain{a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{a}(1),BpodSystem.Data.Custom.RightClickTrain{a}(1));
        BpodSystem.Data.Custom.RightClickTrain{a}(1) = min(BpodSystem.Data.Custom.LeftClickTrain{a}(1),BpodSystem.Data.Custom.RightClickTrain{a}(1));
    elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{a}) && ~isempty(BpodSystem.Data.Custom.RightClickTrain{a})
        BpodSystem.Data.Custom.LeftClickTrain{a}(1) = BpodSystem.Data.Custom.RightClickTrain{a}(1);
    elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{1}) &&  isempty(BpodSystem.Data.Custom.RightClickTrain{a})
        BpodSystem.Data.Custom.RightClickTrain{a}(1) = BpodSystem.Data.Custom.LeftClickTrain{a}(1);
    else
        BpodSystem.Data.Custom.LeftClickTrain{a} = round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
        BpodSystem.Data.Custom.RightClickTrain{a} = round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
    end
    if length(BpodSystem.Data.Custom.LeftClickTrain{a}) > length(BpodSystem.Data.Custom.RightClickTrain{a})
        BpodSystem.Data.Custom.MoreLeftClicks(a) = double(1);
    elseif length(BpodSystem.Data.Custom.LeftClickTrain{1}) < length(BpodSystem.Data.Custom.RightClickTrain{a})
        BpodSystem.Data.Custom.MoreLeftClicks(a) = double(0);
    else
        BpodSystem.Data.Custom.MoreLeftClicks(a) = NaN;
    end
    BpodSystem.Data.Custom.DV(a) = (length(BpodSystem.Data.Custom.LeftClickTrain{a}) - length(BpodSystem.Data.Custom.RightClickTrain{a}))./(length(BpodSystem.Data.Custom.LeftClickTrain{a}) + length(BpodSystem.Data.Custom.RightClickTrain{a}));
end%for a+1:2

BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';

%server data
BpodSystem.Data.Custom.Rig = getenv('computername');
% [~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
BpodSystem.Data.Custom.Subject = BpodSystem.GUIData.SubjectName;
%% Configuring PulsePal

% Added PMA 20-07-2021 % Code to intialise the PulsePal seems to be missing?
global PulsePalSystem
if isempty(PulsePalSystem)
    try
        PulsePal 
    end
end   

load PulsePalParamStimulus.mat
load PulsePalParamFeedback.mat
BpodSystem.Data.Custom.PulsePalParamStimulus=PulsePalParamStimulus;
BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
clear PulsePalParamFeedback PulsePalParamStimulus
if ~BpodSystem.EmulatorMode
    ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{1}))*5);
end

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
BpodSystem.GUIHandles.OutcomePlot = [];
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .055          .15 .81 .3]);
BpodSystem.GUIHandles.OutcomePlot.TextPanel     = axes('Position',    [  .87          .15 .10 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud = axes('Position',    [2*.05 + 1*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position',        [4*.05 + 3*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',         [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',   [6*.05 + 5*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');
MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
BpodSystem.ProtocolFigures.ParameterGUI.Position = TaskParameters.Figures.ParameterGUI.Position;
%BpodNotebook('init');

%% Arduino controller activation

computerName = getenv('COMPUTERNAME');
if strcmp(computerName,'CIRCE')
    % Make the arduino controlling cameras etc. start here
    BpodSystem.PluginObjects.SerialConnection = connectTimerArduino;
    pause(2); % Need to wait for the connection to actually go live
    write(BpodSystem.PluginObjects.SerialConnection,'A','STRING'); %  'A' means run all (cam & barcodes)
    pause(0.5);
end
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

% Stop the timing arduino
write(serialCon,'S','STRING');


end

function [RawEvents] = try_RunStateMatrix()

try
    RawEvents = RunStateMatrix;
catch
    disp('RunStateMatrix Failed. Trying again...')
    RawEvents = RunStateMatrix();
end % End try

end % End try_RunStateMatrix


function serialCon = connectTimerArduino
    try
        port = findArduinoPort;
    catch
        warning('Couldn''t automatically find timing Arduino. Using a default port. Check timing TTLS are running!!!!');
        port = 'COM11';
    end
    try
        serialCon =  serialport(port,9600);
    catch
        error('failed to connect to timing arduino...');
    end
end