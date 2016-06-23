%% Creating movie of histogram of Effective Weights for the different time instants
%  Tilt the screen for best effect

HistMovie = VideoWriter('WeightHistMovie1.avi');
HistMovie.FrameRate = 4;
open(HistMovie);
currfig = figure;
for i = 1:length(StateVarsUnstable.Time)
	EffWeights = getEffectiveWeights(...
		getSingleRecord(StateVarsUnstable, i), ...
		InputStateUnstable);
	
	CurrTimems = StateVarsUnstable.Time(i)/(InputStruct.onemsbyTstep);
	NoOfSpikes = OutputVarsUnstable.NoOfSpikes(i);
	
% 	% Bar graph plotting
% 	
% 	subplot(3,1,1); bar([10, 20], [nnz(EffWeights < 9.5), nnz(EffWeights >= 9.5)]);
% 	title(sprintf('T = %d', CurrTimems/1000 - 18000));
% 	xlim([0, 30]);
% 	ylim([0 10000]);
	
	% Histogram Plotting
	subplot(3,1,1); hist(EffWeights(EffWeights >= 0), 0:27);
	title(sprintf('T = %d', CurrTimems/1000));
	xlim([0, 30]);
	ylim([0 35000]);
	
	subplot(3,1,2); hist(StateVarsUnstable.Weight(EffWeights >= 0, i), 0:24);
	xlim([0, 30]);
	ylim([0 35000]);
	
	RelativeIncPlot = StateVarsUnstable.ST_STDP_RelativeInc(EffWeights >= 0, i);
	RelativeIncPlot(RelativeIncPlot < 0) = 0;
	subplot(3,1,3); hist(RelativeIncPlot, 0:0.1:2.5);
 	xlim([0, 3]);
	ylim([0 40000]);
	xlabel(sprintf('Spikes Generated = %d', NoOfSpikes));
	
	MaximizePlot();
	frame = getframe(gcf);
	writeVideo(HistMovie, frame);
end
close(HistMovie);
clear HistMovie i 