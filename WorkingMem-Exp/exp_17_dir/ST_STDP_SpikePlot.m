%% Initializing Relevant Paths
WorkingMemoryDir=deblank(fileread('./TimeDelNetSim_build/install/ModulePath.txt'));
addpath ./TimeDelNetSim_build/install
addpath(fullfile(WorkingMemoryDir, 'TimeDelNetSim', 'MatlabSource'));
addpath(fullfile(WorkingMemoryDir, 'ExternalInputCurrent', 'MatlabSource'));
addpath(fullfile(WorkingMemoryDir, 'MexMemoryInterfacing', 'MatlabSource'));

%% Loading 5 Hours Long Long Term STDP Simulation Result
load('./TimeDelNetSim_build/Data/OutputSparse5Hours.mat');
clear OutputVarsSparse StateVarsSparse InputStateSparse FinalStateSparse;
OutputVarsSparse = OutputVars;
StateVarsSparse = StateVars;
InputStateSparse = InputState;
FinalStateSparse = FinalState;
clear OutputVars StateVars InputState FinalState;

%% Spike Plots Generation

% Clearing InputStruct
clear InputStruct;

% Initializing InputStruct
InputStruct = InputStateSparse;
InputStruct.InitialState = FinalStateSparse;

% Simulation Parameters
InputStruct.NoOfms                = int32(150*1000);

% LT-STDP Related Parameters
InputStruct.W0 = single(0);

% ST-STDP Related Parameters
InputStruct.ST_STDP_MaxRelativeInc      = single(2);
InputStruct.ST_STDP_DecayWithTime       = single(exp(-1/5000));
InputStruct.ST_STDP_EffectDecay         = single(exp(-1/8));
InputStruct.ST_STDP_EffectMaxCausal     = single(0.16);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0.18);

% External Input Current Parameters
InputStruct.Iext.IExtAmplitude    = single(30);
InputStruct.Iext.IRandAmplitude   = single(30);
InputStruct.Iext.AvgRandSpikeFreq = single(0.3);

% External Input Current Pattern
PatternStringArray = {
	'from 0 onwards every 15s         '
	'    from 0 to 1100ms every 110ms '
	'        from 0 onwards generate 1'
	};
InputStruct.Iext.IExtPattern      = getEmptyIExtPattern();
InputStruct.Iext.IExtPattern      = getIExtPatternFromString(PatternStringArray);
InputStruct.Iext.IExtPattern.NeuronPatterns = {uint32([1,60])};

% Network Structure Parameters
InputStruct.InitialState.Weight(InputStruct.NEnd > 800) = 8;

% Interfacing Parameters
% Get Full State every 1 secs
OutputOptions               = {'FSF', 'SpikeList', 'Final', 'Initial'};
InputStruct.StorageStepSize = int32(2000);
InputStruct.OutputControl   = strjoin(OutputOptions);
InputStruct.StatusDisplayInterval = int32(3000);

[OutputVarsSpikeListCurrFSF, StateVarsSpikeListCurrFSF, FinalStateSpikeListCurrFSF, InputStateSpikeListCurrFSF] = TimeDelNetSim(InputStruct);

%% Plotting SpikeList upto 120ms
InitTime = double(FinalStateSparse.Time)/1000;
BegTime = InitTime + 0;
EndTime = InitTime + 120;% + 25;

figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStruct, OutputVarsSpikeListCurrFSF.SpikeList);
plot(GenerationTimeVect/1000 - InitTime*double(InputStruct.onemsbyTstep), double(InputStruct.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
MaximizePlot()
% PlotSpikePropagation(InputStruct, GenerationTimeVect, SpikeSynIndVect);

%% Plotting SpikeList upto 150ms to show instability
InitTime = double(FinalStateSparse.Time)/1000;
BegTime = InitTime + 120;
EndTime = InitTime + 150;% + 25;

figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStruct, OutputVarsSpikeListCurrFSF.SpikeList);
plot(GenerationTimeVect/1000 - InitTime*double(InputStruct.onemsbyTstep), double(InputStruct.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
MaximizePlot()

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

