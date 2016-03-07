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
  
Index
------

    CAP - Code Already Provided

Experiments
-----------

### Experiment 1 ###

  #### Procedure ####

  This Experiment has the following steps:
  
  1. Compile the Exe's of WorkingMemory, PolychronousGroupFind.
    
  2. (if required) generate the 5Hours long simulation file 
     SimResults1000Sparse5Hours.mat
    
  3. Read the data (CAP)
    
  4. Setup the following simulation parameters and get FSF
     
        NoOfms                      = int32(900*1000)
        StorageStepSize             = int32(2000)
       
        ST_STDP_MaxRelativeInc      = single(2.5);
        ST_STDP_EffectMaxCausal     = single(0.12);
        ST_STDP_EffectMaxAntiCausal = single(0.12); 
       
        W0                          = single(0);
       
        Iext.IExtAmplitude          = single(30);
        Iext.AvgRandSpikeFreq       = single(0.3);
        Iext.MajorTimePeriod        = uint32(18000);
        Iext.MajorOnTime            = uint32(1100);
        Iext.MinorTimePeriod        = uint32(110);
        Iext.NoOfNeurons            = uint32(60);
    
  5. Plot Video of FSF weight histograms. (CAP)
    
  6. Using FSF of time (5*60*60 + 468) seconds, simulate
     and get SpikeList for the next 20s.
    
  7. Observe spike behaviour.

### Experiment 2 ###

  #### Procedure ####

  1. Follow Steps 1 to 3 in Experiment 1.
  2. In Point 4. edit the following parameter values
     
        ST_STDP_MaxRelativeInc      = single(2.5);
        ST_STDP_EffectDecay         = single(exp(-1/30));
        ST_STDP_EffectMaxCausal     = single(0.11);
        ST_STDP_EffectMaxAntiCausal = single(0.11);
        
        W0                          = single(0);
        
        Iext.IExtAmplitude          = single(30);
        Iext.AvgRandSpikeFreq       = single(0.3);
        Iext.MajorTimePeriod        = uint32(18000);
        Iext.MajorOnTime            = uint32(1210);
        Iext.MinorTimePeriod        = uint32(110);
        Iext.NoOfNeurons            = uint32(60);
    
  3. Plot Histogram video (CAP)
  4. Opbserve spike train.
  
### Experiment 3 ###

  #### Procedure #####
  
  1. Follow Steps 1 to 3 in Experiment 1
  2. In Point 4. edit the following parameter values
  
        InputStruct.ST_STDP_MaxRelativeInc      = single(2.5);
        InputStruct.ST_STDP_DecayWithTime       = single(exp(-1/5000));
        InputStruct.ST_STDP_EffectDecay         = single(exp(-1/20));
        InputStruct.ST_STDP_EffectMaxCausal     = single(0.09);
        InputStruct.ST_STDP_EffectMaxAntiCausal = single(0.09);
        
        InputStruct.W0                          = single(0);
        
        InputStruct.Iext.IExtAmplitude          = single(30);
        InputStruct.Iext.AvgRandSpikeFreq       = single(0.3);
        InputStruct.Iext.MajorTimePeriod        = uint32(72000);
        InputStruct.Iext.MajorOnTime            = uint32(17000);
        InputStruct.Iext.MinorTimePeriod        = uint32(500);
        InputStruct.Iext.NoOfNeurons            = uint32(45);

### Experiment 4 ###

  #### Procedure ####
  
  1. Compile the Exe's of WorkingMemory, PolychronousGroupFind.
  
  2. (if required) generate the 5Hours long simulation file 
     SimResults1000Sparse5HoursMax9.mat. Only this time, the 
     maximum weight should be set to 9 instead of 8.
     
  3. Set the following simulation parameters:
     
        InputStruct.ST_STDP_MaxRelativeInc      = single(2.5);
        InputStruct.ST_STDP_DecayWithTime       = single(exp(-1/5000));
        InputStruct.ST_STDP_EffectDecay         = single(exp(-1/20));
        InputStruct.ST_STDP_EffectMaxCausal     = single(0.11);
        InputStruct.ST_STDP_EffectMaxAntiCausal = single(0.11);
        
        InputStruct.W0                          = single(0);
        
        InputStruct.Iext.IExtAmplitude = single(30);
        InputStruct.Iext.AvgRandSpikeFreq = single(0.3);
        InputStruct.Iext.MajorTimePeriod = uint32(30000);
        InputStruct.Iext.MajorOnTime     = uint32(1100);
        InputStruct.Iext.MinorTimePeriod = uint32(100);
        InputStruct.Iext.NoOfNeurons     = uint32(45);

        InputStruct.InitialState.Weight(InputStruct.NEnd > 800) = 8;
     
  4. Simulate for 900 seconds and observe spikelist.
  
  #### Observations ####
  
  1. This appears to be quite stable. The reason being that it 
     has a higher default synaptic strength (9 instead of 8). 
     This allows me to use a shorter input length to get the  
     required synaptic strengths while using a smaller value of
     ST_STDP_EffectMaxCausal and ST_STDP_EffectMaxAntiCausal
     which gives stability during recollection of memory.
     
  #### Potential Issues ####
  
  1. This however, does not seem to get around the potential 
     problem where giving multiple patterns will push the net-
     work to insanity. This is because it relies on the same 
     dynamics as all the previous cases.
     
### Experiment 5 ###

  #### Procedure ####
  
  1. Checkout the branch WorkingMem/Standard-ST-STDP/Maximum-Curr-In
     (commit hash 4bf69c46e4bcbf0ce69a0e443229f2d12db1a92c) and 
     containing branch in WorkingMemory.
     
  2. Compile WorkingMemory (use SetupExperiment).
     
  3. (if required) generate the 5Hours long simulation file 
     SimResults1000Sparse5HoursMax9.mat. Only this time, the 
     maximum weight should be set to 9 instead of 8.
     
  4. Set the parameters as below:
     
     InputStruct.IinMax = single(20);

     InputStruct.ST_STDP_MaxRelativeInc      = single(2.5);
     InputStruct.ST_STDP_DecayWithTime       = single(exp(-1/5000));
     InputStruct.ST_STDP_EffectDecay         = single(exp(-1/20));
     InputStruct.ST_STDP_EffectMaxCausal     = single(0.12);
     InputStruct.ST_STDP_EffectMaxAntiCausal = single(0.12);
 
     InputStruct.W0                          = single(0);
 
     InputStruct.Iext.IExtAmplitude = single(30);
     InputStruct.Iext.AvgRandSpikeFreq = single(0.3);
     InputStruct.Iext.MajorTimePeriod = uint32(30000);
     InputStruct.Iext.MajorOnTime     = uint32(1100);
     InputStruct.Iext.MinorTimePeriod = uint32(100);
     InputStruct.Iext.NoOfNeurons     = uint32(45);
 
     InputStruct.InitialState.Weight(InputStruct.NEnd > 800) = 8;

  5. Try out the following combination of parameters
     
     * ST_STDP_EffectMaxCausal     = single(0.11);
       ST_STDP_EffectMaxAntiCausal = single(0.11);
     
     * ST_STDP_EffectMaxCausal     = single(0.12);
       ST_STDP_EffectMaxAntiCausal = single(0.12);
       
       InputStruct.IinMax = 15, 20, 40, 50
       
  #### Observations ####
  
  * The addition of the IinMax does not seem to resolve the issue
    of instability. The reason is that a current level of upto 20
    seems to allow for instant spiking. and given a good enough 
    number of synapses of high weight, the network still becomes
    berserk.
    
  * Also, in order for spontaneous spiking to arise, it is nece-
    ssary to allow high input currents to a FEW neurons in the 
    network. Thus, if we reduce IinMax, then no Memory retention
    occurs as can be observed in the case where 
    
        InputStruct.IinMax = 15
    
### Experiment 6 - STDP Effectiveness Testing ###

  #### Description ####
  
  This experiment is to ascertain the effectiveness of STDP to 
  generate Polychronous Neural Groups.
  
  #### Procedure ####
  
  1. Checkout the WorkingMem/Standard-ST-STDP/Basic-Algo branch
     of the WorkingMemory repository.
     
  2. Ensure that the submodule Polychronization and PolychronousGroupFind 
     are updated.
     
  3. Recompile Code (SetupExperiment.ps1).
     
  4. Use the code in WorkingMemoryExp.m to generate the sparse 
     Network after STDP
     
  5. Read the Data Generated
     
  6. Use the code in STDPEffectivenessExp.m to jumble the weights 
     and calculate PNG's
  
  #### Observations ####
  
  * There is a clear increase in the number of PNG's in the network 
    combination arrived at via STDP as opposed to a random combination.
  
  * One particular observation: (making the randomization for loop 1:8,
    finding all PNG's with length >= 5)
    
    PNG's with randomized combination     = 598
    PNG's with STDP resultant combination = 8738
  
  * The increase ranges from 7-15 fold.