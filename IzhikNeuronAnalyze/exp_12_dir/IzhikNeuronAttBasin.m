
addpath build/install;

%%
DynSysParameters.a = single(0.02);
DynSysParameters.b = single(0.2);
DynSysParameters.c = single(-65);   
DynSysParameters.d = single(8);

DynSysParameters.GridXSpec = single([-15; 0.02; 10]);
DynSysParameters.GridYSpec = single([-100; 0.05; 30]);

DynSysParameters.onemsbyTstep = uint32(2);

[IzhikSilentFBB, IzhikSilentBPB] = GetAttBasin_IzhikevichSilent(DynSysParameters);
[IzhikSpikingFBB, IzhikSpikingBPB] = GetAttBasin_IzhikevichSpiking(DynSysParameters);

[SimpleIzhikSpikingFBB, SimpleIzhikSpikingBPB] = GetAttBasin_SimpleIzhikevichSpiking(DynSysParameters);
[SimpleIzhikSilentFBB, SimpleIzhikSilentBPB] = GetAttBasin_SimpleIzhikevichSilent(DynSysParameters);

%% Plot
IzhikFig = figure();
ColorCubeScheme = colorcube(length(IzhikSilentBPB));
CopperScheme = colorcube(length(IzhikSpikingBPB));
GridXSpec = DynSysParameters.GridXSpec; % [0 1 1];
GridYSpec = DynSysParameters.GridYSpec; % [0 1 1];
hold on;
for i = 1:length(IzhikSpikingBPB)
	fill(double(IzhikSpikingBPB{i}.X)*GridXSpec(2) + GridXSpec(1), double(IzhikSpikingBPB{i}.Y)*GridYSpec(2) + GridYSpec(1), CopperScheme(i,:), 'LineStyle', 'none');
end
for i = 1:length(IzhikSilentBPB)
	fill(double(IzhikSilentBPB{i}.X)*GridXSpec(2) + GridXSpec(1), double(IzhikSilentBPB{i}.Y)*GridYSpec(2) + GridYSpec(1), ColorCubeScheme(i,:), 'LineStyle', 'none');
end
hold off;
xlim([GridXSpec(1), GridXSpec(3)])
ylim([GridYSpec(1), GridYSpec(3)])

SimpIzhikPartitionFig = figure();
ColorCubeScheme = colorcube(length(SimpleIzhikSilentBPB));
CopperScheme = colorcube(length(SimpleIzhikSpikingBPB));
hold on;
for i = 1:length(SimpleIzhikSpikingBPB)
	fill(double(SimpleIzhikSpikingBPB{i}.X)*GridXSpec(2) + GridXSpec(1), double(SimpleIzhikSpikingBPB{i}.Y)*GridYSpec(2) + GridYSpec(1), CopperScheme(i,:), 'LineStyle', 'none');
end
for i = 1:length(SimpleIzhikSilentBPB)
	fill(double(SimpleIzhikSilentBPB{i}.X)*GridXSpec(2) + GridXSpec(1), double(SimpleIzhikSilentBPB{i}.Y)*GridYSpec(2) + GridYSpec(1), ColorCubeScheme(i,:), 'LineStyle', 'none');
end
hold off;
xlim([GridXSpec(1), GridXSpec(3)])
ylim([GridYSpec(1), GridYSpec(3)])
