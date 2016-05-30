#!/usr/bin/env python3.5

import sys
import os
from RepoManagement.BasicUtils import changedDir, getFrameDir
from RepoManagement import getRootDirectory
from RepoManagement import SubModuleProcessing as SMP
import subprocess
import shlex

# get Current Script Directory
CurrentScriptDir = getFrameDir()

# initialize submodules
SMP.UpdateSubModules(CurrentScriptDir)

# Retrieve Relevant Directories
ExperimentRootDir = getRootDirectory(CurrentScriptDir)
SubModulesDir = os.path.join(ExperimentRootDir, 'SubModulesDir')
GetAttractionBasinDir = os.path.join(SubModulesDir, 'GetAttractionBasin')

# Initialize Directories relevant to CMake
CMakeModulesDir = os.path.join(GetAttractionBasinDir, 'CMakeModules')
CurrentSourceDir = GetAttractionBasinDir
BuildDir = os.path.join(CurrentScriptDir, 'build')

# add CMakeModulesDir to sys path and get default platform
sys.path.insert(0, CMakeModulesDir)
from CMakePyHelper import getDefaultPlatformGen
DefaultGenerator = getDefaultPlatformGen()

# Initialize Path to the HPP file correspondingto the dynamic system.
DynSystemHPPPath = os.path.join(CurrentScriptDir, '../NeuronDynSys/IzhikevichSpiking.hpp')
if not os.path.isdir(BuildDir):
    os.mkdir(BuildDir)

with changedDir(BuildDir):
    CMakeCmd = (
        'cmake -G "{Generator}" '.format(Generator=DefaultGenerator) +
        '-D CMAKE_BUILD_TYPE=Release ' +
        '-D DYN_SYSTEM_HPP_PATH={DynSystemHPPPath} '.format(DynSystemHPPPath=DynSystemHPPPath) +
        '"{SourceDir}"'.format(SourceDir=CurrentSourceDir))

    with open(os.devnull, 'w') as NullStream:
        CMakeOutput = subprocess.call(shlex.split(CMakeCmd), stdout=NullStream)

    print(CMakeOutput)
    if not CMakeOutput:
        print("\nCMake build files successfully generated")
        isCMakeGenSuccess = True
    else:
        print("\nErrors occurred in the execution of the following command:")
        print()
        print("  {Command}".format(Command=CMakeCmd))
        isCMakeGenSuccess = False

if isCMakeGenSuccess:
    CMakeBuildCmd = 'cmake --build "{BuildDir}" --target install --config Release'.format(
        BuildDir=BuildDir)
    
    with open(os.devnull, 'w') as NullStream:
        CMakeBuildOutput = subprocess.call(shlex.split(CMakeBuildCmd), stdout=NullStream)
    
    if not CMakeBuildOutput:
        print("\nCMake build and install successfully completed")
        print("Installed in:")
        print("\n  {Directory}".format(Directory=os.path.join(BuildDir, 'install')))
    else:
        print("\nErrors occurred in the execution of the following command:")
        print()
        print("  {Command}".format(Command=CMakeBuildCmd))
        isCMakeGenSuccess = False
