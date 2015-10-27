SpikeList = OutputVarsSpikeListActivity.SpikeList;
TimeRchd = SpikeList.TimeRchd;

InputWeights = cell(length(TimeRchd),1);
Weights = getEffectiveWeights(FinalStateSpikeListActivity.Weight, FinalStateSpikeListActivity.ST_STDP_RelativeInc);

for i = 1:length(TimeRchd)
	CurrTimeRchd = TimeRchd(i);
	
	CurrInputSpikes = SpikeList.SpikeSynInds(SpikeList.TimeRchdStartInds(i)+1:SpikeList.TimeRchdStartInds(i+1));
	CurrInputSpikesNEnd = InputStateSpikeListActivity.NEnd(CurrInputSpikes+1);
	CurrInputSpikesWeight = Weights(CurrInputSpikes+1);
	
	% Spilt Spikes by NEnd
	InputSpikesbyNEnd = accumarray(CurrInputSpikesNEnd, CurrInputSpikesWeight, [N 1], @(x) {x}, {[]}); 
end