rmpath('..\..\x64\Debug_Lib');
addpath('..\WorkingMemory\TimeDelNetSim\x64\Release_Lib\');
addpath('..\WorkingMemory\TimeDelNetSim\MatlabSource\');
% addpath('export_fig-master');

%%
rng('default');
rng(25);
N = 1000;
E = 0.8;
RecurrentNetParams.NExc = round(N*E);
RecurrentNetParams.NInh = round(N - N*E);

RecurrentNetParams.NSynExctoExc = ceil(100*N/2000);
RecurrentNetParams.NSynExctoInh = ceil(100*N/2000);
RecurrentNetParams.NSynInhtoExc = ceil(1200*N/2000);

RecurrentNetParams.MeanExctoExc = 0.5*2000/N;
RecurrentNetParams.MeanExctoInh = 0.15*2000/N;
RecurrentNetParams.MeanInhtoExc = -0.7*2000/N;

RecurrentNetParams.Var          = 0.2;
RecurrentNetParams.DelayRange   = 20;

[A, Ninh, Weights, Delays] = WorkingMemNet();

a = 0.02*ones(N,1);
b = 0.2*ones(N,1);
c = -65*ones(N,1);
d = 8*ones(N,1);

a(Ninh) = 0.1;
b(Ninh) = 0.2;
c(Ninh) = -65;
d(Ninh) = 2;
% Delays = Delays + 10;
[NEndVect, NStartVect] = find(A);

%% Getting Long Sparse Vector

OutputOptions = {'FSF', 'Initial'};
% Clearing InputStruct
clear InputStruct;

% Getting Midway state
InputStruct.a = single(a);
InputStruct.b = single(b);
InputStruct.c = single(c);
InputStruct.d = single(d);

InputStruct.NStart = int32(NStartVect);
InputStruct.NEnd   = int32(NEndVect);
InputStruct.InitialState.Weight = single(Weights);
InputStruct.Delay  = single(Delays);

InputStruct.V = single(-65*ones(N,1));
InputStruct.U = single(0.2*InputStruct.V);

InputStruct.onemsbyTstep                   = int32(1);
InputStruct.NoOfms                         = int32(5*60*60*1000);
InputStruct.DelayRange                     = int32(RecurrentNetParams.DelayRange);
InputStruct.StorageStepSize                = int32(60*1000);
InputStruct.OutputControl                  = strjoin(OutputOptions);
InputStruct.StatusDisplayInterval          = int32(4000);
InputStruct.InitialState.Iext.IExtGenState = uint32(30);

InputStruct.MaxSynWeight                   = single(8);
InputStruct.ST_STDP_EffectMaxCausal        = single(0.0);
InputStruct.ST_STDP_EffectMaxAntiCausal    = single(0.0);
InputStruct.Iext.IExtAmplitude             = single(0);
InputStruct.Iext.AvgRandSpikeFreq          = single(1);

InputStruct.OutputFile = 'SimResults1000Sparse5Hours.mat';

if ~exist('../WorkingMemory/TimeDelNetSim/Data', 'dir')
	mkdir('../WorkingMemory/TimeDelNetSim/Data')
end
save('../WorkingMemory/TimeDelNetSim/Data/InputData.mat', 'InputStruct');

% [OutputVarsSparse, StateVarsSparse, FinalStateSparse, InputStateSparse] = TimeDelNetSimMEX_Lib(InputStruct);
% Run the program after this
! start "TimeDelNetSim Sparse Simulation" /d . "powershell" ". .\Release_Exe.ps1"
%% Loading 5 Hours Long Long Term STDP Simulation Result
load('../WorkingMemory/TimeDelNetSim/Data/SimResults1000Sparse5Hours.mat');
clear OutputVarsSparse StateVarsSparse InputStateSparse FinalStateSparse;
OutputVarsSparse = OutputVars;
StateVarsSparse = StateVars;
InputStateSparse = InputState;
FinalStateSparse = FinalState;
clear OutputVars StateVars InputState FinalState;

%% Spike Plots Generation

% Clearing InputStruct
clear InputStruct;

% Getting Midway state
InputStruct = InputStateSparse;
InputStruct.InitialState = FinalStateSparse;

InputStruct.NoOfms                = int32(1000*1000);
InputStruct.StatusDisplayInterval = int32(3000);

InputStruct.ST_STDP_MaxRelativeInc      = single(2.5);
InputStruct.ST_STDP_EffectMaxCausal     = single(0.1);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0.12);

InputStruct.Iext.IExtAmplitude = single(30);
InputStruct.Iext.W0            = single(0.1);
InputStruct.Iext.AvgRandSpikeFreq = single(0.3);
InputStruct.Iext.MajorTimePeriod = uint32(15000);
InputStruct.Iext.MajorOnTime     = uint32(1000);
InputStruct.Iext.MinorTimePeriod = uint32(110);
InputStruct.Iext.NoOfNeurons     = uint32(60);

InputStruct.InitialState.Weight(InputStruct.NEnd > 800) = 6;
InputStruct.OutputFile = 'SimResults1000DebugSpikeListfrom5Hours.mat';

% % Get SpikeList
% OutputOptions               = {'SpikeList', 'Final', 'Initial'};
% InputStruct.StorageStepSize = int32(0);
% InputStruct.OutputControl   = strjoin(OutputOptions);
% [OutputVarsSpikeListCurr, StateVarsSpikeListCurr, FinalStateSpikeListCurr, InputStateSpikeListCurr] = TimeDelNetSim_WorkingMemory(InputStruct);

% Get Full State every 3 secs
OutputOptions               = {'Weight','ST_STDP_RelativeInc', 'Final', 'Initial'};
InputStruct.StorageStepSize = int32(4000);
InputStruct.OutputControl   = strjoin(OutputOptions);
[OutputVarsSpikeListCurrFSF, StateVarsSpikeListCurrFSF, FinalStateSpikeListCurrFSF, InputStateSpikeListCurrFSF] = TimeDelNetSim_WorkingMemory(InputStruct);

clear functions;

%% Plotting SpikeList
BegTime = (5*60)*60 + 510;
EndTime = (5*60)*60 + 530;

figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStruct, StateVarsSpikeListCurr.Time, OutputVarsSpikeListCurr.SpikeList);
plot(GenerationTimeVect - BegTime*1000*double(InputStruct.onemsbyTstep), double(InputStruct.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
% PlotSpikePropagation(InputStruct, GenerationTimeVect, SpikeSynIndVect);

%% Creating movie of histogram of Effective Weights for the different time instants
%  Tilt the screen for best effect

HistMovie = VideoWriter('WeightHistMovie.avi');
HistMovie.FrameRate = 2;
open(HistMovie);
currfig = figure;
for i = 1:length(StateVarsSpikeListCurrFSF.Time)
	EffWeights = getEffectiveWeights(...
		StateVarsSpikeListCurrFSF.Weight(:,i), ...
		StateVarsSpikeListCurrFSF.ST_STDP_RelativeInc(:,i));
	
	CurrTimems = StateVarsSpikeListCurrFSF.Time(i)/(InputStruct.onemsbyTstep);
	NoOfSpikes = OutputVarsSpikeListCurrFSF.NoOfSpikes(i);
	
	subplot(3,1,1); hist(EffWeights(EffWeights >= 0), 0:24);
	title(sprintf('T = %d', CurrTimems/1000 - 18000));
	xlim([0, 30]);
	ylim([0 35000]);
	
	subplot(3,1,2); hist(StateVarsSpikeListCurrFSF.Weight(EffWeights >= 0, i), 0:24);
	xlim([0, 30]);
	ylim([0 35000]);
	
	RelativeIncPlot = StateVarsSpikeListCurrFSF.ST_STDP_RelativeInc(EffWeights >= 0, i);
	RelativeIncPlot(RelativeIncPlot < 0) = 0;
	subplot(3,1,3); hist(RelativeIncPlot, 0:0.1:2.5);
 	xlim([0, 3]);
	ylim([0 40000]);
	xlabel(sprintf('Spikes Generated = %d', NoOfSpikes));
	
	MaximizePlot();
	frame = getframe(gcf);
	writeVideo(HistMovie, frame);
end
close(HistMovie);
clear HistMovie i 

%% Calculating Polychronous groups
addpath('..\PolychronousGroupFind\PolychronousGroupFind\x64\Release_Lib\');
% MinWeightSyn;
% RequiredConcurrency;
% DelayedSpikeProb;
% SpikeProbThreshold;
% MinLengthThreshold;
% MaxLengthThreshold;

InputStruct = InputStateSparse;
InputStruct.InitialState = <appropriate state>;
InputStruct.MinWeightSyn = single(7.8);
InputStruct.MinLengthThreshold = int32(5);

PNGList = PolychronousGroupFind(InputStruct);
rmpath('..\PolychronousGroupFind\PolychronousGroupFind\x64\Release_Lib\');
