WorkingMemModulePath = deblank(fileread('./TimeDelNetSim_build/install/ModulePath.txt'));
addpath(fullfile(WorkingMemModulePath, 'TimeDelNetSim', 'MatlabSource'))

%%
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
% Delays = Delays + 10;
[NEndVect, NStartVect] = find(A);

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
InputStruct.DelayRange                     = int32(WorkingMemNetParams.DelayRange);
InputStruct.StorageStepSize                = int32(60*1000);
InputStruct.OutputControl                  = strjoin(OutputOptions);
InputStruct.StatusDisplayInterval          = int32(4000);
InputStruct.InitialState.Iext.IExtGenState = uint32(30);

InputStruct.MaxSynWeight                   = single(8);
InputStruct.ST_STDP_EffectMaxCausal        = single(0.0);
InputStruct.ST_STDP_EffectMaxAntiCausal    = single(0.0);
InputStruct.Iext.IExtAmplitude             = single(0);
InputStruct.Iext.AvgRandSpikeFreq          = single(1);

if ~exist('TimeDelNetSim_build/Data', 'dir')
    mkdir('TimeDelNetSim_build/Data')
end

save('TimeDelNetSim_build/Data/5HrsSparseInputData.mat', 'InputStruct');
!TimeDelNetSim_build/install/TimeDelNetSim TimeDelNetSim_build/Data/5HrsSparseInputData.mat TimeDelNetSim_build/Data/5HrsSparseOutputData.mat 