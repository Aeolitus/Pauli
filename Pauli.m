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
        function obj = Pauli(configfile, folderpath)
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
                        choice = questdlg(['This folder was already evaluated. ' ...
                            'Would you like to load the old evaluation or to redo it?'], ...
                            'Pauli-Savefile found', 'Load', ...
                            'Redo','Load');
                        switch choice
                            case 'Load'
                                loadF = fullfile(folderpath, 'savedPauliState.pauli');
                            case 'Redo'
                                analyze = folderpath;
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
                    disp('Saving Pauli Object to Folder...');
                end
                obj.save;
                if obj.parameters.verbose
                    toc;
                end
            end     
        end % End Constructor
        
        function saveConfig(PauliObject, filename)    %#ok<INUSL>
            % saveConfig    This method saves the object to a file
            %    Creates a *.pauli file containing this object to be used
            %    as a starting point for later evaluations.
            if strcmpi(filename(end-5:end),'.pauli') ~= 1
                filename = [filename '.pauli'];
            end
            save(filename,'PauliObject');
        end
        
        function save(PauliObject)
            % SAVE    Saves the current state of the pauli object
            %    By default, this saves the Pauli object to the folder that
            %    is currently being evaluated. If no folder is set, the
            %    user is prompted to select a folder and filename.
            if ~isnan(PauliObject.parameters.folderpath)
                PauliObject.saveConfig(fullfile(PauliObject.parameters. ...
                    folderpath,'savedPauliState.pauli'));
            else
                [file,path] = uiputfile('Pauli-Files (*.pauli)','Save Pauli-Object as...');
                PauliObject.saveConfig(fullfile(path,file));
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
        
        function createDensities(obj)
            % createDensities    Load images and convert them to densities
            %    This method calls the external loadDensities method, which
            %    goes and loads all the images defined via the
            %    PauliParameters and converts them to densities.
            loadDensities(obj);
        end
    end
end