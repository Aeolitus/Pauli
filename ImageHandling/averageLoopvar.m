function outp = averageLoopvar(pauliObj,loopvar, filterFunction, data)
    % AVERAGELOOPVAR 	Automatically averages together images 
    %     This function averages together one of the dimensions of the
    %     densities object, so all values of a given loopvar. The loopvar
    %     can be given as a number (index in the
    %     pauliObj.parameters.loopvars cell array) or a string (the name of
    %     the loopvar). The filterfunction can be a function handle that
    %     is given the image as a double matrix and returns true if the
    %     image should be considered, and false if it should be discarded.
    if nargin < 4 
        data = pauliObj.data.density;
    end
    % If no filterfunction is given, dont filter
    if nargin < 3
        filterFunction = @(~)true;
    end
    % If a name is given, get the correct index
    if ~isnumeric(loopvar)
        for i=1:numel(pauliObj.parameters.loopvars)
            if loopvar == pauliObj.parameters.loopvars{i}.name
                loopvar = i;
                break;
            end
        end
        if ~isnumeric(loopvar)
            error('The given loopvar could not be recognized!');
        end
    end
    
    %% Average together
    
    % Move the dimension to average over to the end
    permVec = 1:numel(pauliObj.parameters.loopvars);
    permVec(permVec==loopvar) = [];
    permVec = [permVec loopvar];
    densTemp = permute(data, permVec);
    
    % Reshape cell array so that all other dimensions are collapsed into
    % one
    sizes = size(densTemp);
    mults = prod(sizes(1:end-1));
    densTemp = reshape(densTemp, mults, []);
    
    % Preallocate array for averaging densities
    avgTemp = cell(mults,1);
    for i=1:mults
        avgTemp{i} = zeros(size(data{1}));
    end
    avgC = 0;
    
    % Average together images if filterfunction is true
    for i=1:size(densTemp,1)
        for j=1:size(densTemp,2)
            if ~isempty(densTemp{i,j}) && filterFunction(densTemp{i,j})
                avgTemp{i} = avgTemp{i} + densTemp{i,j};
                avgC = avgC + 1;
            end
        end
        avgTemp{i} = avgTemp{i} ./ avgC;
        avgC = 0;
    end
    
    % Cleanup and reshape back to original shape minus averaged dimension
    clear densTemp;
    if (numel(sizes(1:end-1))>1)
        averaged = reshape(avgTemp, sizes(1:end-1));
    else
        averaged = squeeze(avgTemp);
    end
    clear avgTemp;
    if nargin < 4
        pauliObj.data.averaged = averaged;
        pauliObj.parameters.averagedLoopvar = loopvar;
    end
    outp = averaged;
end