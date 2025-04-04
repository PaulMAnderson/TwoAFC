function generateAuditoryStimuli(nNewTrials, auditoryAlpha, leftBias)
% This function generates new trial stimuli and updates the various data
% and GUI fields as needed

%% Load global variables
% Would like to remove this and have it take the BpodSystem as in input
% % variable, or else be a method of an object

global BpodSystem
global TaskParameters

%% Get the left bias, or set to no bias

if nargin < 4
    try
        leftBias = TaskParameters.GUI.FutureLeftBias;
    catch
        leftBias = 0.5;
    end
end

%% Calculate the beta ratio

BetaRatio = leftBias / (1 - leftBias);

% BetaRatio = (1 - min(0.9,max(0.1,TaskParameters.GUI.LeftBias))) / ...
%                  min(0.9,max(0.1,TaskParameters.GUI.LeftBias)); 

% use a = ratio*b to yield E[X] = LeftBiasAud using Beta(a,b) pdf
% cut off between 0.1-0.9 to prevent extreme values (only one side) and div by 

%make a,b symmetric around auditoryAlpha to make B symmetric
BetaA =  (2 * auditoryAlpha * BetaRatio) / (1 + BetaRatio); 
BetaB = (auditoryAlpha - BetaA) + auditoryAlpha;

%% Generate Stimuli

% Need to account for very first trials where we don't have the DV 
% calculated yet
if isfield(BpodSystem.Data.Custom,'DV')
    latestTrial = numel(BpodSystem.Data.Custom.DV); 
else
    latestTrial = numel(BpodSystem.Data.Custom.TrialNumber);
end

for trialNum = 1:nNewTrials

    % Get the trial index
    trialIdx = latestTrial + trialNum;

    % Save the alpha (probably not neccessary anymore but kept for
    % backwards compatability
    BpodSystem.Data.Custom.EffectiveAlpha(trialIdx) = auditoryAlpha; 

    % Check for deliberate 50-50 trial
    if rand(1,1) < TaskParameters.GUI.Proportion50Fifty && trialIdx > TaskParameters.GUI.StartEasyTrials
        BpodSystem.Data.Custom.AuditoryOmega(trialIdx) = 0.5;
    else
        BpodSystem.Data.Custom.AuditoryOmega(trialIdx) = betarnd(max(0,BetaA),max(0,BetaB),1,1); %prevent negative parameters
    end

    %% Calculate click rates
    BpodSystem.Data.Custom.LeftClickRate(trialIdx) = ...
        round(BpodSystem.Data.Custom.AuditoryOmega(trialIdx)*TaskParameters.GUI.SumRates);

    BpodSystem.Data.Custom.RightClickRate(trialIdx) = ...
        round((1-BpodSystem.Data.Custom.AuditoryOmega(trialIdx))*TaskParameters.GUI.SumRates);

    BpodSystem.Data.Custom.LeftClickTrain{trialIdx} = ...
        GeneratePoissonClickTrain(BpodSystem.Data.Custom.LeftClickRate(trialIdx), ...
        TaskParameters.GUI.AuditoryStimulusTime);

    BpodSystem.Data.Custom.RightClickTrain{trialIdx} = ...
        GeneratePoissonClickTrain(BpodSystem.Data.Custom.RightClickRate(trialIdx), ...
        TaskParameters.GUI.AuditoryStimulusTime);
   
    %% Correct left/right click train
    if ~isempty(BpodSystem.Data.Custom.LeftClickTrain{trialIdx}) && ...
       ~isempty(BpodSystem.Data.Custom.RightClickTrain{trialIdx})
                BpodSystem.Data.Custom.LeftClickTrain{trialIdx}(1) =  ...
                    min(BpodSystem.Data.Custom.LeftClickTrain{trialIdx}(1), ...
                    BpodSystem.Data.Custom.RightClickTrain{trialIdx}(1));
        BpodSystem.Data.Custom.RightClickTrain{trialIdx}(1) =  ...
            min(BpodSystem.Data.Custom.LeftClickTrain{trialIdx}(1), ...
            BpodSystem.Data.Custom.RightClickTrain{trialIdx}(1));

    elseif  isempty(BpodSystem.Data.Custom.LeftClickTrain{trialIdx}) &&  ...
            ~isempty(BpodSystem.Data.Custom.RightClickTrain{trialIdx})
        
        BpodSystem.Data.Custom.LeftClickTrain{trialIdx}(1) =  ...
            BpodSystem.Data.Custom.RightClickTrain{trialIdx}(1);
    
    elseif ~isempty(BpodSystem.Data.Custom.LeftClickTrain{1}) &&  ...
            isempty(BpodSystem.Data.Custom.RightClickTrain{trialIdx})
        
        BpodSystem.Data.Custom.RightClickTrain{trialIdx}(1) =  ...
            BpodSystem.Data.Custom.LeftClickTrain{trialIdx}(1);

    else
        BpodSystem.Data.Custom.LeftClickTrain{trialIdx} =  ...
            round(1/BpodSystem.Data.Custom.LeftClickRate*10000)/10000;
        BpodSystem.Data.Custom.RightClickTrain{trialIdx} =  ...
            round(1/BpodSystem.Data.Custom.RightClickRate*10000)/10000;
    end

    if length(BpodSystem.Data.Custom.LeftClickTrain{trialIdx}) >  ...
       length(BpodSystem.Data.Custom.RightClickTrain{trialIdx})
        BpodSystem.Data.Custom.MoreLeftClicks(trialIdx) = double(1);
    
    elseif length(BpodSystem.Data.Custom.LeftClickTrain{1}) <  ...
            length(BpodSystem.Data.Custom.RightClickTrain{trialIdx})
            BpodSystem.Data.Custom.MoreLeftClicks(trialIdx) = double(0);
    
    else
        BpodSystem.Data.Custom.MoreLeftClicks(trialIdx) = NaN;
    end
    
    BpodSystem.Data.Custom.DV(trialIdx) = ...
    (length(BpodSystem.Data.Custom.LeftClickTrain{trialIdx}) -  ...
    length(BpodSystem.Data.Custom.RightClickTrain{trialIdx})) ./ ...
    (length(BpodSystem.Data.Custom.LeftClickTrain{trialIdx}) + ...
    length(BpodSystem.Data.Custom.RightClickTrain{trialIdx}));

end


end % End function generateAuditoryStimuli


%% Sub functions
function ClickTimes = GeneratePoissonClickTrain(ClickRate, Duration)
% ClickTimes = click time points in us
% ClickRate = mean click rate in Hz
% Duration = click train duration in seconds

SamplingRate = 1000000;
nSamples = Duration*SamplingRate;
ExponentialMean = round((1/ClickRate)*SamplingRate); % Calculates mean of exponential distribution
InvertedMean = ExponentialMean*-1;
PreallocateSize = round(ClickRate*Duration*2);
ClickTimes = zeros(1,PreallocateSize);
Pos = 0;
Time = 0;
Building = 1;
while Building == 1
    Pos = Pos + 1;
    Interval = InvertedMean*log(rand)+100; % +100 ensures no duplicate timestamps at PulsePal resolution of 100us
    Time = Time + Interval;
    if Time > nSamples
        Building = 0;
    else
        ClickTimes(Pos) = Time;
    end
end
ClickTimes = ClickTimes(1:Pos-1); % Trim click train preallocation to length
ClickTimes = round(ClickTimes/100)/10000; % Make clicks multiples of 100us - necessary for pulse time programming

end %  function GeneratePoissonClickTrain