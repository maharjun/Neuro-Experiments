%% Getting Detailed SubSimulation

OutputOptions = {'Iin'};
InputStruct = InputStateSpikeListCurrFSF;
InputStruct.InitialState = getSingleState(StateVarsSpikeListCurrFSF, 1000*18663);
InputStruct.NoOfms          = int32(1000);
InputStruct.StorageStepSize = int32(0);
InputStruct.StatusDisplayInterval = int32(3000);
InputStruct.OutputControl = strjoin(OutputOptions);
[OutputVarsDetailed, StateVarsDetailed, FinalStateDetailed, InputStateDetailed] = TimeDelNetSim_WorkingMemory(InputStruct);