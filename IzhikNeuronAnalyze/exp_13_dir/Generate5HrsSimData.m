WorkingMemModulePath = deblank(fileread('./TimeDelNetSim_build/install/ModulePath.txt'));
addpath(fullfile(WorkingMemModulePath, 'TimeDelNetSim', 'MatlabSource'))

%% Setup Network Parameters
rng('default');
rng(25);
N = 1000;
E = 0.8;
WorkingMemNetParams.NExc = round(N*E);
WorkingMemNetParams.NInh = round(N - N*E);

WorkingMemNetParams.F_E  = 100;
WorkingMemNetParams.F_IE = 100;

WorkingMemNetParams.InitInhWeight = -5;
WorkingMemNetParams.InitExcWeight = 6;

WorkingMemNetParams.DelayRange   = 20;

[A, Ninh, Weights, Delays] = WorkingMemNet(WorkingMemNetParams);

a = 0.02*ones(N,1);
b = 0.2*ones(N,1);
c = -65*ones(N,1);
d = 8*ones(N,1);

a(Ninh) = 0.1;
b(Ninh) = 0.2;
c(Ninh) = -65;
d(Ninh) = 2;
[NEndVect, NStartVect] = find(A);

%% Running Simulation to generate sparse representation of 5 Hrs Simulation

OutputOptions = {'FSF', 'Initial'};
% Clearing InputStruct
clear InputStruct;

% Neuron Parameters
InputStruct.a = single(a);
InputStruct.b = single(b);
InputStruct.c = single(c);
InputStruct.d = single(d);

% Network Parameters
InputStruct.NStart              = int32(NStartVect);
InputStruct.NEnd                = int32(NEndVect);
InputStruct.InitialState.Weight = single(Weights);
InputStruct.Delay               = single(Delays);
InputStruct.DelayRange          = int32(WorkingMemNetParams.DelayRange);

% Simulation Parameters
InputStruct.onemsbyTstep = int32(1);
InputStruct.NoOfms       = int32(5*60*60*1000);

% Interfacing Parameters
InputStruct.StorageStepSize       = int32(60*1000);
InputStruct.OutputControl         = strjoin(OutputOptions);
InputStruct.StatusDisplayInterval = int32(4000);

% External Current Parameters
InputStruct.Iext.IExtAmplitude             = single(0);
InputStruct.Iext.IRandAmplitude            = single(30);
InputStruct.Iext.AvgRandSpikeFreq          = single(1);
InputStruct.InitialState.Iext.IExtGenState = uint32(30);

% LT-STDP Related Parameters
InputStruct.MaxSynWeight                   = single(8);

% ST-STDP Related Parameters
InputStruct.ST_STDP_EffectMaxCausal        = single(0.0);
InputStruct.ST_STDP_EffectMaxAntiCausal    = single(0.0);

if ~exist('TimeDelNetSim_build/Data', 'dir')
    mkdir('TimeDelNetSim_build/Data')
end

save('TimeDelNetSim_build/Data/5HrsSparseInputData.mat', 'InputStruct');
!TimeDelNetSim_build/install/TimeDelNetSim TimeDelNetSim_build/Data/5HrsSparseInputData.mat TimeDelNetSim_build/Data/5HrsSparseOutputData.mat 