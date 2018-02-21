function outp = loadDensities(pauliObj)
    % LOADDENSITIES    Load the images requested and convert to densities
    %     This function will, for each combination of loopvars, load all
    %     the images defined in the parameters object. When all can be
    %     loaded, they are converted to a density as defined in
    %     convertToDensity. Then, all images not to be saved are discarded
    %     and the next set is loaded. 
    
    if pauliObj.parameters.verbose == true
        textprogressbar('RESET',1);
    end
    
    %% Hacky way of initialising the densities cell array
    numFields = 1;
    command = '';
    for i=1:numel(pauliObj.parameters.loopvars)
        tmp = numel(pauliObj.parameters.loopvars{i}.values);
        command = [command  num2str(tmp) ','];
        numFields = numFields*tmp;
    end
    command = command(1:end-1);
    command = [command '} = [];'];
    eval(['pauliObj.data.density{' command]);
    if numel(pauliObj.parameters.imagesToSave) > 0
        eval(['pauliObj.data.image{' command]);
    end
    
    %% Main loop loading the images and converting them to densities
    index = numel(pauliObj.parameters.loopvars);
    if pauliObj.parameters.verbose == true
        textprogressbar('Loading images & converting to densities... ');
    end
    
    % Flags and variables for output
    counter = 1;
    convertedCounter = 0;
    imagesNotFound = {};
    
    while index > 0
        
        % Struct later containing all the images that were loaded
        imgLoaded = struct();
        
        % Create the loop variable part of the filename and the cell index
        variableStr = '';
        cellIndex = '';
        for i=1:numel(pauliObj.parameters.loopvars)
            variableStr = [variableStr '_' pauliObj.parameters.         ...
                loopvars{i}.name '_' pauliObj.parameters.               ...
                loopvars{i}.value()];
            cellIndex = [cellIndex num2str(pauliObj.parameters.         ...
                loopvars{i}.currentIndex) ','];
        end
        variableStr = [variableStr '.png'];
        cellIndex = cellIndex(1:end-1); % Remove last comma
        
        % For each image to be loaded, create the full filepath. If a file
        % exists, load, crop and save it, otherwise skip the entire
        % combination of variables.
        flag = false;
        for i=1:numel(pauliObj.parameters.imagesToLoad)
            filename = [pauliObj.parameters.imagesToLoad{i} variableStr];
            filenameFull = [pauliObj.parameters.folderpath '\'  filename];
            if exist(filenameFull, 'file') == 2
                % Load Image
                temp = double(imread(filenameFull));
                % Crop Image and save
                imgLoaded.(pauliObj.parameters.imagesToLoad{i}) = ...
                    temp(pauliObj.parameters.crop(3):size(temp,1)-...
                    pauliObj.parameters.crop(4), ...
                    pauliObj.parameters.crop(1):size(temp,2)-...
                    pauliObj.parameters.crop(2));
            else
                flag = true;
                if pauliObj.parameters.verbose
                    imagesNotFound{end+1} = filename;
                end
                break;
            end
        end
        
        % If all images were loaded, convert them to a density and continue
        % to the next set of loopvars
        if ~flag
            %ret = convertToDensity(pauliObj, imgLoaded);
            convertedCounter = convertedCounter + 1;
        end
        
        % Save the images the user requested to be saved
        if ~flag
            for i=1:numel(pauliObj.parameters.imagesToSave)
                % Hacky, but makes sure we get the right entry 
                eval(['pauliObj.data.image{' cellIndex '}.('            ...
                    'pauliObj.parameters.imagesToSave{i}) = '           ...
                    'imgLoaded.(pauliObj.parameters.'                   ...
                    'imagesToSave{i})']);
            end
        end
        
        % This block below will increment the last loopvar. When the
        % loopvar signals that it has reset to 1, it goes to the second to
        % last loopvar, increments it by one and starts again with the
        % first value of the last loopvar. If the second to last is also
        % signalling that it has reset, it goes a step further, until the
        % first loopvar has signalled that it has reset. At this point, the
        % while loop is broken - all images have been loaded
        flag = false;
        while ~pauliObj.parameters.loopvars{index}.step()
            flag = true;
            index = index - 1;
            if index == 0
                break;
            end
        end
        if flag && index > 0
            index = numel(pauliObj.parameters.loopvars);
        end
        if pauliObj.parameters.verbose == true
            textprogressbar(100*counter/numFields);
        end
        counter = counter +1;
    % End big while loop    
    end
    if pauliObj.parameters.verbose == true
        textprogressbar([' ... done! (' num2str(convertedCounter) ' density images created)']);
        if numel(imagesNotFound) > 0
            disp('The following images were not found on your file system:');
            for i=1:numel(imagesNotFound)
                disp(imagesNotFound{i});
            end
            disp('Those density images have been skipped.');
        end
    end
end