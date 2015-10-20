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