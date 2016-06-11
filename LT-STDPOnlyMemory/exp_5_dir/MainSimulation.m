%% Initializing Relevant Paths
WorkingMemoryDir=deblank(fileread('./TimeDelNetSim_build/install/ModulePath.txt'));
PolychronousGroupFindDir=deblank(fileread('./PolychronousGroupFind_build/install/ModulePath.txt'));
addpath ./TimeDelNetSim_build/install
addpath ./PolychronousGroupFind_build/install
addpath(fullfile(WorkingMemoryDir, 'TimeDelNetSim', 'MatlabSource'));
addpath(fullfile(WorkingMemoryDir, 'ExternalInputCurrent', 'MatlabSource'));
addpath(fullfile(WorkingMemoryDir, 'MexMemoryInterfacing', 'MatlabSource'));
addpath(fullfile(PolychronousGroupFindDir, 'PolychronousGroupFind', 'MatlabSource'));

%% Network Design

rng('default');
rng(35);
N = 1000;
E = 0.8;
WorkingMemNetParams.NExc          = round(N*E);
WorkingMemNetParams.NInh          = round(N - N*E);

WorkingMemNetParams.F_E           = 100;
WorkingMemNetParams.F_IE          = 100;

WorkingMemNetParams.InitInhWeight = -5;
WorkingMemNetParams.InitExcWeight = 6;

WorkingMemNetParams.DelayRange    = 20;

[A, Ninh, Weights, Delays] = WorkingMemNet(WorkingMemNetParams);

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

%% Spike Plots Generation

% Clearing InputStruct
clear InputStruct;

% Getting Midway state
% InputStruct = InputStateSparse;
% InputStruct.InitialState = getSingleState(StateVarsSpikeListCurrFSF, 200*1000);

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

InputStruct.onemsbyTstep          = int32(1);
InputStruct.DelayRange            = int32(WorkingMemNetParams.DelayRange);

InputStruct.NoOfms                = int32(300*1000);
InputStruct.StatusDisplayInterval = int32(3000);

InputStruct.ST_STDP_MaxRelativeInc      = single(2);
InputStruct.ST_STDP_EffectMaxCausal     = single(0);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0);
InputStruct.ST_STDP_DecayWithTime       = single(exp(-1/20000));

InputStruct.W0                          = single(0.3);

InputStruct.Iext.IExtAmplitude = single(30);
InputStruct.Iext.AvgRandSpikeFreq = single(0.3);

IExtPatternString = {
    'from 0   to 100s, every 10s      '
    '    from 0 to 2s, every 200ms    '
    '        from 0 onwards generate 1'
    'from 100s to 200s, every 10s     '
    '    from 0 to 2s, every 200ms    '
    '        from 0 onwards generate 2'
    'from 200s to 300s, every 10s     '
    '    from 0 to 2s, every 300ms    '
    '        from 0 onwards generate 3'
};

InputStruct.Iext.IExtPattern = getIExtPatternFromString(IExtPatternString);
rng(40);
InputStruct.Iext.IExtPattern.NeuronPatterns{end+1} = uint32([1,30]);
InputStruct.Iext.IExtPattern.NeuronPatterns{end+1} = uint32([120, 91]);
InputStruct.Iext.IExtPattern.NeuronPatterns{end+1} = uint32([80, 51]);
InputStruct.Iext.IExtPattern.NeuronPatterns{end+1} = uint32([150, 121]);
InputStruct.Iext.IExtPattern.NeuronPatterns{end+1} = uint32([181, 210]);
InputStruct.Iext.IExtPattern.NeuronPatterns{end+1} = uint32([0, randperm(30), 0]);

InputStruct.MaxSynWeight          = single(12);

InputStruct.OutputFile = 'SimResults1000DebugSpikeListfrom5Hours.mat';

% Get Full State every 1 secs
OutputOptions               = {'FSF', 'SpikeList', 'Final', 'Initial'};
InputStruct.StorageStepSize = int32(1000);
InputStruct.OutputControl   = strjoin(OutputOptions);
% save('..\WorkingMemory\TimeDelNetSim\Data\InputData.mat', 'InputStruct');

[OutputVarsSpikeListCurrFSF, ...
	StateVarsSpikeListCurrFSF, ...
	FinalStateSpikeListCurrFSF, ...
	InputStateSpikeListCurrFSF] = TimeDelNetSim(InputStruct);

clear functions;

%% Plotting SpikeList 0-100
InitTime = double(InputStateSpikeListCurrFSF.InitialState.Time)/(1000*double(InputStruct.onemsbyTstep));
BegTime = InitTime + 000;
EndTime = InitTime + 100;% + 25;

SpikePlot_0_100 = figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStruct, OutputVarsSpikeListCurrFSF.SpikeList);
plot(GenerationTimeVect/(1000*double(InputStruct.onemsbyTstep)) - InitTime, double(InputStruct.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);

MaximizePlot
xlabel('Time in s.', 'fontsize', 15)
ylabel('Neuron Index', 'fontsize', 15)

%% Plotting SpikeList 100-200
InitTime = double(InputStateSpikeListCurrFSF.InitialState.Time)/(1000*double(InputStruct.onemsbyTstep));
BegTime = InitTime + 50;
EndTime = InitTime + 150;% + 25;

SpikePlot_100_200 = figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStruct, OutputVarsSpikeListCurrFSF.SpikeList);
plot(GenerationTimeVect/(1000*double(InputStruct.onemsbyTstep)) - InitTime, double(InputStruct.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);

MaximizePlot
xlabel('Time in s.', 'fontsize', 15)
ylabel('Neuron Index', 'fontsize', 15)

%% Plotting SpikeList 200-300
InitTime = double(InputStateSpikeListCurrFSF.InitialState.Time)/(1000*double(InputStruct.onemsbyTstep));
BegTime = InitTime + 200;
EndTime = InitTime + 300;% + 25;

SpikePlot_200_300 = figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStruct, OutputVarsSpikeListCurrFSF.SpikeList);
plot(GenerationTimeVect/(1000*double(InputStruct.onemsbyTstep)) - InitTime, double(InputStruct.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);

MaximizePlot
xlabel('Time in s.', 'fontsize', 15)
ylabel('Neuron Index', 'fontsize', 15)

%% Calculating Correlation

onemsbyTstep = double(InputStateSpikeListCurrFSF.onemsbyTstep);
BegTime = double(InputStateSpikeListCurrFSF.InitialState.Time)/1000;

BegOffset = 90;
EndOffset = 90.2;

SpikeMatSmall  = getSparseSpikeArr(InputStateSpikeListCurrFSF, OutputVarsSpikeListCurrFSF.SpikeList, BegTime+BegOffset, BegTime+EndOffset);

BegOffset = 90;
EndOffset = 130;

SpikeMatLong   = getSparseSpikeArr(InputStateSpikeListCurrFSF, OutputVarsSpikeListCurrFSF.SpikeList, BegTime+BegOffset, BegTime+EndOffset);

CorrelationArr = getSpikeCorr(SpikeMatSmall(60:800,:), SpikeMatLong(60:800,:), 2);
CorrelationPlot = figure;
plot((0:length(CorrelationArr)-1)/(1000*onemsbyTstep), CorrelationArr)

MaximizePlot();
xlabel('Offset in s', 'fontsize', 15);
ylabel('Correlation', 'fontsize', 15);

%% Creating movie of histogram of Effective Weights for the different time instants
%  Tilt the screen for best effect

HistMovie = VideoWriter('WeightHistMovie1.avi');
HistMovie.FrameRate = 4;
open(HistMovie);
currfig = figure;
for i = 1:length(StateVarsSpikeListCurrFSF.Time)
	EffWeights = getEffectiveWeights(...
		getSingleRecord(StateVarsSpikeListCurrFSF, i), ...
		InputStateSpikeListCurrFSF);
	
	CurrTimems = StateVarsSpikeListCurrFSF.Time(i)/(InputStruct.onemsbyTstep);
	NoOfSpikes = OutputVarsSpikeListCurrFSF.NoOfSpikes(i);
	
% 	% Bar graph plotting
% 	
% 	subplot(3,1,1); bar([10, 20], [nnz(EffWeights < 9.5), nnz(EffWeights >= 9.5)]);
% 	title(sprintf('T = %d', CurrTimems/1000 - 18000));
% 	xlim([0, 30]);
% 	ylim([0 10000]);
	
	% Histogram Plotting
	subplot(3,1,1); hist(EffWeights(EffWeights >= 8), 8:27);
	title(sprintf('T = %d', CurrTimems/1000));
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
% MinWeightSyn;
% RequiredConcurrency;
% DelayedSpikeProb;
% SpikeProbThreshold;
% MinLengthThreshold;
% MaxLengthThreshold;

InputStruct = InputStateSpikeListCurrFSF;
InputStruct.InitialState = getSingleState(StateVarsSpikeListCurrFSF, 290*1000);
InputStruct.InitialState.Weight = InputStruct.InitialState.Weight; % getEffectiveWeights(InputStruct.InitialState.Weight, InputStruct.InitialState.ST_STDP_RelativeInc);
InputStruct.MinWeightSyn = single(10);
InputStruct.DelayedSpikeProb = single(0.8);
InputStruct.MinLengthThreshold = int32(4);

PNGList = PolychronousGroupFind(InputStruct);
