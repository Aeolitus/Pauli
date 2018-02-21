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
        function obj = Pauli(configfile)
            % Pauli    Constructor creating the pauli object and subobjects
            %     When called without an argument, creates an empty pauli
            %     object. When a .pauliP file is passed, the parameters
            %     file is automatically loaded from that file. When a
            %     .pauli file is passed, the entire object is automatically
            %     loaded from that file. 
            obj.parameters = PauliParameters;
            obj.constants = PauliConst;
            obj.data = PauliData;
            if nargin > 0
                if strcmpi(configfile(end-6:end),'.pauliP') == 1 && ...
                        exist(configfile, 'file') == 2
                    loaded = load(configfile, '-mat');
                    obj.parameters = loaded.PauliParametersObject;
                else
                    if strcmpi(configfile(end-5:end),'.pauli') == 1 && ...
                        exist(configfile, 'file') == 2
                        clear obj;
                        loaded = load(configfile, '-mat');
                        obj = loaded.PauliObject;
                    end
                end
            end
        end
        
        function saveConfig(PauliObject, filename)    %#ok<INUSL>
            % saveConfig    This method saves the object to a file
            %    Creates a *.pauli file containing this object to be used
            %    as a starting point for later evaluations.
            if strcmpi(filename(end-5:end),'.pauli') ~= 1
                filename = [filename '.pauli'];
            end
            save(filename,'PauliObject');
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
    end
end