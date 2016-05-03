function [ TopLevelDir ] = InitTopLevelDir(SubDir)
%INITTOPLEVELDIR Calculates Top Level Directory of the Experiment Folder
% 
%    [ FullPathFunc ] = InitTopLevelDir(SubDir)
% 
% Input Arguments:
% 
% 1.  SubDir - The path of a subdirectory whose ancestor is the top level
%              directory of the Experiment Folder. If ommitted, it takes on
%              the value given by pwd.
% 
% Output Arguments:
% 
% 2.  TopLevelDir - The Path of the top level directory, formatted using
%                   '/' separator without a '/' at the end unless its a
%                   root drive. (output of fullfile)
% 
% Working:
% 
% The top level directory of the experiment repository is characterized by
% the existence of a file "EXP_TOP_LEVEL_DIR.indic".

if (nargin < 1)
	SubDir = pwd;
	SubDir = strrep(SubDir, '\', '/');
end

OrigDirectory = pwd;
OrigDirectory = strrep(OrigDirectory, '\', '/');

try
	cd(SubDir);
	while true
		CurrentDirectory = pwd;
		CurrentDirectory = strrep(CurrentDirectory, '\', '/');
		
		if ~isempty(ls('EXP_TOP_LEVEL_DIR.indic'))
			TopLevelDir = CurrentDirectory;
			cd(OrigDirectory);
			clear OrigDirectory CurrentDirectory
			break;
		elseif ~isempty(regexp(CurrentDirectory, '^[A-Z]:/$', 'ONCE'))
			TopLevelDir = '';
			cd(OrigDirectory);
			clear OrigDirectory CurrentDirectory
			break;
		end
		cd ..
	end
catch
	cd(OrigDirectory);
	clear OrigDirectory CurrentDirectory
end

if isempty(TopLevelDir)
	Ex = MException('PathFinding:NoTopPath', ...
		[ 'The Top Path of the Experiments directory' ...
		  ' does not appear to be either the current' ...
		  ' directory or a parent of the current directory']);
	throw(Ex);
end

end

