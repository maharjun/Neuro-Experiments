function SetupExperiment {
	Param(
		[switch]$subupdate
	)
	# Set up submodules (This is done automatically by checkout)
	if ($subupdate){
		git submodule update --init --recursive
	}
	
	# Set up External-Current-Input in The respective submodule
	# Nothing to do right now.
	
	# Compile the respective Exe's 
	cd ..\WorkingMemory\TimeDelNetSim
	$WorkingMemConfig = "Configuration=Release_Exe,Platform=x64,AsSubProgram=true," + 
						"AssemblyName=TimeDelNetSim_WorkingMemory"
	Invoke-Expression "MsBuild /Property:$WorkingMemConfig /verbosity:m /clp:ErrorsOnly"
	
	$WorkingMemConfig = "Configuration=Release_Lib,Platform=x64,AsSubProgram=true," +
	                    "AssemblyName=TimeDelNetSim_WorkingMemory"
	Invoke-Expression "MsBuild /Property:$WorkingMemConfig /verbosity:m /clp:ErrorsOnly"
	cd ..\..\ExperimentCode
	
	cd ..\PolychronousGroupFind\PolychronousGroupFind\
	$PolychronousGroupFindConfig = "Configuration=Release_Exe,Platform=x64,AsSubProgram=true"
	Invoke-Expression "MsBuild /Property:$PolychronousGroupFindConfig /verbosity:m /clp:ErrorsOnly"
	
	$PolychronousGroupFindConfig = "Configuration=Release_Lib,Platform=x64,AsSubProgram=true"
	Invoke-Expression "MsBuild /Property:$PolychronousGroupFindConfig /verbosity:m /clp:ErrorsOnly"
	cd ..\..\ExperimentCode
}