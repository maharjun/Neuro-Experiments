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

%% Get Initial Simulation Upto 140 s (i.e. upto instability)

% Clearing InputStruct
clear InputStruct;

% Initializing InputStruct
InputStruct = InputStateSparse;
InputStruct.InitialState = FinalStateSparse;

% Simulation Parameters
InputStruct.NoOfms                = int32(140*1000);

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

[OutputVarsUnstable, StateVarsUnstable, FinalStateUnstable, InputStateUnstable] = TimeDelNetSim(InputStruct);

%% Simulating freezing weights at 108s

InputStruct = InputStateUnstable;
InputStruct.InitialState = getSingleState(StateVarsUnstable, (18000+108)*1000);

% ST-STDP Related Parameters
InputStruct.ST_STDP_DecayWithTime       = single(1);
InputStruct.ST_STDP_EffectMaxCausal     = single(0);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0);

InputStruct.NoOfms = int32(40*1000);
[OutputVarsFrozen108, StateVarsFrozen108, FinalStateFrozen108, InputStateFrozen108] = TimeDelNetSim(InputStruct);

%% Simulating freezing weights at 128s

InputStruct = InputStateUnstable;
InputStruct.InitialState = getSingleState(StateVarsUnstable, (18000+128)*1000);

% ST-STDP Related Parameters
InputStruct.ST_STDP_DecayWithTime       = single(1);
InputStruct.ST_STDP_EffectMaxCausal     = single(0);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0);

InputStruct.NoOfms = int32(40*1000);
[OutputVarsFrozen128, StateVarsFrozen128, FinalStateFrozen128, InputStateFrozen128] = TimeDelNetSim(InputStruct);

%% Plotting frozen weights Spike Sequence at 108s
InitTime = double(FinalStateSparse.Time)/1000;

FigFrozen108 = figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(InputStateFrozen108, OutputVarsFrozen108.SpikeList);
plot(GenerationTimeVect/1000 - InitTime*double(InputStruct.onemsbyTstep), double(InputStateFrozen108.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
MaximizePlot()
title('Spikelist (Weights frozen at 104s)', 'fontsize', 18);
xlabel('time in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);

%% Plotting frozen weights Spike Sequence at 128s
InitTime = double(FinalStateSparse.Time)/1000;

FigFrozen128 = figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(InputStateFrozen128, OutputVarsFrozen128.SpikeList);
plot(GenerationTimeVect/1000 - InitTime*double(InputStruct.onemsbyTstep), double(InputStateFrozen128.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
MaximizePlot()
title('Spikelist (Weights frozen at 128s)', 'fontsize', 18);
xlabel('time in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);

%% Get Correlation of recurrence for 108s Pattern
InitTime = double(FinalStateSparse.Time)/1000;

onemsbyTstepTstep = double(InputStateFrozen108.onemsbyTstep);

ShortPatternBegTime = InitTime+120;
ShortPatternEndTime = InitTime+120.11;
ShortPatternSpikeMat = getSparseSpikeArr(InputStateFrozen108, OutputVarsFrozen108.SpikeList, ShortPatternBegTime, ShortPatternEndTime);

LongPatternSpikeMat = getSparseSpikeArr(InputStateFrozen108, OutputVarsFrozen108.SpikeList);

CorrelationArr = getSpikeCorr(ShortPatternSpikeMat, LongPatternSpikeMat, 2);
FigFrozen108Corr = figure;
plot((0:length(CorrelationArr)-1)/(1000*onemsbyTstep), CorrelationArr);
MaximizePlot();
title('Corr [120,120.11) vs [104,144) (104s Weight Freeze)', 'fontsize', 18);
xlabel('offset in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);

%% Get Correlation of recurrence for 128s Pattern
InitTime = double(FinalStateSparse.Time)/1000;

onemsbyTstepTstep = double(InputStateFrozen128.onemsbyTstep);

ShortPatternBegTime = InitTime+135;
ShortPatternEndTime = InitTime+135.11;
ShortPatternSpikeMat = getSparseSpikeArr(InputStateFrozen128, OutputVarsFrozen128.SpikeList, ShortPatternBegTime, ShortPatternEndTime);

LongPatternSpikeMat = getSparseSpikeArr(InputStateFrozen128, OutputVarsFrozen128.SpikeList);

CorrelationArr = getSpikeCorr(ShortPatternSpikeMat, LongPatternSpikeMat, 2);
figure;
plot((0:length(CorrelationArr)-1)/(1000*onemsbyTstep), CorrelationArr);
MaximizePlot();
title('Corr [135,135.11) vs [128,168) (104s Weight Freeze)', 'fontsize', 18);
xlabel('offset in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);
