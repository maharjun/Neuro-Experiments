%% Code to design New Network where the Weights of Exc-Exc Synapses are randomly permuted
rng(45);
NewNetwork.NStart = InputStateSparse.NStart;
NewNetwork.NEnd   = InputStateSparse.NEnd;
NewNetwork.Delay  = InputStateSparse.Delay;

% Getting Exc-Exc Weights
RelevantWeightsIndex = InputStateSparse.NStart <= 800 & InputStateSparse.NEnd <= 800;
CurrentWeights  = FinalStateSparse.Weight;
RelevantWeights = CurrentWeights(RelevantWeightsIndex);

% Randomly jumbling weights
for i = 1:8
	RelevantWeights = RelevantWeights(randperm(length(RelevantWeights)));
end

% Assigning back jumbled weights
NewNetwork.Weight = InputStateSparse.InitialState.Weight;
NewNetwork.Weight(RelevantWeightsIndex) = RelevantWeights;

%% Calculating PNG's for 

addpath('..\PolychronousGroupFind\PolychronousGroupFind\x64\Release_Lib\');
% MinWeightSyn;
% RequiredConcurrency;
% DelayedSpikeProb;
% SpikeProbThreshold;
% MinLengthThreshold;
% MaxLengthThreshold;

NewInputStruct = InputStateSparse;
NewInputStruct.InitialState.Weight = NewNetwork.Weight;

NewInputStruct.MinWeightSyn = single(8);
NewInputStruct.DelayedSpikeProb = single(0.4);
NewInputStruct.SpikeProbThreshold = single(0.2);
NewInputStruct.MinLengthThreshold = int32(5);

PNGList2 = PolychronousGroupFind(NewInputStruct);
rmpath('..\PolychronousGroupFind\PolychronousGroupFind\x64\Release_Lib\');
