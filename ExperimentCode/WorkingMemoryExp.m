rmpath('..\..\x64\Debug_Lib');
addpath('..\Polychronization\TimeDelNetSim\x64\Release_Lib\');
addpath('..\Polychronization\TimeDelNetSim\MatlabSource\');
addpath('..\MexMemoryInterfacing\MatlabSource\');
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
InputStruct.InitialState.Iext.IExtScaleFactor = single(20);
InputStruct.MaxSynWeight                   = single(10);

InputStruct.OutputFile = 'SimResults1000Sparse5HoursMax10.mat';

if ~exist('../Polychronization/TimeDelNetSim/Data', 'dir')
	mkdir('../Polychronization/TimeDelNetSim/Data')
end
save('../Polychronization/TimeDelNetSim/Data/InputData.mat', 'InputStruct');

% [OutputVarsSparse, StateVarsSparse, FinalStateSparse, InputStateSparse] = TimeDelNetSim_Polychron(InputStruct);
% Run the program after this
! start "TimeDelNetSim Sparse Simulation" /d . "powershell" ". .\Release_Exe.ps1"
%% Loading 5 Hours Long Long Term STDP Simulation Result
load('../Polychronization/TimeDelNetSim/Data/SimResults1000Sparse5HoursMax10.mat');
clear OutputVarsSparse StateVarsSparse InputStateSparse FinalStateSparse;
OutputVarsSparse = OutputVars;
StateVarsSparse = StateVars;
InputStateSparse = InputState;
FinalStateSparse = FinalState;
clear OutputVars StateVars InputState FinalState;

%% Getting SpikeList of a particular portion
InputStruct = InputStateSparse;
InputStruct.InitialState = getSingleState(StateVarsSparse, 298*60*1000);

OutputOptions = {'SpikeList', 'Initial', 'Final'};

InputStruct.NoOfms = int32(2*60*1000);
InputStruct.OutputControl = strjoin(OutputOptions);

[OutputVarsSpikeList, StateVarsSpikeList, FinalStateSpikeList, InputStateSpikeList] = TimeDelNetSim_Polychron(InputStruct);

%% Plotting SpikeList
BegTime = 298*60 + 0;
EndTime = 298*60 + 5;

figure;
[GenerationTimeVect, SpikeSynIndVect] = ParseSpikeList(BegTime, EndTime, InputStruct, OutputVarsSpikeList.SpikeList);
plot(GenerationTimeVect - BegTime*1000*double(InputStruct.onemsbyTstep), double(InputStruct.NStart(SpikeSynIndVect)), '.', 'MarkerSize', 1);
% PlotSpikePropagation(InputStruct, GenerationTimeVect, SpikeSynIndVect);

%% Calculating Polychronous groups
addpath('..\PolychronousGroupFind\PolychronousGroupFind\x64\Release_Lib\');
% MinWeightSyn;
% RequiredConcurrency;
% DelayedSpikeProb;
% SpikeProbThreshold;
% MinLengthThreshold;
% MaxLengthThreshold;

InputStruct = InputStateSparse;
InputStruct.InitialState = FinalStateSparse;
InputStruct.MinWeightSyn = single(8);
InputStruct.DelayedSpikeProb = single(0.4);
InputStruct.SpikeProbThreshold = single(0.2);
InputStruct.MinLengthThreshold = int32(5);

PNGList = PolychronousGroupFind(InputStruct);
rmpath('..\PolychronousGroupFind\PolychronousGroupFind\x64\Release_Lib\');

%% Displaying PNG
addpath('..\PolychronousGroupFind\PolychronousGroupFind\MatlabSource\');

PNGList = PNGList2FlatCellArray(PNGList);
CurrentPNG = GetPNG(PNGList, 42);
CurrentPNGWOInhib = GetPNGWOInhib(CurrentPNG, 800);
CurrPNGRelative = ConvertPNGtoRelative(CurrentPNGWOInhib, InputStruct.NStart, InputStruct.Delay);
DisplayPNG(CurrPNGRelative);
rmpath('..\PolychronousGroupFind\PolychronousGroupFind\MatlabSource\');