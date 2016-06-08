
addpath build/install;

%%
DynSysParameters.a = single(0.02);
DynSysParameters.b = single(0.2);
DynSysParameters.c = single(-65);   
DynSysParameters.d = single(8);

DynSysParameters.GridXSpec = single([-15; 0.02; 10]);
DynSysParameters.GridYSpec = single([-100; 0.05; 30]);

DynSysParameters.onemsbyTstep = uint32(2);

[IzhikFullBasinBoundary, IzhikBasinPartitionBoundaries] = GetAttBasin_IzhikevichSilent(DynSysParameters);
[SimpIzhikFullBasinBoundary, SimpIzhikBasinPartitionBoundaries] = GetAttBasin_SimpleIzhikevichSilent(DynSysParameters);

%% Plot
IzhikPartitionFig = figure();
colormap(IzhikPartitionFig, colorcube(length(IzhikBasinPartitionBoundaries)));
GridXSpec = DynSysParameters.GridXSpec; % [0 1 1];
GridYSpec = DynSysParameters.GridYSpec; % [0 1 1];
fill(double(IzhikFullBasinBoundary.X)*GridXSpec(2) + GridXSpec(1), double(IzhikFullBasinBoundary.Y)*GridYSpec(2) + GridYSpec(1), 'b', 'LineStyle', 'none');
hold on;
for i = 1:length(IzhikBasinPartitionBoundaries)
	fill(double(IzhikBasinPartitionBoundaries{i}.X)*GridXSpec(2) + GridXSpec(1), double(IzhikBasinPartitionBoundaries{i}.Y)*GridYSpec(2) + GridYSpec(1), i, 'LineStyle', 'none');
end
hold off;
xlim([GridXSpec(1), GridXSpec(3)])
ylim([GridYSpec(1), GridYSpec(3)])

SimpIzhikPartitionFig = figure();
colormap(SimpIzhikPartitionFig, copper(length(SimpIzhikBasinPartitionBoundaries)));
fill(double(SimpIzhikFullBasinBoundary.X)*GridXSpec(2) + GridXSpec(1), double(SimpIzhikFullBasinBoundary.Y)*GridYSpec(2) + GridYSpec(1), 'b', 'LineStyle', 'none');
hold on;
for i = 1:length(SimpIzhikBasinPartitionBoundaries)
	fill(double(SimpIzhikBasinPartitionBoundaries{i}.X)*GridXSpec(2) + GridXSpec(1), double(SimpIzhikBasinPartitionBoundaries{i}.Y)*GridYSpec(2) + GridYSpec(1), i, 'LineStyle', 'none');
end
hold off;
xlim([GridXSpec(1), GridXSpec(3)])
ylim([GridYSpec(1), GridYSpec(3)])
