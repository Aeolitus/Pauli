classdef PauliData < handle
    % PauliData   Class containing all data loaded from the images
    %     Contains densities, any further saved images and xml values.
    properties
        % Cell array containing the calculated densities
        density;
        
        % Cell array of structs containing all images that were saved
        image;
        
        % Cell array of strings with the PNGs XML text
        xml;
        
        % Struct with any additional data the user generates
        user;
    end
end