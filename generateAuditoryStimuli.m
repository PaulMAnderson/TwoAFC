function generateAuditoryStimuli(nNewTrials, auditoryAlpha, leftBias)
% This function generates new trial stimuli and updates the various data
% and GUI fields as needed

%% Load global variables
global BpodSystem
global TaskParameters

%% Get the left bias, or set to no bias

if nargin < 3
    try
        leftBias = TaskParameters.GUI.FutureLeftBias;
    catch
        leftBias = 0.5;
    end
end

%% Calculate the beta ratio

BetaRatio = leftBias / (1 - leftBias);

%make a,b symmetric around auditoryAlpha to make B symmetric
BetaA =  (2 * auditoryAlpha * BetaRatio) / (1 + BetaRatio);
BetaB = (auditoryAlpha - BetaA) + auditoryAlpha;

%% Generate Stimuli

% Need to account for very first trials where we don't have evidenceStrength
% calculated yet
if isfield(BpodSystem.Data.Custom,'evidenceStrength')
    latestTrial = numel(BpodSystem.Data.Custom.evidenceStrength);
else
    latestTrial = numel(BpodSystem.Data.Custom.trialNumber);
end

% Pre-generate all beta and 50/50 samples at once (vectorised across trials)
omegaSamples = betarnd(max(0,BetaA), max(0,BetaB), 1, nNewTrials);
r50          = rand(1, nNewTrials);
duration     = TaskParameters.GUI.AuditoryStimulusTime;
sumRates     = TaskParameters.GUI.SumRates;
prop5050     = TaskParameters.GUI.Proportion50Fifty;
startEasy    = TaskParameters.GUI.StartEasyTrials;

for trialNum = 1:nNewTrials

    trialIdx = latestTrial + trialNum;

    BpodSystem.Data.Custom.trialAlpha(trialIdx) = auditoryAlpha;

    % Check for deliberate 50-50 trial
    if r50(trialNum) < prop5050 && trialIdx > startEasy
        omega_val = 0.5;
    else
        omega_val = omegaSamples(trialNum);
    end
    BpodSystem.Data.Custom.omega(trialIdx) = omega_val;

    %% Calculate click rates
    clickRateL = round(omega_val * sumRates);
    clickRateR = round((1 - omega_val) * sumRates);
    BpodSystem.Data.Custom.clickRateLeft(trialIdx)  = clickRateL;
    BpodSystem.Data.Custom.clickRateRight(trialIdx) = clickRateR;

    % Generate click trains into local variables to avoid repeated struct lookups
    trainL = GeneratePoissonClickTrain(clickRateL, duration);
    trainR = GeneratePoissonClickTrain(clickRateR, duration);

    %% Correct left/right click train - Set the first click to be equal

    if ~isempty(trainL) && ~isempty(trainR)

        firstClick = min(trainL(1), trainR(1));
        trainL(1)  = firstClick;
        trainR(1)  = firstClick;

    elseif isempty(trainL) && ~isempty(trainR)

        trainL = trainR(1);

    elseif ~isempty(trainL) && isempty(trainR)

        trainR = trainL(1);

    else
        % Both trains are empty: generate fallback single-click trains
        if clickRateL > 0
            trainL = round(1/clickRateL*10000)/10000;
        else
            trainL = [];
        end
        if clickRateR > 0
            trainR = round(1/clickRateR*10000)/10000;
        else
            trainR = [];
        end
    end

    BpodSystem.Data.Custom.clickTrainLeft{trialIdx}  = trainL;
    BpodSystem.Data.Custom.clickTrainRight{trialIdx} = trainR;

    nLeft  = length(trainL);
    nRight = length(trainR);

    if nLeft > nRight
        BpodSystem.Data.Custom.sideProgrammed{trialIdx} = 'left';
    elseif nRight > nLeft
        BpodSystem.Data.Custom.sideProgrammed{trialIdx} = 'right';
    else
        BpodSystem.Data.Custom.sideProgrammed{trialIdx} = 'none';
    end

    % evidenceStrength: positive = right-dominant (canonical convention)
    if (nLeft + nRight) > 0
        BpodSystem.Data.Custom.evidenceStrength(trialIdx) = ...
            (nRight - nLeft) / (nRight + nLeft);
    else
        BpodSystem.Data.Custom.evidenceStrength(trialIdx) = 0;
    end

end


end % End function generateAuditoryStimuli


%% Sub functions
function ClickTimes = GeneratePoissonClickTrain(ClickRate, Duration)
% ClickTimes = click time points in seconds (PulsePal format)
% ClickRate  = mean click rate in Hz
% Duration   = click train duration in seconds

if ClickRate <= 0
    ClickTimes = [];
    return;
end

SamplingRate   = 1000000;
nSamples       = Duration * SamplingRate;
ExponentialMean = (1 / ClickRate) * SamplingRate;

% Pre-generate 3x the expected number of intervals in one vectorised call.
% For any realistic click rate (1–100 Hz) and duration (≤10 s) the 3x
% buffer covers > 99.9999% of cases without a second draw.
nExpected = ceil(ClickRate * Duration);
intervals = -ExponentialMean * log(rand(1, nExpected * 3)) + 100;

% Cumulative sum gives absolute click times; keep only those within window
ClickTimes = cumsum(intervals);
ClickTimes = ClickTimes(ClickTimes <= nSamples);

% Round to 100μs PulsePal grid
ClickTimes = round(ClickTimes / 100) / 10000;

end %  function GeneratePoissonClickTrain
