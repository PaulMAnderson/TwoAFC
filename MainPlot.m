function MainPlot(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem
global TaskParameters

switch Action
    case 'init'
        
        %% Outcome
        %initialize pokes plot
        nTrialsToShow = 100; %default number of trials to display
        
        if nargin >=3  %custom number of trials
            nTrialsToShow =varargin{1};
        end
        axes(AxesHandles.HandleOutcome);
        %         Xdata = 1:numel(SideList); Ydata = SideList(Xdata);
        %plot in specified axes
        BpodSystem.GUIHandles.OutcomePlot.Aud = line(-1,1,...
            'LineStyle','none',...
            'Marker','o',...
            'MarkerEdge',[.5,.5,.5],...
            'MarkerFace',[.7,.7,.7],...
            'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.DV = line(1:numel(BpodSystem.Data.Custom.DV),BpodSystem.Data.Custom.DV,...
            'LineStyle','none',...
            'Marker','o',...
            'MarkerEdge','b',...
            'MarkerFace','b',...
            'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(1,0,...
            'LineStyle','none',...
            'Marker','o',...
            'MarkerEdge','k',...
            'MarkerFace',[1 1 1],...
            'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(1,0,...
            'LineStyle','none',...
            'Marker','+','MarkerEdge',...
            'k','MarkerFace',...
            [1 1 1],...
            'MarkerSize',6);
                
        BpodSystem.GUIHandles.OutcomePlot.Correct = line(-1,1,...
            'LineStyle','none',...
            'Marker','o',...
            'MarkerEdge','g',...
            'MarkerFace','g',...
            'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.Incorrect = line(-1,1,...
            'LineStyle','none',...
            'Marker','o',...
            'MarkerEdge','r',...
            'MarkerFace','r',...
            'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.BrokeFix = line(-1,0,...
            'LineStyle','none',...
            'Marker','d',...
            'MarkerEdge','b',...
            'MarkerFace','none',...
            'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal = line(-1,0,...
            'LineStyle','none',...
            'Marker','d',...
            'MarkerEdge','none',...
            'MarkerFace','b',...
            'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoReward = line(-1,0,...
            'LineStyle','none',...
            'Marker','o',...
            'MarkerEdge','none',...
            'MarkerFace','w',...
            'MarkerSize',5);  
        BpodSystem.GUIHandles.OutcomePlot.NoResponse = line(-1,[0 1],...
            'LineStyle','none',...
            'Marker','x',...
            'MarkerEdge','w',...
            'MarkerFace','none',...
            'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.Catch = line(-1,[0 1],...
            'LineStyle','none',...
            'Marker','o',...
            'MarkerEdge',[0,0,0],...
            'MarkerFace',[0,0,0],...
            'MarkerSize',4);
        set(AxesHandles.HandleOutcome,...
            'TickDir', 'out',...
            'XLim',[0, nTrialsToShow],...
            'YLim', [-1.25, 1.25],...
            'YTick', [-1, 1],...
            'YTickLabel', {'Right','Left'},...
            'FontSize', 13);
        set(BpodSystem.GUIHandles.OutcomePlot.Aud,...
            'xdata',1:length(BpodSystem.Data.Custom.AuditoryOmega),...
            'ydata',BpodSystem.Data.Custom.DV);
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 14);
        hold(AxesHandles.HandleOutcome, 'on');
        
        %% Text Panel
        axes(AxesHandles.TextPanel);
        AxesHandles.TextPanel.XAxis.Color = 'w';
        AxesHandles.TextPanel.YAxis.Color = 'w';
        AxesHandles.TextPanel.YDir = 'reverse';

        textNames  = {'CumRwdL','CumRwdR','nTrialsL','nTrialsR',...
            'ChoiceLeft','ChoiceRight','PercCorrect','percCorrL',...
            'percCorrR','RewardDelay','currTr'};
        textLabels = {'Left: 0mL','Right: 0mL','Left trials: 0',...
            'Right trials: 0','Chose left: 0','Chose right: 0',...
            'Correct:','CorrL:','CorrR:','Curr delay:','Curr Trial:'};
        nLabels = length(textLabels);
        
        AxesHandles.TextPanel.XLim = [0 10];
        AxesHandles.TextPanel.YLim = [0 nLabels+1];

        xCoord = 9;
        yCoord = 0.5;
        textSettings = {'verticalalignment','bottom','horizontalalignment',...
            'right','FontSize',8};
        for labelI = 1:length(textLabels)
            BpodSystem.GUIHandles.OutcomePlot.(textNames{labelI}) = ...
                text(xCoord,yCoord,textLabels{labelI},textSettings{:});
            yCoord = yCoord + 1;
        end

        %% Psyc Auditory
        BpodSystem.GUIHandles.OutcomePlot.PsycAud = line(AxesHandles.HandlePsycAud,[-1 1],[.5 .5],...
            'LineStyle','none',...
            'Marker','o',...
            'MarkerEdge','k',...
            'MarkerFace','k',...
            'MarkerSize',6,...
            'Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.PsycAudMidLine = line(AxesHandles.HandlePsycAud,[-1. 1.],[.5 .5],...
            'color',[0.8, 0.8, 0.8],...
            'Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.PsycAudTopLine = line(AxesHandles.HandlePsycAud,[-1. 1.],[.9 .9],...
            'color',[0.85, 0.85, 0.85],...
            'Visible','off');        
        BpodSystem.GUIHandles.OutcomePlot.PsycAudBottomLine = line(AxesHandles.HandlePsycAud,[-1. 1.],[.1 .1],...
            'color',[0.85, 0.85, 0.85],...
            'Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.PsycAudVertLine = line(AxesHandles.HandlePsycAud,[0 0],[0 1],...
            'color',[0.9, 0.9, 0.9],...
            'Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.PsycAudFit = line(AxesHandles.HandlePsycAud,[-1. 1.],[.5 .5],...
            'color','k',...
            'Visible','off');
        AxesHandles.HandlePsycAud.YLim = [0 1.05];
        AxesHandles.HandlePsycAud.XLim = [-1.05, 1.05];
        AxesHandles.HandlePsycAud.XLabel.String = '[left]       Evidence       [right]'; % FIGURE OUT UNIT
        AxesHandles.HandlePsycAud.YLabel.String = '% Right Choice';
        AxesHandles.HandlePsycAud.Title.String = 'Psychometric Aud';
        %% Vevaiometric curve
        hold(AxesHandles.HandleVevaiometric,'on')
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch = line(AxesHandles.HandleVevaiometric,-2,-1,...
            'LineStyle','-',...
            'Color','g',...
            'Visible','off',...
            'LineWidth',2);
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr = line(AxesHandles.HandleVevaiometric,-2,-1,...
            'LineStyle','-',...
            'Color','r',...
            'Visible','off',...
            'LineWidth',2);
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr = line(AxesHandles.HandleVevaiometric,-2,-1,...
            'LineStyle','none',...
            'Color','r',...
            'Marker','x',...
            'MarkerFaceColor','r',...
            'MarkerSize',6,...
            'Visible','off',...
            'MarkerEdgeColor','r');
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch = line(AxesHandles.HandleVevaiometric,-2,-1,...
            'LineStyle','none',...
            'Color','g',...
            'Marker','x',...
            'MarkerFaceColor','g',...
            'MarkerSize',6,...
            'Visible','off',...
            'MarkerEdgeColor','g');
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricMidLine = line(AxesHandles.HandleVevaiometric,[0 0],[0 14],...
            'color',[0.8, 0.8, 0.8],...
            'Visible','off');
        AxesHandles.HandleVevaiometric.YLim = [0 14];
        AxesHandles.HandleVevaiometric.XLim = [-1.05, 1.05];
        AxesHandles.HandleVevaiometric.XLabel.String = '[left]       Evidence       [right]';
        AxesHandles.HandleVevaiometric.YLabel.String = 'WT (s)';
        AxesHandles.HandleVevaiometric.Title.String = 'Vevaiometric';
        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        BpodSystem.GUIHandles.OutcomePlot.TrialRate = line(AxesHandles.HandleTrialRate,[0],[0],...
            'LineStyle','-',...
            'Color','k',...
            'Visible','off'); %#ok<NBRAK>
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'nTrials';
        AxesHandles.HandleTrialRate.Title.String = 'Trial rate';
        %% Stimulus delay
        hold(AxesHandles.HandleFix,'on')
        AxesHandles.HandleFix.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFix.YLabel.String = 'trial counts';
        AxesHandles.HandleFix.Title.String = 'Pre-stimulus delay';
        %% ST histogram
        hold(AxesHandles.HandleST,'on')
        AxesHandles.HandleST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleST.YLabel.String = 'trial counts';
        AxesHandles.HandleST.Title.String = 'Stim sampling time';
        %% Reward Delay histogram
        hold(AxesHandles.HandleReward,'on')
        AxesHandles.HandleReward.XLabel.String = 'Time (ms)';
        AxesHandles.HandleReward.YLabel.String = 'trial counts';
        AxesHandles.HandleReward.Title.String = 'Reward delay';        
    case 'update'
        
        %% Check Trial Selection inputs
        iTrial = varargin{1}; % Need to get the trial number
        if TaskParameters.GUI.PlotRestrictRange
            startTrial = TaskParameters.GUI.PlotRangeStart;
            endTrial   = TaskParameters.GUI.PlotRangeEnd;
            if endTrial == 0
                endTrial = iTrial; % Use 0 to stand for dynamic end
            end
            if startTrial < 0 % if startTrial is negative subtract from current trial
                startTrial = max(1,(iTrial + startTrial));
            end
        else
            startTrial = 1;
            endTrial   = iTrial;
        end
        
        % Safety check to make sure they will work
        if startTrial < 1 || startTrial >= endTrial
                startTrial = 1;
        end
        if endTrial > iTrial || endTrial < startTrial
            endTrial = iTrial;
        end           
        
        nTrials = endTrial - startTrial + 1;
     
        %% Reposition and hide/show axes
        ShowPlots = [TaskParameters.GUI.ShowPsycAud,TaskParameters.GUI.ShowVevaiometric,...
                     TaskParameters.GUI.ShowTrialRate,TaskParameters.GUI.ShowFix,...
                     TaskParameters.GUI.ShowST,...
                     TaskParameters.GUI.ShowReward];
        plotHandles = {BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud,...
                       BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric,...
                       BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate,...
                       BpodSystem.GUIHandles.OutcomePlot.HandleFix,...
                       BpodSystem.GUIHandles.OutcomePlot.HandleST,...
                       BpodSystem.GUIHandles.OutcomePlot.HandleReward};                       
        NoPlots = sum(ShowPlots);
        NPlot = cumsum(ShowPlots);
        for plotI = 1:length(plotHandles)
            currentHandle = plotHandles{plotI};
            if ShowPlots(plotI)
                plotPosition = [NPlot(plotI)*.05+0.005 + (NPlot(plotI)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
                currentHandle.Position = plotPosition;
                currentHandle.Visible = 'on';
                set(plotHandles{plotI}.Children,'Visible','on')
            else
                currentHandle.Visible = 'off';
                set(plotHandles{plotI}.Children,'Visible','off')
            end       
        end
        
        %% Outcome
        % iTrial = varargin{1};
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,iTrial,nTrialsToShow); % recompute xlim
        
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle,...
            'xdata', iTrial+1,...
            'ydata', 0);
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross,...
            'xdata', iTrial+1,...
            'ydata', 0);
        
        %plot modality background
        set(BpodSystem.GUIHandles.OutcomePlot.Aud,...
            'xdata',1:length(BpodSystem.Data.Custom.AuditoryOmega),...
            'ydata',BpodSystem.Data.Custom.DV);
        %plot past&future trials
        set(BpodSystem.GUIHandles.OutcomePlot.DV,...
            'xdata', mn:numel(BpodSystem.Data.Custom.DV),...
            'ydata',BpodSystem.Data.Custom.DV(mn:end));
        
        %Plot past trial outcomes
        indxToPlot = mn:iTrial;
        %Cumulative Reward Amount
        R = BpodSystem.Data.Custom.RewardMagnitude;
        iRwd = BpodSystem.Data.Custom.Rewarded;
        C = zeros(size(R)); 
        C(BpodSystem.Data.Custom.ChoiceLeft==1&iRwd,1) = 1; 
        C(BpodSystem.Data.Custom.ChoiceLeft==0&iRwd,2) = 1;
        R = R(startTrial:endTrial,:).*C(startTrial:endTrial,:);
        lTrials = BpodSystem.Data.Custom.MoreLeftClicks(startTrial:endTrial);
        lTrials = lTrials(~isnan(lTrials));
        lChoice = BpodSystem.Data.Custom.ChoiceLeft(startTrial:endTrial);
        lChoice = lChoice(~isnan(lChoice));
        currRewardDelay = TaskParameters.GUI.RewardDelay;        
        
        %Plot Rewarded
        ndxCor = BpodSystem.Data.Custom.ChoiceCorrect(indxToPlot)==1;
        Xdata = indxToPlot(ndxCor);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxCor);
        set(BpodSystem.GUIHandles.OutcomePlot.Correct, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Incorrect
        ndxInc = BpodSystem.Data.Custom.ChoiceCorrect(indxToPlot)==0;
        Xdata = indxToPlot(ndxInc);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxInc);
        set(BpodSystem.GUIHandles.OutcomePlot.Incorrect, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Broken Fixation
        ndxBroke = BpodSystem.Data.Custom.BrokeFixation(indxToPlot);
        Xdata = indxToPlot(ndxBroke); Ydata = zeros(1,sum(ndxBroke));
        set(BpodSystem.GUIHandles.OutcomePlot.BrokeFix, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Early Withdrawal
        ndxEarly = BpodSystem.Data.Custom.EarlyWithdrawal(indxToPlot);
        Xdata = indxToPlot(ndxEarly);
        Ydata = zeros(1,sum(ndxEarly));
        set(BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal, 'xdata', Xdata, 'ydata', Ydata);
        %Plot missed choice trials
        ndxMiss = isnan(BpodSystem.Data.Custom.ChoiceLeft(indxToPlot))&~ndxBroke&~ndxEarly;
        Xdata = indxToPlot(ndxMiss);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxMiss);
        set(BpodSystem.GUIHandles.OutcomePlot.NoResponse, 'xdata', Xdata, 'ydata', Ydata);
        %Plot NoReward trials
        ndxNoReward = ~BpodSystem.Data.Custom.Rewarded(indxToPlot);
        Xdata = indxToPlot(ndxNoReward&~ndxMiss);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxNoReward&~ndxMiss);
        set(BpodSystem.GUIHandles.OutcomePlot.NoReward, 'xdata', Xdata, 'ydata', Ydata);   
        %Plot catch trials
        ndxCatch = BpodSystem.Data.Custom.CatchTrial(indxToPlot);
        Xdata = indxToPlot(ndxCatch&~ndxMiss);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxCatch&~ndxMiss);
        set(BpodSystem.GUIHandles.OutcomePlot.Catch, 'xdata', Xdata, 'ydata', Ydata);
        
        %% Text Panel
        axes(AxesHandles.TextPanel);

        set(BpodSystem.GUIHandles.OutcomePlot.CumRwdL,...
            'string', ['Left: ' num2str(sum(R(:,1))/1000) ' mL']);
        set(BpodSystem.GUIHandles.OutcomePlot.CumRwdR,...
            'string', ['Right: ' num2str(sum(R(:,2))/1000) ' mL']);
        set(BpodSystem.GUIHandles.OutcomePlot.nTrialsL,...        
            'string', ['Left trials: ', num2str(sum(lTrials))]);
        set(BpodSystem.GUIHandles.OutcomePlot.nTrialsR,...
            'string', ['Right trials: ', num2str(sum(~lTrials))]);
         set(BpodSystem.GUIHandles.OutcomePlot.ChoiceLeft,...
            'string', ['Chose left: ', num2str(sum(lChoice))]);
        set(BpodSystem.GUIHandles.OutcomePlot.ChoiceRight,...
            'string', ['Chose right: ', num2str(sum(~lChoice))]);
        set(BpodSystem.GUIHandles.OutcomePlot.PercCorrect,...
            'string', sprintf('Correct: %.0f %%',...
            (nansum(BpodSystem.Data.Custom.ChoiceCorrect(startTrial:endTrial))/(length(lTrials)...
            -nansum(BpodSystem.Data.Custom.EarlyWithdrawal(startTrial:endTrial))...
            -nansum(BpodSystem.Data.Custom.BrokeFixation(startTrial:endTrial))))*100));
        choiceCorrectInRange = BpodSystem.Data.Custom.ChoiceCorrect(startTrial:endTrial);
        trialsLeftInRange = BpodSystem.Data.Custom.MoreLeftClicks(startTrial:endTrial);
        EarlyWithdrawalInRange = BpodSystem.Data.Custom.EarlyWithdrawal(startTrial:endTrial);
        BrokeFixationInRange = BpodSystem.Data.Custom.BrokeFixation(startTrial:endTrial);        
        if any(isnan(trialsLeftInRange))
            trialsLeftInRange(isnan(trialsLeftInRange)) = 0;
        end
        if any(isnan(choiceCorrectInRange))
            choiceCorrectInRange(isnan(choiceCorrectInRange)) = 0;
        end
        if any(isnan(EarlyWithdrawalInRange))
            EarlyWithdrawalInRange(isnan(EarlyWithdrawalInRange)) = 0;
        end
        if any(isnan(BrokeFixationInRange))
            BrokeFixationInRange(isnan(BrokeFixationInRange)) = 0;
        end
        
        percCorrL = sum(choiceCorrectInRange & trialsLeftInRange)/(sum(trialsLeftInRange)-sum(EarlyWithdrawalInRange(logical(trialsLeftInRange)))...
            -sum(BrokeFixationInRange(logical(trialsLeftInRange))))*100;
        
        percCorrR = sum(choiceCorrectInRange & ~trialsLeftInRange)/(sum(~trialsLeftInRange)-sum(EarlyWithdrawalInRange(~trialsLeftInRange))...
            -sum(BrokeFixationInRange(~trialsLeftInRange)))*100;
        
        set(BpodSystem.GUIHandles.OutcomePlot.percCorrL,...
            'string', sprintf('CorrL: %.0f %%',percCorrL));       
        set(BpodSystem.GUIHandles.OutcomePlot.percCorrR,...
            'string', sprintf('CorrR: %.0f %%', percCorrR));        
        set(BpodSystem.GUIHandles.OutcomePlot.RewardDelay,...
            'string', ['Delay: ', num2str(currRewardDelay)]);
        set(BpodSystem.GUIHandles.OutcomePlot.currTr,...
            'string', ['currTrial: ', num2str(iTrial)]);        

        %% Psych Aud
        if TaskParameters.GUI.ShowPsycAud
            AudDV = -BpodSystem.Data.Custom.DV(1:numel(BpodSystem.Data.Custom.ChoiceLeft));
            ndxAud = ones(1,numel(BpodSystem.Data.Custom.ChoiceLeft));
            ndxNan = isnan(BpodSystem.Data.Custom.ChoiceLeft);
            ChoiceRight = BpodSystem.Data.Custom.ChoiceLeft;
            ChoiceRight(ndxNan) = 1;
            ChoiceRight = ~ChoiceRight;
            
            % Select trials
            if TaskParameters.GUI.PlotRestrictRange
                AudDV       = AudDV(startTrial:endTrial);
                ndxAud      = ndxAud(startTrial:endTrial);
                ndxNan      = ndxNan(startTrial:endTrial);
                ChoiceRight = ChoiceRight(startTrial:endTrial);
            end
            
            AudBin = 8;
            BinIdx = discretize(AudDV,linspace(-1,1,AudBin+1));
            PsycY = grpstats(ChoiceRight(ndxAud&~ndxNan),BinIdx(ndxAud&~ndxNan),'mean');
            PsycX = unique(BinIdx(ndxAud&~ndxNan))/AudBin*2-1-1/AudBin;
            BpodSystem.GUIHandles.OutcomePlot.PsycAud.YData = PsycY;
            BpodSystem.GUIHandles.OutcomePlot.PsycAud.XData = PsycX;
            % Get a warning for the glmfit function sometimes
            warning('off','stats:glmfit:IterationLimit');
            warning('off','stats:glmfit:PerfectSeparation');
            if sum(ndxAud&~ndxNan) > 1
                BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.XData = linspace(min(AudDV),max(AudDV),100);
                BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.YData = glmval(glmfit(AudDV(ndxAud&~ndxNan),...
                    ChoiceRight(ndxAud&~ndxNan)','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
            end
        end
        %% Vevaiometric
        if TaskParameters.GUI.ShowVevaiometric
            ndxError = BpodSystem.Data.Custom.ChoiceCorrect(startTrial:endTrial) == 0 ; %all (completed) error trials (including catch errors)
            ndxCorrectCatch = BpodSystem.Data.Custom.CatchTrial(startTrial:endTrial) & BpodSystem.Data.Custom.ChoiceCorrect(startTrial:endTrial) == 1; %only correct catch trials
            ndxMinWT = BpodSystem.Data.Custom.ChoicePortTime(startTrial:endTrial) > TaskParameters.GUI.VevaiometricMinWT;
            DV = -BpodSystem.Data.Custom.DV(startTrial:endTrial);
            DVNBin = TaskParameters.GUI.VevaiometricNBin;
            WT = BpodSystem.Data.Custom.ChoicePortTime(startTrial:endTrial);
            BinIdx = discretize(DV,linspace(-1,1,DVNBin+1));
            WTerr = grpstats(WT(ndxError&ndxMinWT),BinIdx(ndxError&ndxMinWT),'mean')';
            WTcatch = grpstats(WT(ndxCorrectCatch&ndxMinWT),BinIdx(ndxCorrectCatch&ndxMinWT),'mean')';
            Xerr = unique(BinIdx(ndxError&ndxMinWT))/DVNBin*2-1-1/DVNBin;
            Xcatch = unique(BinIdx(ndxCorrectCatch&ndxMinWT))/DVNBin*2-1-1/DVNBin;   
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr.YData = WTerr;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr.XData = Xerr;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch.YData = WTcatch;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch.XData = Xcatch;
            if TaskParameters.GUI.VevaiometricShowPoints
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.YData = WT(ndxError&ndxMinWT);
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.XData = DV(ndxError&ndxMinWT);
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.YData = WT(ndxCorrectCatch&ndxMinWT);
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.XData = DV(ndxCorrectCatch&ndxMinWT);
            else
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.YData = -1;
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.XData = 0;
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.YData = -1;
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.XData = 0;
            end
        end
        %% Trial rate
        if TaskParameters.GUI.ShowTrialRate
            BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60;
            BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(BpodSystem.Data.Custom.ChoiceLeft);       
            try % never initialised it so we just try and delete it every time
                delete(BpodSystem.GUIHandles.OutcomePlot.PlotRange)
            end
            if TaskParameters.GUI.PlotRestrictRange % Show trials being plotted               
                BpodSystem.GUIHandles.OutcomePlot.PlotRange = ...
                    line(BpodSystem.GUIHandles.OutcomePlot.TrialRate.Parent,...
                    BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData(startTrial:endTrial),...
                    BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData(startTrial:endTrial),...
                    'LineStyle','-','Color','g');
            end                
        end
        if TaskParameters.GUI.ShowFix
            %% Stimulus delay
            cla(AxesHandles.HandleFix)
            fixDur = BpodSystem.Data.Custom.FixationTime(startTrial:endTrial);
            BpodSystem.GUIHandles.OutcomePlot.HistBroke = histogram(AxesHandles.HandleFix,fixDur(BpodSystem.Data.Custom.BrokeFixation(startTrial:endTrial))*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistFix = histogram(AxesHandles.HandleFix,fixDur(~BpodSystem.Data.Custom.BrokeFixation(startTrial:endTrial))*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistFix.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistFix.FaceColor = 'b';
            BpodSystem.GUIHandles.OutcomePlot.HistFix.EdgeColor = 'none';
            BreakP = mean(BpodSystem.Data.Custom.BrokeFixation);
            cornertext(AxesHandles.HandleFix,sprintf('P=%1.2f',BreakP))
        end
        %% ST - Sampling Time
        if TaskParameters.GUI.ShowST
            cla(AxesHandles.HandleST)
            st = BpodSystem.Data.Custom.SamplingTime(startTrial:endTrial);
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly = histogram(AxesHandles.HandleST,st(BpodSystem.Data.Custom.EarlyWithdrawal(startTrial:endTrial))*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistST = histogram(AxesHandles.HandleST,st(~BpodSystem.Data.Custom.EarlyWithdrawal(startTrial:endTrial))*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistST.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistST.FaceColor = 'b';
            BpodSystem.GUIHandles.OutcomePlot.HistST.EdgeColor = 'none';
            EarlyP = sum(BpodSystem.Data.Custom.EarlyWithdrawal)/sum(~BpodSystem.Data.Custom.BrokeFixation);
            cornertext(AxesHandles.HandleST,sprintf('P=%1.2f',EarlyP))
        end
        %% Reward delay (exclude catch trials and error trials, if set on catch)
        if TaskParameters.GUI.ShowReward
            cla(AxesHandles.HandleReward)
            ndxExclude = false(1,nTrials);
            WT = BpodSystem.Data.Custom.ChoicePortTime(startTrial:endTrial);
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed = histogram(AxesHandles.HandleReward,...
                                                                     WT(~BpodSystem.Data.Custom.Rewarded(startTrial:endTrial)...
                                                                         &~BpodSystem.Data.Custom.CatchTrial(startTrial:endTrial)...
                                                                         &~ndxExclude)*1000....
                                                                    );
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.BinWidth = 100;
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.FaceColor = 'r';
            %BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.Normalization = 'probability';
            BpodSystem.GUIHandles.OutcomePlot.HistFeed = histogram(AxesHandles.HandleReward,...
                                                                   WT(BpodSystem.Data.Custom.Rewarded(startTrial:endTrial)...
                                                                       &~BpodSystem.Data.Custom.CatchTrial(startTrial:endTrial)...
                                                                       &~ndxExclude)*1000....
                                                                   );
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.FaceColor = 'b';
            %BpodSystem.GUIHandles.OutcomePlot.HistFeed.Normalization = 'probability';
            %LeftSkip = sum(~BpodSystem.Data.Custom.Rewarded(startTrial:endTrial)&~BpodSystem.Data.Custom.CatchTrial(startTrial:endTrial)&~ndxExclude&BpodSystem.Data.Custom.ChoiceLeft(startTrial:endTrial)==1)/sum(~BpodSystem.Data.Custom.CatchTrial(startTrial:endTrial)&~ndxExclude&BpodSystem.Data.Custom.ChoiceLeft(startTrial:endTrial)==1);
            %RightSkip = sum(~BpodSystem.Data.Custom.Rewarded(startTrial:endTrial)&~BpodSystem.Data.Custom.CatchTrial(startTrial:endTrial)&~ndxExclude&BpodSystem.Data.Custom.ChoiceLeft(startTrial:endTrial)==0)/sum(~BpodSystem.Data.Custom.CatchTrial(startTrial:endTrial)&~ndxExclude&BpodSystem.Data.Custom.ChoiceLeft(startTrial:endTrial)==0);
            %cornertext(AxesHandles.HandleReward,{sprintf('L=%1.3f',LeftSkip),sprintf('R=%1.3f',RightSkip)})
            
            % Update min max and tau lines on the feedback histogram
            BpodSystem.GUIHandles.OutcomePlot.RewardMin = line(AxesHandles.HandleReward,...
                [TaskParameters.GUI.RewardDelayTable.Min TaskParameters.GUI.RewardDelayTable.Min].*1000,...
                [AxesHandles.HandleReward.YLim(1) AxesHandles.HandleReward.YLim(2)],...
                'color',[0.5 0.5 0.5]);
            BpodSystem.GUIHandles.OutcomePlot.RewardMax = line(AxesHandles.HandleReward,...
                [TaskParameters.GUI.RewardDelayTable.Max TaskParameters.GUI.RewardDelayTable.Max].*1000,...
                [AxesHandles.HandleReward.YLim(1) AxesHandles.HandleReward.YLim(2)],...
                'color',[0.5 0.5 0.5]);
            BpodSystem.GUIHandles.OutcomePlot.RewardTau = line(AxesHandles.HandleReward,...
                 [TaskParameters.GUI.RewardDelayTable.Tau TaskParameters.GUI.RewardDelayTable.Tau].*1000,...
                [AxesHandles.HandleReward.YLim(1) AxesHandles.HandleReward.YLim(2)],...
                'color',[0.5 0.5 0.5],'LineStyle',':');
        end
end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

function cornertext(h,str)
unit = get(h,'Units');
set(h,'Units','char');
pos = get(h,'Position');
if ~iscell(str)
    str = {str};
end
for i = 1:length(str)
    x = pos(1)+1;
    y = pos(2)+pos(4)-i;
    uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
end
set(h,'Units',unit);
end

