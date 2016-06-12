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

# Include GetAttractionBasinDir in Paths
sys.path.insert(0, WorkingMemDir)

# import SetupDynSys and call SetupDynSys
from SetupTimeDelNetSim import SetupTimeDelNetSim

with changedDir(CurrentScriptDir):
    SetupTimeDelNetSim()
