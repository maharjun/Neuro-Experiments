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

%% Get Initial Simulation Upto 320 s (i.e. upto instability)

% Clearing InputStruct
clear InputStruct;

% Initializing InputStruct
InputStruct = InputStateSparse;
InputStruct.InitialState = FinalStateSparse;

% Simulation Parameters
InputStruct.NoOfms                = int32(320*1000);

% LT-STDP Related Parameters
InputStruct.W0 = single(0);

% ST-STDP Related Parameters
InputStruct.ST_STDP_MaxRelativeInc      = single(2);
InputStruct.ST_STDP_DecayWithTime       = single(exp(-1/5000));
InputStruct.ST_STDP_EffectDecay         = single(exp(-1/8));
InputStruct.ST_STDP_EffectMaxCausal     = single(0.32);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0.4);

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

%% Plotting SpikeList

InitTime = double(FinalStateSparse.Time)/1000;
BegTime = InitTime + 250;
EndTime = InitTime + 300;

FigUnstable = figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStateUnstable, OutputVarsUnstable.SpikeList);
plot(GenerationTimeVect/1000 - InitTime*double(InputStateUnstable.onemsbyTstep), double(InputStateUnstable.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
MaximizePlot()
title('Spikelist (Weights frozen at 104s)', 'fontsize', 18);
xlabel('time in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);

%% Simulating freezing weights at 286s

InputStruct = InputStateUnstable;
InputStruct.InitialState = getSingleState(StateVarsUnstable, (18000+286)*1000);

% ST-STDP Related Parameters
InputStruct.ST_STDP_DecayWithTime       = single(1);
InputStruct.ST_STDP_EffectMaxCausal     = single(0);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0);

InputStruct.NoOfms = int32(40*1000);
[OutputVarsFrozen286, StateVarsFrozen286, FinalStateFrozen286, InputStateFrozen286] = TimeDelNetSim(InputStruct);

%% Simulating freezing weights at 302s

InputStruct = InputStateUnstable;
InputStruct.InitialState = getSingleState(StateVarsUnstable, (18000+302)*1000);

% ST-STDP Related Parameters
InputStruct.ST_STDP_DecayWithTime       = single(1);
InputStruct.ST_STDP_EffectMaxCausal     = single(0);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0);

InputStruct.NoOfms = int32(40*1000);
[OutputVarsFrozen302, StateVarsFrozen302, FinalStateFrozen302, InputStateFrozen302] = TimeDelNetSim(InputStruct);

%% Plotting frozen weights Spike Sequence at 286s
InitTime = double(FinalStateSparse.Time)/1000;
BegTime = InitTime+300;
EndTime = InitTime+310;

FigFrozen286 = figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStateFrozen286, OutputVarsFrozen286.SpikeList);
plot(GenerationTimeVect/1000 - InitTime*double(InputStruct.onemsbyTstep), double(InputStateFrozen286.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
MaximizePlot()
title('Spikelist (Weights frozen at 286s)', 'fontsize', 18);
xlabel('time in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);

%% Plotting frozen weights Spike Sequence at 302s
InitTime = double(FinalStateSparse.Time)/1000;
BegTime = InitTime+315;
EndTime = InitTime+325;

FigFrozen302 = figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStateFrozen302, OutputVarsFrozen302.SpikeList);
plot(GenerationTimeVect/1000 - InitTime*double(InputStruct.onemsbyTstep), double(InputStateFrozen302.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
MaximizePlot()
title('Spikelist (Weights frozen at 302s)', 'fontsize', 18);
xlabel('time in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);

%% Get Correlation of recurrence for 286s Pattern
InitTime = double(FinalStateSparse.Time)/1000;

onemsbyTstep = double(InputStateFrozen286.onemsbyTstep);

ShortPatternBegTime = InitTime+300;
ShortPatternEndTime = InitTime+300.11;
ShortPatternSpikeMat = getSparseSpikeArr(InputStateFrozen286, OutputVarsFrozen286.SpikeList, ShortPatternBegTime, ShortPatternEndTime);
ShortPatternSpikeMat = ShortPatternSpikeMat(1:800, :);

LongPatternBegTime = InitTime+300;
LongPatternEndTime = InitTime+310;
LongPatternSpikeMat = getSparseSpikeArr(InputStateFrozen286, OutputVarsFrozen286.SpikeList, LongPatternBegTime, LongPatternEndTime);
LongPatternSpikeMat = LongPatternSpikeMat(1:800, :);

CorrelationArr = getSpikeCorr(ShortPatternSpikeMat, LongPatternSpikeMat, 2);
FigFrozen108Corr = figure;
plot((0:length(CorrelationArr)-1)/(1000*onemsbyTstep), CorrelationArr);
MaximizePlot();
title('Corr [300,300.11) vs [300,310) (286s Weight Freeze)', 'fontsize', 18);
xlim([0, LongPatternEndTime-LongPatternBegTime]);
xlabel('offset in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);

%% Get Correlation of recurrence for 302s Pattern
InitTime = double(FinalStateSparse.Time)/1000;

onemsbyTstep = double(InputStateFrozen302.onemsbyTstep);

ShortPatternBegTime = InitTime+315;
ShortPatternEndTime = InitTime+315.11;
ShortPatternSpikeMat = getSparseSpikeArr(InputStateFrozen302, OutputVarsFrozen302.SpikeList, ShortPatternBegTime, ShortPatternEndTime);
ShortPatternSpikeMat = ShortPatternSpikeMat(1:800, :);

LongPatternBegTime = InitTime+315;
LongPatternEndTime = InitTime+325;
LongPatternSpikeMat = getSparseSpikeArr(InputStateFrozen302, OutputVarsFrozen302.SpikeList, LongPatternBegTime, LongPatternEndTime);
LongPatternSpikeMat = LongPatternSpikeMat(1:800, :);

CorrelationArr = getSpikeCorr(ShortPatternSpikeMat, LongPatternSpikeMat, 2);
figure;
plot((0:length(CorrelationArr)-1)/(1000*onemsbyTstep), CorrelationArr);
MaximizePlot();
title('Corr [315,315.11) vs [315,325) (302s Weight Freeze)', 'fontsize', 18);
xlim([0, LongPatternEndTime-LongPatternBegTime]);
xlabel('offset in s', 'fontsize', 15);
ylabel('Neuron Index', 'fontsize', 15);
