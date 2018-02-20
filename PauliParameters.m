classdef PauliParameters < handle
    % PauliParameters   Class containing everything the user puts in
    %     All parameters that are set by the user are stored in this class.
    %     It should ideally not be modified by code afterwards, except for
    %     some specific cases like the automatic detection of the files in
    %     the folder and such things. Default values for parameters are not
    %     set here, but in a config file.
    properties
        % boolean flag if output shout be generated
        verbose = NaN;
        
        % Path to the folder containing the CameraControl images
        folderpath = NaN;
        
        % Array of structs with field "name" and cell array "values" 
        loopvars = NaN;
        
        % Cell Array of filenames to use
        files = NaN;
        
        % Cell Array of possible image names
        images = NaN;
    end
    methods
        function obj = PauliParameters(configfile)
            % Pauliparameters    Constructor. Call with cfg file to load.
            %     When called without any argument, this method creates a
            %     PauliParameters object where all fields are set to NaN to
            %     signal that they have not been set. When called with a
            %     filename, the constructor will attempt to load the
            %     PauliParameters object saved therein via the saveConfig
            %     method of this class.
            if nargin > 0 && exist(configfile, 'file') == 2
                clear obj;
                loaded = load(configfile, '-mat');
                obj = loaded.PauliParametersObject;
            end
        end
        
        function saveConfig(PauliParametersObject, filename)    %#ok<INUSL>
            % saveConfig    This method saves the parameters to a file
            %    Creates a *.pauliP file containing this object to be used
            %    as a starting point for later evaluations.
            if strcmpi(filename(end-6:end),'.paulip') ~= 1
                filename = [filename '.pauliP'];
            end
            save(filename,'PauliParametersObject');
        end
    end
end