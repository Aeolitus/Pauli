function loadDensities(pauliObj, loadOnlyNew)
    % LOADDENSITIES    Load the images requested and convert to densities
    %     This function will, for each combination of loopvars, load all
    %     the images defined in the parameters object. When all can be
    %     loaded, they are converted to a density as defined in
    %     convertToDensity. Then, all images not to be saved are discarded
    %     and the next set is loaded. 
    if nargin<2
        loadOnlyNew = 0;
    end
    
    if pauliObj.parameters.verbose == true
        textprogressbar('RESET',1);
    end
    
     %% Hacky way of initialising the cell arrays
     
    % New loopvars added?
    initArrays = 0;
    if ~isempty(pauliObj.data.density)
        for i=1:numel(pauliObj.parameters.loopvars)
            tmp = numel(pauliObj.parameters.loopvars{i}.values);
            if size(pauliObj.data.density,i) ~= tmp
                initArrays = 1;
                break;
            end
        end
    else
        initArrays = 1;
    end
    
    numFields = 1;
    command = '';
    for i=1:numel(pauliObj.parameters.loopvars)
        tmp = numel(pauliObj.parameters.loopvars{i}.values);
        command = [command  num2str(tmp) ','];
        numFields = numFields*tmp;
    end
    command = command(1:end-1);
    command = [command '} = [];'];
    if initArrays
        eval(['pauliObj.data.density{' command]);
        if numel(pauliObj.parameters.imagesToSave) > 0
            eval(['pauliObj.data.image{' command]);
        end
        eval(['pauliObj.data.xml{' command]);
    end
    
    %% Main loop loading the images and converting them to densities
    index = numel(pauliObj.parameters.loopvars);
    if pauliObj.parameters.verbose == true
        textprogressbar('Loading and converting images... ');
    end
    
    % Flags and variables for output
    counter = 1;
    convertedCounter = 0;
    imagesNotFound = {};
    skippedOldCounter = 0;
    
    while index > 0
        
        % Struct later containing all the images that were loaded
        imgLoaded = struct();
        xmlStruct = struct();
        
        % Create the loop variable part of the filename and the cell index
        variableStr = '';
        cellIndex = '';
        % Assemble file name using the loopvars in their original order
        for i=pauliObj.parameters.filenameLoopvarsOrder
            variableStr = [variableStr '_' pauliObj.parameters.         ...
                loopvars{i}.name '_' pauliObj.parameters.               ...
                loopvars{i}.value()];
        end
        variableStr = [variableStr '.png'];
        % Assemble cell index
        for i=1:numel(pauliObj.parameters.loopvars)
            cellIndex = [cellIndex num2str(pauliObj.parameters.         ...
                loopvars{i}.currentIndex) ','];
        end
        cellIndex = cellIndex(1:end-1); % Remove last comma
        
        if ~loadOnlyNew || eval(['isempty(pauliObj.data.density{' cellIndex '})'])
            % For each image to be loaded, create the full filepath. If a file
            % exists, load, crop and save it, otherwise skip the entire
            % combination of variables.
            flag = false;
            for i=1:numel(pauliObj.parameters.imagesToLoad)
                filename = [pauliObj.parameters.imagesToLoad{i} variableStr];
                filenameFull = [pauliObj.parameters.folderpath '\'  filename];
                if exist(filenameFull, 'file') == 2
                    % Load Image
                    try
                        temp = double(imread(filenameFull));
                    catch
                        flag = true;
                        if pauliObj.parameters.verbose
                            imagesNotFound{end+1} = [filename ' - Error when loading PNG'];
                        end
                        break;
                    end
                    % Crop Image and save, or dont crop if not ordered to
                    if any(strcmp(pauliObj.parameters.imagesToCrop, ...
                            pauliObj.parameters.imagesToLoad{i}))
                        imgLoaded.(pauliObj.parameters.imagesToLoad{i}) = ...
                            temp(1+pauliObj.parameters.crop(3):size(temp,1)-...
                            pauliObj.parameters.crop(4), ...
                            1+pauliObj.parameters.crop(1):size(temp,2)-...
                            pauliObj.parameters.crop(2));
                    else
                        imgLoaded.(pauliObj.parameters.imagesToLoad{i}) = ...
                            temp;
                    end
                    % Extract XML
                    if i==1
                        ImgInfo = imfinfo(filenameFull);
                        XmlText = strrep(ImgInfo.OtherText{3,2}, ...
                            'ISO8859-1', 'ISO-8859-1');
                        evalc(['pauliObj.data.xml{' cellIndex '}=XmlText;']);
                    end
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
                % Pretty hacky section. Not as nice as could be done
                evalc(['ret = ' pauliObj.parameters.                        ...
                    convertToDensityFunctionName                            ...
                    '(pauliObj, imgLoaded, XmlText);']);
                evalc(['pauliObj.data.density{' cellIndex '} = ret;']);
                convertedCounter = convertedCounter + 1;
            end

            % Save the images the user requested to be saved
            if ~flag && iscell(pauliObj.parameters.imagesToSave)
                for i=1:numel(pauliObj.parameters.imagesToSave)
                    % Hacky, but makes sure we get the right entry 
                    evalc(['pauliObj.data.image{' cellIndex '}.('           ...
                        'pauliObj.parameters.imagesToSave{i}) = '           ...
                        'imgLoaded.(pauliObj.parameters.'                   ...
                        'imagesToSave{i})']);
                end
            end
        else
            skippedOldCounter = skippedOldCounter + 1;
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
        if skippedOldCounter == 0
            textprogressbar([' ... done! (' num2str(convertedCounter) ' density images created)']);
        else
            textprogressbar([' ... done! (' num2str(convertedCounter)...
                ' density images added, ' num2str(convertedCounter+skippedOldCounter) ' total)']);
        end
        if numel(imagesNotFound) > 0
            disp('The following images were not found on your file system:');
            for i=1:numel(imagesNotFound)
                disp(imagesNotFound{i});
            end
            disp('Those density images have been skipped.');
        end
    end
end