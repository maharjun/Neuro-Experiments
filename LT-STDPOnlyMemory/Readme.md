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

### Experiment 1 - Basic Working Mem Experiment (Unstable) ###

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
        Iext.IExtPattern            = getEmptyIExtPattern();
        Iext.IExtPattern            = AddInterval(Iext.IExtPattern, 0, 0,0,18000,0);
        Iext.IExtPattern            =     AddInterval(Iext.IExtPattern, 1, 0,1100,110,0);
        Iext.IExtPattern            =         AddInterval(Iext.IExtPattern, 2, 0,0,0,1);
        
        Iext.IExtPattern.NeuronPatterns = {uint32([1,60])};
   
 5. Plot Video of FSF weight histograms. (CAP)
   
 6. Using FSF of time (5*60*60 + 468) seconds, simulate
    and get SpikeList for the next 20s.
   
 7. Observe spike behaviour.

### Experiment 2 - Playing with ST_STDP_EffectDecay ###

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
        Iext.IExtPattern            = getEmptyIExtPattern();
        Iext.IExtPattern            = AddInterval(Iext.IExtPattern, 0, 0,0,18000,0);
        Iext.IExtPattern            =     AddInterval(Iext.IExtPattern, 1, 0,1210,110,0);
        Iext.IExtPattern            =         AddInterval(Iext.IExtPattern, 2, 0,0,0,1);
        
        Iext.IExtPattern.NeuronPatterns = {uint32([1,60])};
    
 3. Plot Histogram video (CAP)
 4. Opbserve spike train.
  
### Experiment 3 - Extended Input Time and Low ST-STDP amplitude (Stable) ###

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
        InputStruct.Iext.IExtPattern            = getEmptyIExtPattern();
        InputStruct.Iext.IExtPattern            = AddInterval(InputStruct.Iext.IExtPattern, 0, 0,0,72000,0);
        InputStruct.Iext.IExtPattern            =     AddInterval(InputStruct.Iext.IExtPattern, 1, 0,17000,500,0);
        InputStruct.Iext.IExtPattern            =         AddInterval(InputStruct.Iext.IExtPattern, 2, 0,0,0,1);
        
        InputStruct.Iext.IExtPattern.NeuronPatterns = {uint32([1,45])};

### Experiment 4 - Maximum Synaptic Weight = 9 (Stable--) ###
  
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
        InputStruct.Iext.IExtPattern            = getEmptyIExtPattern();
        InputStruct.Iext.IExtPattern            = AddInterval(InputStruct.Iext.IExtPattern, 0, 0,0,30000,0);
        InputStruct.Iext.IExtPattern            =     AddInterval(InputStruct.Iext.IExtPattern, 1, 0,1100,100,0);
        InputStruct.Iext.IExtPattern            =         AddInterval(InputStruct.Iext.IExtPattern, 2, 0,0,0,1);
        
        InputStruct.Iext.IExtPattern.NeuronPatterns = {uint32([1,45])};

        InputStruct.InitialState.Weight(InputStruct.NEnd > 800) = 8;
     
 4. Simulate for 900 seconds and observe spikelist.
  
#### Observations ####
  
 1. This appears to be quite stable. The reason being that it 
    has a higher default synaptic strength (9 instead of 8). 
    This allows me to use a shorter input length to get the  
    required synaptic strengths while using a smaller value of
    `ST_STDP_EffectMaxCausal` and `ST_STDP_EffectMaxAntiCausal`
    which gives stability during recollection of memory.
      
#### Potential Issues ####
   
 1. This however, does not seem to get around the potential 
    problem where giving multiple patterns will push the net-
    work to insanity. This is because it relies on the same 
    dynamics as all the previous cases.
     
### Experiment 5 - Maximun Input Current Clipping (Stable--) ###

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
        
        InputStruct.Iext.IExtPattern            = getEmptyIExtPattern();
        InputStruct.Iext.IExtPattern            = AddInterval(Iext.IExtPattern, 0, 0,0,30000,0);
        InputStruct.Iext.IExtPattern            =     AddInterval(Iext.IExtPattern, 1, 0,1100,100,0);
        InputStruct.Iext.IExtPattern            =         AddInterval(Iext.IExtPattern, 2, 0,0,0,1);
        InputStruct.Iext.IExtPattern.NeuronPatterns = {uint32([1,45])};
        
        InputStruct.InitialState.Weight(InputStruct.NEnd > 800) = 8;

 5. Try out the following combination of parameters
     
      1. 
            
            ST_STDP_EffectMaxCausal     = single(0.11);
            ST_STDP_EffectMaxAntiCausal = single(0.11);
      2. 
            
            ST_STDP_EffectMaxCausal     = single(0.12);
            ST_STDP_EffectMaxAntiCausal = single(0.12);
     
    With:
    
        InputStruct.IinMax = 15, 20, 40, 50
       
#### Observations ####
  
  * The addition of the IinMax DOES NOT seem to RESOLVE the issue
    of instability. The reason is that a current level of upto 20
    seems to allow for instant spiking. and given a good enough 
    number of synapses of high weight, the network still becomes
    berserk.
    
  * Also, in order for spontaneous spiking to arise, it is nece-
    ssary to allow high input currents to a FEW neurons in the 
    network. Thus, if we reduce IinMax, then no Memory retention
    occurs as can be observed in the case where 
    
        InputStruct.IinMax = 15
    
### Experiment 6 - Performing Incoming Weight Normalization ###
  
#### Description ####
  
  In this case, 
  
#### Procedure ####
  
### To Do: ###

Formalize a basic heuristic measure of the expected activity of a neuron.

Now, (or without) formulate a heuristic measure of expected network burst 
tendency 

  - W/O involving PNG's (just histogram)
  - involving PNG's

Try studying the stability of networks with different statistics of
weights to understand stability.

perform basic calculus to understand the change in weights under non-
linear normalization

