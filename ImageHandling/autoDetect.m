function outp = autoDetect(PauliP, foldername)
    % AUTODETECT    Automatically detect the loop variables and their values.
    %     This function goes over all the png files in the folder "foldername".
    %     First, from the first entry, the names of the loopvars are extracted 
    %     some regexp. Then, all files are looped over and the different
    %     possible values for the loopvars are recorded. 
    images = {};
    filesList = {};
    loopvars = {};
    
    if PauliP.verbose == true
        textprogressbar('RESET',1);
    end
    
    %% Extract a full list of filenames in the directory
    
    % Get filenames for the given folder 
    input = dir(foldername);
    folderContent = {};
    for i=1:numel(input)
        if input(i).isdir == 0 && strcmpi(input(i).name(end-3:end),'.png') == 1
            folderContent{end+1} = input(i).name;
        end
    end
    
    %% Get Loopvar names from the first png file in the folder
    
    % Conservative Approach: Maximum Number of Loopvars is the number of
    % underscores in the file name divided by two (name_varname_value.png).
    % Less is possible. 
    % The regexp below should match 
    % (Imagename){_(var_name)_(var_value)}(possibly _continuity)(.png)
    % for any amount of the term in curly brackets. 
    % We start with the maximum number of variables possible and decrease the
    % number until we get a match. That match then defines the loopvars.
    for numberofVariables = length(find(folderContent{1}=='_'))/2:-1:0
        rE = ['(?:[a-zA-Z]+)' ...
            repmat('_([a-zA-Z_]+)_(?:[0-9e.-]+)',1,numberofVariables) ...
            '(?:_[0-9]+){0,1}.png'];
        regexpOut = regexp(folderContent{1}, rE,'tokens');
        if ~isempty(regexpOut) 
            break;
        end
    end
    regexpOut = regexpOut{1};
    % Create the loopvar objects and assign names
    for i=1:numel(regexpOut)
        temp = PauliLoopvar;
        temp.name = regexpOut{i};
        loopvars{i} = temp;
    end
    %% Make the full file list given the variable lists above

    if PauliP.verbose == true
            textprogressbar('Autodetecting loopvar values...  ');
    end
        
    % Define the regular Expression
    rE = '([a-zA-Z]*)'; % Image Name
    for i=1:numel(loopvars) % Name and Capture Groups for the Loopvars
        rE = [rE '_' loopvars{i}.name '_([0-9e.-]+)'];
    end
    rE = [rE '(?:_[0-9]+){0,1}']; % Continuity padding
    rE = [rE '.png'];
    
    % Loop over all files and extract values and save filename if it matches
    for i=1:numel(folderContent)
        if PauliP.verbose == true
            textprogressbar(i/numel(folderContent)*100);
        end
        
        regexpOut = regexp(folderContent{i}, rE, 'tokens');
        if isempty(regexpOut)
            continue;
        end
        regexpOut = regexpOut{1};

        % Image Name
        if (~any(strcmp(images,regexpOut{1})))
            images{end+1} = regexpOut{1};
        end

        % Loopvar Values
        for ii = 2:numel(loopvars)+1
            if (~any(strcmp(loopvars{ii-1}.values,regexpOut{ii})))
                loopvars{ii-1}.values{end+1} = regexpOut{ii};
            end
        end
        
        % Add file to files list
        filesList{end+1} = folderContent(i);

    end
    
    % Sort Loopvars
    for i=1:numel(loopvars)
        posVec = zeros(1,numel(loopvars{i}.values)); 
        for j=1:numel(loopvars{i}.values)
            posVec(j) = str2double(loopvars{i}.values{j});
        end
        [~, indices] = sort(posVec, 'ascend');
        loopvars{i}.values = loopvars{i}.values(indices);
    end        
    
    if PauliP.verbose == true
        textprogressbar(' ... done!');
    
        disp('Detected Loopvars: ');
        for i=1:numel(loopvars)
            valStr = '[';
            for j=1:numel(loopvars{i}.values)
                valStr = [valStr loopvars{i}.values{j} ','];
            end
            valStr = [valStr(1:end-1) ']'];
            disp([loopvars{i}.name ' -> ' valStr]);
        end        
    end
    %% Write results to PauliParameters Object

    PauliP.folderpath = foldername;
    PauliP.files = filesList;
    PauliP.images = images;
    PauliP.loopvars = loopvars;

    % If the user wants the object as a return, he shall get it.
    if nargout > 0
        outp = PauliP;
    else
        clear outp;
    end
    
end