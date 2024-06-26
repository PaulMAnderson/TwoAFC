function sma = stateMatrix(iTrial) %RMM
global BpodSystem
global TaskParameters

%stateMatrix from Dual2AFCRicardo


%% Define ports
LeftPort = floor(mod(TaskParameters.GUI.Ports_LMR/100,10));
CenterPort = floor(mod(TaskParameters.GUI.Ports_LMR/10,10));
RightPort = mod(TaskParameters.GUI.Ports_LMR,10);
LeftPortOut = strcat('Port',num2str(LeftPort),'Out');
CenterPortOut = strcat('Port',num2str(CenterPort),'Out');
RightPortOut = strcat('Port',num2str(RightPort),'Out');
LeftPortIn = strcat('Port',num2str(LeftPort),'In');
CenterPortIn = strcat('Port',num2str(CenterPort),'In');
RightPortIn = strcat('Port',num2str(RightPort),'In');

LeftValve = 2^(LeftPort-1);
RightValve = 2^(RightPort-1);

LeftValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardMagnitude(iTrial,1), LeftPort);
RightValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardMagnitude(iTrial,2), RightPort);

LeftRewarded = BpodSystem.Data.Custom.MoreLeftClicks(iTrial);
if isnan(LeftRewarded)
    LeftRewarded = rand(1,1)<0.5;
end


if LeftRewarded == 1
    LeftPokeAction = 'rewarded_Lin';
    RightPokeAction = 'unrewarded_Rin';
elseif LeftRewarded == 0
    LeftPokeAction = 'unrewarded_Lin';
    RightPokeAction = 'rewarded_Rin';
else
    error('Bpod:Olf2AFC:unknownStim','Undefined stimulus');
end

if BpodSystem.Data.Custom.CatchTrial(iTrial)
    FeedbackDelayCorrect = 20; 
else
    FeedbackDelayCorrect = TaskParameters.GUI.FeedbackDelay;
end
if TaskParameters.GUI.CatchError
    FeedbackDelayError = 20;
else
    FeedbackDelayError = TaskParameters.GUI.FeedbackDelay;
end

% wire output depending on trial difficulty 
evidence = abs(BpodSystem.Data.Custom.AuditoryOmega(iTrial)-0.5);
binned_omega = discretize(evidence, linspace(0,1,20)); 

%% Build state matrix
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,FeedbackDelayCorrect);
sma = SetGlobalTimer(sma,2,FeedbackDelayError);
    
% Set individual TrialCount
TrialDigits=dec2base(iTrial,10)-'0';
TrialDigits=[zeros(1,4-length(TrialDigits)),TrialDigits];
TrialDigit1=TrialDigits(1);
TrialDigit2=TrialDigits(2);
TrialDigit3=TrialDigits(3);
TrialDigit4=TrialDigits(4);
    
% TRIALCOUNT STATE1
sma = AddState(sma,'Name','TrialCount1',...
    'Timer',0.001+(0.001*TrialDigit1),...
    'StateChangeConditions',{'Tup','TrialCount1KIll'},...
    'OutputActions',{'BNCState',2});

% TRIALCOUNT STATE1 KILL
sma = AddState(sma,'Name','TrialCount1KIll',...
    'Timer',0.001,...
    'StateChangeConditions',{'Tup','TrialCount2'},...
    'OutputActions',{'BNCState',0});

% TRIALCOUNT STATE2
sma = AddState(sma,'Name','TrialCount2',...
    'Timer',0.001+(0.001*TrialDigit2),...
    'StateChangeConditions',{'Tup','TrialCount2Kill'},...
    'OutputActions',{'BNCState',2});

% TRIALCOUNT STATE2 KILL
sma = AddState(sma,'Name','TrialCount2Kill',...
    'Timer',0.001,...
    'StateChangeConditions',{'Tup','TrialCount3'},...
    'OutputActions',{'BNCState',0});

% TRIALCOUNT STATE3
sma = AddState(sma,'Name','TrialCount3',...
    'Timer',0.001+(0.001*TrialDigit3),...
    'StateChangeConditions',{'Tup','TrialCount3Kill'},...
    'OutputActions',{'BNCState',2});

% TRIALCOUNT STATE3 KILL
sma = AddState(sma,'Name','TrialCount3Kill',...
    'Timer',0.001,...
    'StateChangeConditions',{'Tup','TrialCount4'},...
    'OutputActions',{'BNCState',0});

% TRIALCOUNT STATE4
sma = AddState(sma,'Name','TrialCount4',...
    'Timer',0.001+(0.001*TrialDigit4),...
    'StateChangeConditions',{'Tup','TrialCount4Kill'},...
    'OutputActions',{'BNCState',2});

% TRIALCOUNT STATE4 KILL
sma = AddState(sma,'Name','TrialCount4Kill',...
    'Timer',0.001,...
    'StateChangeConditions',{'Tup','wait_Cin'},...
    'OutputActions',{'BNCState',0});

sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {CenterPortIn, 'stay_Cin'},...
    'OutputActions', {'SoftCode',1,strcat('PWM',num2str(CenterPort)),255, 'BNCState',2});
sma = AddState(sma, 'Name', 'stay_Cin',...
    'Timer', TaskParameters.GUI.StimDelay,...
    'StateChangeConditions', {CenterPortOut,'broke_fixation','Tup', 'stimulus_delivery_min'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'broke_fixation',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','timeOut_BrokeFixation'},...
    'OutputActions',{});

sma = AddState(sma, 'Name', 'stimulus_delivery_min',...
    'Timer', TaskParameters.GUI.MinSampleAud,...
    'StateChangeConditions', {CenterPortOut,'early_withdrawal','Tup','stimulus_delivery'},...
    'OutputActions', {'BNCState',1});
sma = AddState(sma, 'Name', 'early_withdrawal',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','timeOut_EarlyWithdrawal'},...
    'OutputActions',{'BNCState',0});
sma = AddState(sma, 'Name', 'stimulus_delivery',...
    'Timer', TaskParameters.GUI.AuditoryStimulusTime - TaskParameters.GUI.MinSampleAud,...
    'StateChangeConditions', {CenterPortOut,'wait_Sin','Tup','wait_Sin'},...
    'OutputActions', {'BNCState',1, 'WireState',1, 'PWM4', binned_omega});
sma = AddState(sma, 'Name', 'wait_Sin',...
    'Timer',TaskParameters.GUI.ChoiceDeadLine,...
    'StateChangeConditions', {LeftPortIn,'start_Lin',RightPortIn,'start_Rin','Tup','missed_choice'},...
    'OutputActions',{'BNCState',0,strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(RightPort)),255});

sma = AddState(sma, 'Name','start_Lin',...
    'Timer',0,...
    'StateChangeConditions', {'Tup','start_Lin2'},...
    'OutputActions',{'GlobalTimerTrig',1});%there are two start_Lin states to trigger each global timer separately (Bpod bug)
sma = AddState(sma, 'Name','start_Lin2',...
    'Timer',0,...
    'StateChangeConditions', {'Tup',LeftPokeAction},...
    'OutputActions',{'GlobalTimerTrig',2});
sma = AddState(sma, 'Name','start_Rin',...
    'Timer',0,...
    'StateChangeConditions', {'Tup','start_Rin2'},...
    'OutputActions',{'GlobalTimerTrig',1});%there are two start_Rin states to trigger each global timer separately (Bpod bug)
sma = AddState(sma, 'Name','start_Rin2',...
    'Timer',0,...
    'StateChangeConditions', {'Tup',RightPokeAction},...
    'OutputActions',{'GlobalTimerTrig',2});
sma = AddState(sma, 'Name', 'rewarded_Lin',...
    'Timer', FeedbackDelayCorrect,...
    'StateChangeConditions', {LeftPortOut,'rewarded_Lin_grace','Tup','water_L','GlobalTimer1_End','water_L'},...
    'OutputActions', {'WireState',2});

% RMM - States 'rewarded_Lin_grace' and 'rewarded_Rin_grace' were
% substituted by a new version to remove feedback sound from early dropout trials

% sma = AddState(sma, 'Name', 'rewarded_Lin_grace',... %ORIGINAL STATE
%     'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
%     'StateChangeConditions',{'Tup','skipped_feedback',LeftPortIn,'rewarded_Lin','GlobalTimer1_End','skipped_feedback',CenterPortIn,'skipped_feedback',RightPortIn,'skipped_feedback'},...
%     'OutputActions', {});
% RMM

sma = AddState(sma, 'Name', 'rewarded_Rin',...
    'Timer', FeedbackDelayCorrect,...
    'StateChangeConditions', {RightPortOut,'rewarded_Rin_grace','Tup','water_R','GlobalTimer1_End','water_R'},...
    'OutputActions', {'WireState',2});

% RMM
% sma = AddState(sma, 'Name', 'rewarded_Rin_grace',... %ORIGINAL STATE
%     'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
%     'StateChangeConditions',{'Tup','skipped_feedback',RightPortIn,'rewarded_Rin','GlobalTimer1_End','skipped_feedback',CenterPortIn,'skipped_feedback',LeftPortIn,'skipped_feedback'},...
%     'OutputActions', {});
% RMM

% RMM - New versions of 'rewarded_Lin_grace' and 'rewarded_Rin_grace'
sma = AddState(sma, 'Name', 'rewarded_Rin_grace',... %NEW STATE
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedbackCorrectChoice',RightPortIn,'rewarded_Rin','GlobalTimer1_End','skipped_feedbackCorrectChoice',CenterPortIn,'skipped_feedbackCorrectChoice',LeftPortIn,'skipped_feedbackCorrectChoice'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'rewarded_Lin_grace',... %NEW STATE
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedbackCorrectChoice',LeftPortIn,'rewarded_Lin','GlobalTimer1_End','skipped_feedbackCorrectChoice',CenterPortIn,'skipped_feedbackCorrectChoice',RightPortIn,'skipped_feedbackCorrectChoice'},...
    'OutputActions', {});
% RMM



sma = AddState(sma, 'Name', 'unrewarded_Lin',...
    'Timer', FeedbackDelayError,...
    'StateChangeConditions', {LeftPortOut,'unrewarded_Lin_grace','Tup','timeOut_IncorrectChoice','GlobalTimer2_End','timeOut_IncorrectChoice'},...
    'OutputActions', {'WireState',4});
sma = AddState(sma, 'Name', 'unrewarded_Lin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',LeftPortIn,'unrewarded_Lin','GlobalTimer2_End','skipped_feedback',CenterPortIn,'skipped_feedback',RightPortIn,'skipped_feedback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'unrewarded_Rin',...
    'Timer', FeedbackDelayError,...
    'StateChangeConditions', {RightPortOut,'unrewarded_Rin_grace','Tup','timeOut_IncorrectChoice','GlobalTimer2_End','timeOut_IncorrectChoice'},...
    'OutputActions', {'WireState',4});
sma = AddState(sma, 'Name', 'unrewarded_Rin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',RightPortIn,'unrewarded_Rin','GlobalTimer2_End','skipped_feedback',CenterPortIn,'skipped_feedback',LeftPortIn,'skipped_feedback'},...
    'OutputActions', {});

%%%%%%%%%%%%% RMM - Changes to implement lingersInPort states

% Water_LR states were replaced so that WireState signal continues after
% reward is offered and animal remains in the port

% sma = AddState(sma, 'Name', 'water_L',... % Original state
%     'Timer', LeftValveTime,...
%     'StateChangeConditions', {'Tup','ITI'},... %'StateChangeConditions', {RightPortOut,'ITI'},...
%     'OutputActions', {'ValveState', LeftValve, 'WireState',10});
% sma = AddState(sma, 'Name', 'water_R',... % Original state
%     'Timer', RightValveTime,...
%     'StateChangeConditions', {'Tup','ITI'},... %'StateChangeConditions', {RightPortOut,'ITI'},...
%     'OutputActions', {'ValveState', RightValve, 'WireState',10});

% Modified water_L/R states
sma = AddState(sma, 'Name', 'water_L',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','lingersInPort_L'},... %'StateChangeConditions', {RightPortOut,'ITI'},...
    'OutputActions', {'ValveState', LeftValve, 'WireState',10});
sma = AddState(sma, 'Name', 'water_R',... 
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','lingersInPort_R'},... %'StateChangeConditions', {RightPortOut,'ITI'},...
    'OutputActions', {'ValveState', RightValve, 'WireState',10});

% New lingersInPort & lingersInPort_Grace states. Grace is required because the same logic of the grace
% period during waiting time remains valid here.
sma = AddState(sma, 'Name', 'lingersInPort_L',... 
    'Timer', 0,...
    'StateChangeConditions', {LeftPortOut,'lingersInPort_L_Grace'},... %'StateChangeConditions', {RightPortOut,'ITI'},...
    'OutputActions', {'WireState',2});
sma = AddState(sma, 'Name', 'lingersInPort_R',... 
    'Timer', 0,...
    'StateChangeConditions', {RightPortOut,'lingersInPort_R_Grace'},... %'StateChangeConditions', {RightPortOut,'ITI'},...
    'OutputActions', {'WireState',2});

sma = AddState(sma, 'Name', 'lingersInPort_L_Grace',... 
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions', {LeftPortIn,'lingersInPort_L','Tup','ITI'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'lingersInPort_R_Grace',... 
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions', {RightPortIn,'lingersInPort_R','Tup','ITI'},...
    'OutputActions', {});

%%%%%% End of changes related to lingersInPort



%%%%%%%%%%%
sma = AddState(sma, 'Name', 'timeOut_BrokeFixation',...
    'Timer',TaskParameters.GUI.TimeOutBrokeFixation,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'SoftCode',11});
sma = AddState(sma, 'Name', 'timeOut_EarlyWithdrawal',...
    'Timer',TaskParameters.GUI.TimeOutEarlyWithdrawal,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'SoftCode',11});
sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice',...
    'Timer',TaskParameters.GUI.TimeOutIncorrectChoice,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'SoftCode',11});

sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback',...
    'Timer',TaskParameters.GUI.TimeOutSkippedFeedback,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'SoftCode',12});

sma = AddState(sma, 'Name', 'skipped_feedback',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','timeOut_SkippedFeedback'},...
    'OutputActions', {});

% RMM - Remove feedback from skipped feedback trials (ie., correct choice, but
% doesn't wait long enough to get the reward)
sma = AddState(sma, 'Name', 'skipped_feedbackCorrectChoice',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','timeOut_SkippedFeedbackCorrectChoice'},...
    'OutputActions', {}); 

% RMM - 27.03.23
% Until today, catch trials invariably trigger skippedFeedback states &
% time out. I will change the state below so that there are no time out after
% correct decisions...

sma = AddState(sma, 'Name', 'timeOut_SkippedFeedbackCorrectChoice',...
    'Timer',0,... %Previous: 'Timer',TaskParameters.GUI.TimeOutSkippedFeedback,... %
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{}); %Simply do nothing in the output

% RMM


sma = AddState(sma, 'Name', 'missed_choice',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'ITI',...
    'Timer',max(TaskParameters.GUI.ITI,0),...
    'StateChangeConditions',{'Tup','exit'},...
    'OutputActions',{'SoftCode',9}); % Sets flow rates for next trial
% sma = AddState(sma, 'Name', 'state_name',...
%     'Timer', 0,...
%     'StateChangeConditions', {},...
%     'OutputActions', {});
end
