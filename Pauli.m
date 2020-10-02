classdef Pauli < handle
    % Pauli   Main class to interact with when working with Pauli.
    %     Contains all subclasses and handles all relevant method calls.
    %     You should not need to interact with anything else.
    properties
        % PauliParameters object for this instance of Pauli
        parameters;
        
        % PauliConst object for this instance of Pauli
        constants;
        
        % PauliData object for this instance of Pauli
        data;
    end
    methods
        function obj = Pauli(configfile, folderpath, flag)
            % Pauli    Constructor creating the pauli object and subobjects
            %     When called without an argument, creates an empty pauli
            %     object. When a .pauli file is passed, the entire object 
            %     is automatically loaded from that file. 
            %     If a config file and a folderpath are given, the folder
            %     is automatically scanned for files and the images are
            %     loaded and converted to densities. 
            loadF = '';
            analyze = '';
            
            % Create sub-objects
            obj.parameters = PauliParameters;
            obj.constants = PauliConst;
            obj.data = PauliData;
            
            if nargin > 0
                if strcmpi(configfile(end-5:end),'.pauli') == 1 && ...
                    exist(configfile, 'file') == 2
                    % First Parameter is a .pauli config file - load it.
                    loadF = configfile;
                else 
                    if exist(configfile, 'file') == 7
                        if exist(fullfile(configfile, 'savedPauliState.pauli'), 'file') == 2
                            % First Parameter is a folderpath to a folder
                            % where an evaluation was already done - load
                            % that evaluation back up
                            loadF = configfile;
                        end
                    else
                        % First Argument not recognized.
                        disp('Invalid first argument! Default Object returned.');
                    end
                end
            end
            if nargin > 1
                if exist(folderpath, 'file') == 7
                    if exist(fullfile(folderpath, 'savedPauliState.pauli'), 'file') == 2
                        % Second argument is a path to a folder where an
                        % evaluation was already done. Prompt the user if
                        % the old evaluation should be loaded or if a new
                        % one should be run
                        if nargin > 2 && flag
                            loadF = fullfile(folderpath, 'savedPauliState.pauli');
                        else
                            choice = questdlg(['This folder was already evaluated. ' ...
                                'Would you like to load the old evaluation or to redo it?'], ...
                                'Pauli-Savefile found', 'Load Old Evaluation', ...
                                'Perform New Evaluation','Load Old Evaluation');
                            switch choice
                                case 'Load Old Evaluation'
                                    loadF = fullfile(folderpath, 'savedPauliState.pauli');
                                case 'Perform New Evaluation'
                                    analyze = folderpath;
                            end
                        end
                    else
                        % This folder has not been evaluated before. Do it.
                        analyze = folderpath;
                    end
                else
                    % Second argument has to be a folder.
                    disp('Invalid Folder Path! No evaluation is done.');
                end
            end           
            
            % If we found a saved pauli object to load, do that
            if ~isempty(loadF)
                clear obj;
                loaded = load(loadF, '-mat');
                obj = loaded.PauliObject;
            end
            
            % If we also need to run an evaluation, do that. 
            if ~isempty(analyze)
                if obj.parameters.verbose
                    tic;
                end
                obj.autoDetect(folderpath);
                obj.createDensities;
                if obj.parameters.verbose
                    toc;
                end
                if obj.parameters.verbose
                    disp('Saving Pauli Object to Folder...');
                end
                obj.save;
            end     
        end % End Constructor
        
        function saveConfig(PauliObject, filename)    %#ok<INUSL>
            % saveConfig    This method saves the object to a file
            %    Creates a *.pauli file containing this object to be used
            %    as a starting point for later evaluations.
            if strcmpi(filename(end-5:end),'.pauli') ~= 1
                filename = [filename '.pauli'];
            end
            save(filename,'-v7.3','PauliObject');
        end
        
        function save(PauliObject)
            % SAVE    Saves the current state of the pauli object
            %    By default, this saves the Pauli object to the folder that
            %    is currently being evaluated. If no folder is set, the
            %    user is prompted to select a folder and filename.
            if ~isnan(PauliObject.parameters.folderpath)
                % A folder was analyzed. Save this object there.
                path = PauliObject.parameters.folderpath;
                file = 'savedPauliState.pauli';
            else
                % Ask the user where to save it.
                [file,path] = uiputfile('Pauli-Files (*.pauli)','Save Pauli-Object as...');
            end
            
            combined = fullfile(path,file);
            if exist(combined, 'file') == 2
                % A file would be overwritten! Ask what to do
                choice = questdlg(['A saved Pauli Object already exists! '...
                    'Would you like to overwrite it, rename the old one, or ' ...
                    'save this one under a different name?'], ...
                            'Pauli-Savefile already exists', 'Overwrite', ...
                            'Rename old','Save under a different name', 'Rename old');
                switch choice
                    case 'Overwrite'
                        % Overwrite away
                        PauliObject.saveConfig(combined);
                    case 'Rename old'
                        % Rename the old file
                        movefile(combined, [combined(1:end-6) '_old.pauli']);
                        PauliObject.saveConfig(combined);
                    case 'Save under a different name'
                        % Ask for a different name
                        [file2,path2] = uiputfile('Pauli-Files (*.pauli)','Save Pauli-Object as...');
                        combined2 = fullfile(path2,file2);
                        if strcmp(combined2,combined) == 1
                            % If you select the same twice, its hopeless
                            disp('Same file selected again - terminating.');
                            return;
                        end
                        if exist(combined2, 'file') == 2
                            % Again trying to overwrite stuff...
                            disp('This file also already exists - terminating.');
                            return;
                        end
                        PauliObject.saveConfig(combined2);
                end
            else
                PauliObject.saveConfig(combined);
            end
        end
        
        function autoDetect(obj, folderpath)
            % autoDetect    Automatically fill files and variables lists
            %    This method calls the external autoDetect method, which
            %    goes through the folder passed to this method or saved in 
            %    parameters.folderpath and extracts a list of images, files 
            %    and loopvars in that folder. Can be used to automatically 
            %    populate those variables.
            if nargin == 0
                autoDetect(obj.parameters, obj.parameters.folderpath);
            else
                autoDetect(obj.parameters, folderpath);
            end
        end
        
        function createDensities(obj, loadOnlyNew)
            % createDensities    Load images and convert them to densities
            %    This method calls the external loadDensities method, which
            %    goes and loads all the images defined via the
            %    PauliParameters and converts them to densities.
            if nargin < 2
                loadOnlyNew = 0;
            end
            loadDensities(obj, loadOnlyNew);
        end
        
        function average(obj, loopvar, filterfunction, data)
                % average   Automatically averages together images 
                %     Calls the external averageLoopvar function, averaging
                %     the loopvar given together. loopvar is the index or
                %     the name of the loopvar. filterfunction is an
                %     optional filtering function that returns true when
                %     passed an image that should be averaged and false
                %     otherwise. 
                if nargin < 4
                    data = obj.data.density;
                end
                if nargin < 3
                    filterfunction = @(~)true;
                end
                if nargin < 2
                    loopvar = 'i';
                end
                averageLoopvar(obj, loopvar, filterfunction, data);
        end
        
        function outp = filter(obj, sigmaDist, filterWidth, data)
                % FILTER    Filter the density images based on similarity
                %     This function implements a filtering of the data based on
                %     similarity. Basically, it treats each image as an element in
                %     a N-Dimensional vector space, where N is the number of pixels
                %     per image. It filters out all images who, after being
                %     filtered with a gaussian filter of width filterWidth (to get
                %     rid of shot noise and stuff) are more than sigmaDist sigma
                %     away from the median distance from the overall center of
                %     mass. This is basically how simple facial recognicion
                %     algorithms work and should filter mostly based on images
                %     having a similar structure.
                %     By default, the entire density cell array is filtered and
                %     images that are too far from the COM are replaced with []. If
                %     you have loopvars which will significantly change the cloud
                %     shape, you should pass individual parts of the data that you
                %     expect to look similar to the function as otherwise your data
                %     will not be filtered properly. 
                %     The output is returned by this function or, if you have not
                %     passed custom data to the function, saved in
                %     pauliObj.data.user.filtered
                if nargin < 4
                    data = obj.data.density;
                end
                if nargin < 3
                    filterWidth = 5;
                end
                if nargin < 2
                    sigmaDist = 2;
                end
                outp = filterImages(obj, sigmaDist, filterWidth, data);
        end
        
        function filterAndAverage(obj)
                % FILTERANDAVERAGE     Simple quick filtering and averaging
                %      This function runs the filtering function with
                %      default parameters on the density object and then
                %      runs the averaging function over it. Just a quick
                %      shortcut, no parameters. 
                outp = filterImages(obj, 2, 5, obj.data.density);
                obj.data.averaged = averageLoopvar(obj, 'i', @(~)true, outp);
        end
    end
end