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
GetAttractionBasinDir = Repo(getRootDirectory(CurrentScriptDir)).submodule('GetAttractionBasin').abspath

# Include GetAttractionBasinDir in Paths
sys.path.insert(0, GetAttractionBasinDir)

# import SetupDynSys and call SetupDynSys
from SetupDynSystem import SetupDynSystem

with changedDir(CurrentScriptDir):
    SetupDynSystem('../NeuronDynSys/IzhikevichSpiking.hpp')
