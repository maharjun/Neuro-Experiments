addpath ./TimeDelNetSim_build/install
addpath(fullfile(ExpRepoTopDir, 'SubModulesDir', 'WorkingMemory', 'MexMemoryInterfacing', 'MatlabSource'))

%% Read 5Hours Simulation Data
load TimeDelNetSim_build/Data/5HrsSparseOutputData.mat
clear OutputVars5Hrs StateVars5Hrs InputState5Hrs FinalState5Hrs;
OutputVars5Hrs = OutputVars;
StateVars5Hrs = StateVars;
InputState5Hrs = InputState;
FinalState5Hrs = FinalState;
clear OutputVars StateVars InputState FinalState;

%% Simulate in the prescence of 0.3 Hz Noise

InputStruct = InputState5Hrs;
InputStruct.InitialState = FinalState5Hrs;
OutputOptions = {'U','V'};

CurrentQIndex = InputStruct.InitialState.CurrentQIndex;
CurrSpikeQSize = double(InputStruct.DelayRange*InputStruct.onemsbyTstep);

Factor = 1;

CurrentSpikeQueue = FlatCellArray([], InputStruct.InitialState.SpikeQueue);

NewSpikeQueue = cell(CurrSpikeQSize*Factor, 1);
for i = 1:CurrSpikeQSize
    NewSpikeQueue{(i-1)*Factor+1} = CurrentSpikeQueue{i};
    for j = (i-1)*Factor+2:i*Factor
        NewSpikeQueue{j} = zeros(0,1,'int32');
    end
end
NewQIndex = Factor*CurrentQIndex;
NewSpikeQueue = FlatCellArray.FlattenCellArray(NewSpikeQueue, 'int32');

InputStruct.onemsbyTstep = int32(Factor);
InputStruct.InitialState.SpikeQueue = NewSpikeQueue.Convert2Struct();
InputStruct.InitialState.CurrentQIndex = int32(NewQIndex);
InputStruct.StatusDisplayInterval = int32(InputStruct.StatusDisplayInterval*Factor);
InputStruct.Iext.IRandAmplitude = InputStruct.Iext.IRandAmplitude*Factor;
InputStruct.OutputControl = strjoin(OutputOptions);

InputStruct.StorageStepSize = int32(0);
InputStruct.NoOfms = int32(10000);
InputStruct.Iext.AvgRandSpikeFreq          = single(0.3);

save TimeDelNetSim_build/Data/UVSpreadInputData.mat InputStruct;

[OutputVarsUV, StateVarsUV, FinalStateUV] = TimeDelNetSim(InputStruct);

%% Plotting UV Spread
hist3([StateVarsUV.U(:) StateVarsUV.V(:)], [100, 100])
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
