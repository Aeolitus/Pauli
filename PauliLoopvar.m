classdef PauliLoopvar < handle
    % PauliLoopvar   Object describing a variable to be looped over
    properties
        name = ''
        values = {}
        currentIndex = 1
    end
    
    methods 
        function ret = step(obj)
            % ITERATE    Goes to the next value in the list.
            %     If the last value is reached, goes back to 1 and returns
            %     0. Otherwise, returns 1.
            if obj.currentIndex == numel(obj.values)
                obj.currentIndex = 1;
                ret = 0;
            else
                obj.currentIndex = obj.currentIndex + 1;
                ret = 1;
            end
        end
        
        function ret = value(obj)
            % VALUE    Returns the current value of this loopvar
            ret = obj.values{obj.currentIndex};
        end
    end
    
end