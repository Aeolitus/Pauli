function outp = filterImages(pauliObj, sigmaDist, filterWidth, data)
    % FILTERIMAGES    Filter the density images based on similarity
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
        data = pauliObj.data.density;
    end
    if nargin < 3
        filterWidth = 5;
    end
    if nargin < 2
        sigmaDist = 2;
    end

    % Make Data Structures
    if numel(size(data)) > 1
        sizes = size(data);
        vectorized = reshape(data,[],1);
        cpVectorized = vectorized;
    else
        vectorized = data;
    end
    distances = zeros(numel(vectorized),1);
    selectVec = zeros(numel(vectorized),1);

    % Get average vector and filter it
    dd = zeros(size(data{1}));
    dc = 0;
    for i=1:numel(vectorized)
        if isempty(vectorized{i})
            continue;
        end
        dd = dd + vectorized{i};
        dc = dc + 1;
    end
    avgMat = imgaussfilt(dd ./ dc, filterWidth);
    avgVec = avgMat(:);

    % filter and increase distances, get norm
    for i=1:numel(vectorized)
        if isempty(vectorized{i})
            distances(i) = NaN;
            continue;
        end
        dataVec = imgaussfilt(vectorized{i},filterWidth);
        dataVec = dataVec(:);
        distVec = dataVec - avgVec;
        distances(i) = sum(distVec.^2);
    end
    
    % Try to autodetect interval
    cutOff = NaN;
    if isfield(pauliObj.parameters.user,'Autofilter') && pauliObj.parameters.user.Autofilter
        [N, edges] = histcounts(distances);
        [pks, loc] = findpeaks(smooth(1./N,3), edges(1:end-1));
        loc(isinf(pks)) = [];
        if numel(loc) > 0
            cutOff = loc(1);
            for i=1:numel(vectorized)
                if isempty(vectorized{i})
                    continue;
                end
                if distances(i) < cutOff
                    selectVec(i) = 1;
                end
            end
        end 
    end
    if isnan(cutOff )
        % Select all images further away that the given confidence interval
        medDist = median(distances, 'omitnan');
        stdDist = std(distances, 'omitnan');
        for i=1:numel(vectorized)
            if isempty(vectorized{i})
                continue;
            end
            if distances(i) - medDist < sigmaDist*stdDist
                selectVec(i) = 1;
            end
        end
    end

    % Remove all images further away than given confidence interval
    for i=1:numel(vectorized)
        if isempty(vectorized{i})
            continue;
        end
        if ~selectVec(i)
            vectorized{i} = [];
        end
    end

    % Reshape back
    if numel(size(data)) > 1
        outp = reshape(vectorized, sizes);
    else
        outp = vectorized;
    end
    
    % Save to object
    if nargin < 4
        pauliObj.data.user.filtered = outp;
    end
    
    % Generate Output Plot
    if pauliObj.parameters.verbose
        figure;
        ax = subplot(2,3,[1 2 4 5]);
        hold on
        histogram(distances);
        ax.Box = 'on';
%         ax.YScale = 'log';
        if isnan(cutOff)
            line([1 1]*medDist+sigmaDist*stdDist, ax.YLim);
        else
            line([1 1]*cutOff, ax.YLim, 'Color', 'r');
            xx = ax.XLim();
            xx(1) = cutOff;
            xx = [xx, fliplr(xx)];
            yy = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            fill(xx,yy,'r','FaceAlpha',0.2, 'EdgeColor', 'none');
        end
        ax.TickLabelInterpreter = 'latex';
        ax.XTickLabel = {};
        xlabel('Distance from average image', 'Interpreter', 'latex');
        ylabel('Occurances', 'Interpreter', 'latex');
        title('Analysis of image similarities', 'Interpreter', 'latex');
        
        ax = subplot(2,3,3);
        sumExcl = sum(selectVec == 0);
        disp(['A total of ' num2str(sumExcl) ' images has been removed by the filter.']);
        if sumExcl > 0
            posInd = find(selectVec == 0);
            imInd = ceil(rand()*sumExcl);
            imagesc(cpVectorized{posInd(imInd)});
            ax.TickLabelInterpreter = 'latex';
            ax.XTickLabel = {};
            ax.YTickLabel = {};
            xlabel('');
            ylabel('');
            title('Random rejected image', 'Interpreter', 'latex');
            
            ax = subplot(2,3,6);
            if sumExcl > 1
                posInd = find(selectVec ~= 0);
                imInd = ceil(rand()*numel(posInd));
                imagesc(cpVectorized{posInd(imInd)});
                ax.TickLabelInterpreter = 'latex';
                ax.XTickLabel = {};
                ax.YTickLabel = {};
                xlabel('');
                ylabel('');
                title('Random accepted image', 'Interpreter', 'latex');
            end
        end
        set(gcf, 'Color', 'w');
        sgtitle('Summary of the Filtering process', 'Interpreter', 'latex');
    end