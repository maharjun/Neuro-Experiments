Working Memory Experiments
==========================

Introduction
------------

  * This is the introductory commit that contains the code necessary to 
    generate the network via Long term STDP and then to test short term STDP.
    
  * The simulation in this code has been updated so that the consistent weight
    increase and the weird WeightDeriv update rule have been removed.
    
  * An output variable NoOfms has been added in order to return a basic stat-
    istic about the simulation.
    
  * The following functions have been added:
       
       getEffectiveWeights (only to WorkingMemory)
       getIncomingSyns     (to TimeDelNetSim)
       getOutgoingSyns     (to TimeDelNetSim)
    
  * No experiments are currently detailed and this is just code.

Usage
----------

  For now, the usage is to simply load and run SetupExperiment.ps1 with 
  -subupdate option. in the case of custom initializations, the submodule 
  update must be done manually.
  
  The function must be run from the directory ExperimentCode.
