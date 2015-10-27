%% Get Weights of Incoming Synapses
IncomingSyns = getIncomingSyns(InputStruct);
IncomingWeights = cellfun(@(x) InputStruct.InitialState.Weight(x), IncomingSyns, 'UniformOutput', false);

%% Calculating Effective Weights
%  This is just code that calculates te Effective weights and partitions by
%  NEnd. The State for which we wish to calculate the weights can be
%  changed.

EffWeights = getEffectiveWeights(StateVarsSpikeList.Weight(:,StateVarsSpikeList.Time == 18510*1000), StateVarsSpikeList.ST_STDP_RelativeInc(:,StateVarsSpikeList.Time == 18510*1000));
figure; hist(EffWeights(EffWeights > 0), 0:24);
IncomingEffWeights = cellfun(@(x) EffWeights(x), IncomingSyns, 'UniformOutput', false);

%% Getting Detailed using Intermediate Sparse State Returned
% This is used in case one wishes to analyse in detail.

OutputOptions = { ...
    'Itot', ...
	'V', ...
 	'U', ...
	};
% Clearing InputStruct
clear InputStruct;

% Getting Midway state
InputStruct = InputStateSparse;
InputStruct.InitialState = getSingleState(StateVarsSparse, (12)*1000);
InputStruct.NoOfms                = int32(8000);
InputStruct.StorageStepSize       = int32(0);
InputStruct.OutputControl         = strjoin(OutputOptions);
InputStruct.StatusDisplayInterval = int32(2000);

% InputStruct.OutputFile = 'SimResults1000DebugDetailedfromInter.mat';
% save('../Data/InputData.mat', 'InputStruct');

[OutputVarsDetailed, StateVarsDetailed, FinalStateDetailed, InputStateDetailed] = TimeDelNetSim(InputStruct);
%% Compiling binarysearch
cd ..\PolychronousGroupFind\PolychronousGroupFind\MatlabSource
mex binarySearch.c
cd ..\..\..\ExperimentCode\
%% Code to display PNG's
addpath ..\PolychronousGroupFind\PolychronousGroupFind\MatlabSource

SinglePNG = GetPNG(PNGList2FlatCellArray(PNGList), 10);
SinglePNGWOInhib = GetPNGWOInhib(SinglePNG, 800);

SinglePNGRelative = ConvertPNGtoRelative(SinglePNG, InputStruct.NStart, InputStruct.Delay);
DisplayPNG(SinglePNGRelative);

rmpath ..\PolychronousGroupFind\PolychronousGroupFind\MatlabSource

%% Code to get and process Incoming Synapses

% The code below is to calculate the total incoming excitatory weights
IncSyns = getIncomingSyns(InputStruct);
IncExcSyns = cellfun(@(x) x(x<=80000), IncSyns, 'UniformOutput', false);
IncExcExcSyns = IncExcSyns(1:800);

RelevantState = getSingleState(StateVarsSpikeListCurrFSF, (5*60*60 + 30)*1000);

EffWeights = getEffectiveWeights(RelevantState.Weight, RelevantState.ST_STDP_RelativeInc);
IncExcEffWeights = cellfun(@(x) EffWeights(x), IncExcExcSyns, 'UniformOutput', false);
TotalIncExcEffWeights = cellfun(@sum, IncExcEffWeights);

%% Code to analyze network activity

% Ensure that Working Mem is checked out to WorkingMem/Network-Activity-Check
% and compiled.

InputStruct = InputStateSparse;
InputStruct.InitialState = FinalStateSparse; % getSingleState(StateVarsSpikeListCurrFSF, (5*60*60 + 2)*1000);

% Disable all forms of STDP, resetting WeightDeriv
% to ensure constancy of weight
InputStruct.ST_STDP_EffectMaxCausal     = single(0);
InputStruct.ST_STDP_EffectMaxAntiCausal = single(0);
InputStruct.W0                          = single(0);
InputStruct.Iext.IExtAmplitude          = single(0);
InputStruct.Iext.AvgRandSpikeFreq       = single(0.3);
InputStruct.Iext.IRandAmplitude         = single(20);
if isfield(InputStruct.InitialState, 'WeightDeriv')
	InputStruct.InitialState.WeightDeriv(:) = 0;
end

InputStruct.NoOfms = int32(200000);

% Get Full State every 1 secs
OutputOptions               = {'FSF','PropSpikeList', 'GenSpikeList', 'Final', 'Initial'};
InputStruct.StorageStepSize = int32(1000);
InputStruct.OutputControl   = strjoin(OutputOptions);
% save('..\WorkingMemory\TimeDelNetSim\Data\InputData.mat', 'InputStruct');

[OutputVarsSpikeListActivity, StateVarsSpikeListActivity, FinalStateSpikeListActivity, InputStateSpikeListActivity] = TimeDelNetSim_WorkingMemory(InputStruct);
%% Getting Detailed State
InputStruct = InputStateSpikeListActivity;
InputStruct.InitialState = getSingleState(StateVarsSpikeListActivity, (5*60*60 + 223)*1000);

% Get Detailed Simulation for 1 ms
OutputOptions               = {'V-Iin-Itot','PropSpikeList', 'GenSpikeList', 'Final', 'Initial'};
InputStruct.NoOfms          = int32(1000);
InputStruct.StorageStepSize = int32(0);
InputStruct.OutputControl   = strjoin(OutputOptions);
% save('..\WorkingMemory\TimeDelNetSim\Data\InputData.mat', 'InputStruct');

[OutputVarsSpikeListActvDetailed, StateVarsSpikeListActvDetailed, FinalStateSpikeListActvDetailed, InputStateSpikeListActvDetailed] = TimeDelNetSim_WorkingMemory(InputStruct);

%% Plotting Prop SpikeList
BegTime = double(FinalStateSparse.Time)/1000 + 100;
EndTime = double(FinalStateSparse.Time)/1000 + 100 + 10;

figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStruct, OutputVarsSpikeListActivity.PropSpikeList);
plot(GenerationTimeVect - BegTime*1000*double(InputStruct.onemsbyTstep), double(InputStruct.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1, 'MarkerEdgeColor', 'r');
% PlotSpikePropagation(InputStruct, GenerationTimeVect, SpikeSynIndVect);

%% Plotting Gen SpikeList
BegTime = double(FinalStateSparse.Time)/1000 + 2;
EndTime = double(FinalStateSparse.Time)/1000 + 2 + 200;

TimeGen         = OutputVarsSpikeListActivity.GenSpikeList.TimeGen;
SpikeNeuronInds = FlatCellArray([], OutputVarsSpikeListActivity.GenSpikeList.SpikeNeuronInds);
SpikeNeuronInds = SpikeNeuronInds.Convert2CellArray();

BegTimeIndex = find(OutputVarsSpikeListActivity.GenSpikeList.TimeGen >= BegTime*1000, 1,'first');
EndTimeIndex = find(OutputVarsSpikeListActivity.GenSpikeList.TimeGen  < EndTime*1000, 1,'last');

A = arrayfun(@(i) double(TimeGen(i))*ones(length(SpikeNeuronInds{i}),1), (BegTimeIndex:EndTimeIndex)', 'UniformOutput', false);
PlotTimeVect = cell2mat(A);
PlotNeuronVect = cell2mat(SpikeNeuronInds(BegTimeIndex:EndTimeIndex));

figure;
plot(PlotTimeVect - BegTime*1000*double(InputStruct.onemsbyTstep), double(PlotNeuronVect), '.', 'MarkerSize', 1);
% PlotSpikePropagation(InputStruct, GenerationTimeVect, SpikeSynIndVect);

clear A TimeGen SpikeNeuronInds
%% Calculating Probability of Spiking for the Neurons

NoOfSpikeInstants = accumarray(PlotNeuronVect, ones(length(PlotNeuronVect), 1), [N 1]);
figure; plot(1:1000, NoOfSpikeInstants/(EndTimeIndex - BegTimeIndex + 1)*1000);
fprintf('Total Probability of Spiking = %f\n', sum(NoOfSpikeInstants/(EndTimeIndex - BegTimeIndex + 1)));
%% Getting The inputs to each neuron at each time.

SpikeList = OutputVarsSpikeListActivity.SpikeList;
TimeRchd = SpikeList.TimeRchd;

NeuronofInterest = 730;
InputWeights = cell(length(TimeRchd),1);
Weights = getEffectiveWeights(FinalStateSpikeListActivity, InputStruct);

for i = 1:length(TimeRchd)
	CurrTimeRchd = TimeRchd(i);
	
	CurrInputSpikes = SpikeList.SpikeSynInds(SpikeList.TimeRchdStartInds(i)+1:SpikeList.TimeRchdStartInds(i+1));
	CurrInputSpikesNEnd = InputStateSpikeListActivity.NEnd(CurrInputSpikes+1);
	CurrInputSpikesWeight = Weights(CurrInputSpikes+1);
	
	% Spilt Spikes by NEnd
	InputWeights{i} = CurrInputSpikesWeight(CurrInputSpikesNEnd == NeuronofInterest);
	
	if mod(i, 10000) == 0
		fprintf('Completed %d seconds\n', i);
	end
end