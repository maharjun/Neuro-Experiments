#!/usr/bin/env python3.5

import sys
import os
from RepoManagement.BasicUtils import changedDir, getFrameDir
from RepoManagement import getRootDirectory
from RepoManagement import SubModuleProcessing as SMP

# get Current Script Directory
CurrentScriptDir = getFrameDir()

# initialize submodules
SMP.UpdateSubModules(CurrentScriptDir)

# Retrieve Relevant Directories
ExperimentRootDir = getRootDirectory(CurrentScriptDir)
SubModulesDir = os.path.join(ExperimentRootDir, 'SubModulesDir')
GetAttractionBasinDir = os.path.join(SubModulesDir, 'GetAttractionBasin')

# Initialize Directories relevant to CMake
CMakeModulesDir = os.path.join(SubModulesDir, 'CMakeModules')
CurrentSourceDir = GetAttractionBasinDir
BuildDir = os.path.join(CurrentScriptDir, 'build')

# add CMakeModulesDir to sys path and get default platform
sys.path.insert(0, CMakeModulesDir)
from CMakePyHelper import getDefaultPlatformGen
from CMakePyHelper import CMakeGenCall, CMakeBuildCall

DefaultGenerator = getDefaultPlatformGen()

# Initialize Path to the HPP file correspondingto the dynamic system.
DynSystemHPPPath = os.path.join(CurrentScriptDir, '../NeuronDynSys/IzhikevichSilent.hpp')
if not os.path.isdir(BuildDir):
    os.mkdir(BuildDir)

with changedDir(BuildDir):
    isCMakeGenSuccess = CMakeGenCall(CurrentSourceDir,
                                     Generator=DefaultGenerator,
                                     BuildConfig='Release',
                                     Silent=True,
                                     DYN_SYSTEM_HPP_PATH=DynSystemHPPPath)

if isCMakeGenSuccess:
    CMakeBuildSuccess = CMakeBuildCall(BuildDir,
                                       Target='install',
                                       BuildConfig='Release')
