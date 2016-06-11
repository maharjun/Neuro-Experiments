% Initialize the path variables appropriately
% Now, initialize all the relevant paths for the exes

Neuro_Top_Level_Dir = InitTopLevelDir();

FullPath = @(a) strrep(fullfile(Neuro_Top_Level_Dir, a), '\', '/');

addpath(FullPath('SubModulesDir/WorkingMemory/TimeDelNetSim/x64/Release_Lib'));
addpath(FullPath('SubModulesDir/WorkingMemory/TimeDelNetSim/MatlabSource/'));
addpath(FullPath('SubModulesDir/WorkingMemory/TimeDelNetSim/Headers/IExtHeaders/MatlabSource/'));
addpath(FullPath('SubModulesDir/MexMemoryInterfacing/MatlabSource/'));
