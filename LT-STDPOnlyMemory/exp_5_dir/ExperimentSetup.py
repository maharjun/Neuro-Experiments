#!/usr/bin/env python3.5

import sys
from RepoManagement.BasicUtils import changedDir, getFrameDir
from RepoManagement import getRootDirectory
from RepoManagement import SubModuleProcessing as SMP
from git import Repo

# get Current Script Directory
CurrentScriptDir = getFrameDir()

# initialize submodules
SMP.UpdateSubModules(CurrentScriptDir)

# Retrieve Relevant Directories
WorkingMemDir = Repo(getRootDirectory(CurrentScriptDir)).submodule('WorkingMemory').abspath
ExportFigDir  = Repo(getRootDirectory(CurrentScriptDir)).submodule('ExportFig').abspath
PolychronousGroupFindDir = Repo(getRootDirectory(CurrentScriptDir)).submodule('PolychronousGroupFind').abspath

# Include GetAttractionBasinDir and ExportFigDir in Paths
sys.path.insert(0, WorkingMemDir)
sys.path.insert(0, ExportFigDir)
sys.path.insert(0, PolychronousGroupFindDir)

# import SetupTimeDelNetSim and call SetupTimeDelNetSim
from SetupTimeDelNetSim import SetupTimeDelNetSim
from SetupExportFig import SetupExportFig
from SetupPolychronousGroupFind import SetupPolychronousGroupFind


with changedDir(CurrentScriptDir):
    SetupTimeDelNetSim()
    SetupExportFig()
    SetupPolychronousGroupFind()
    
# Setup ExportFig
