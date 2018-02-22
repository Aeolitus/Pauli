function density_image =                                                ...
    convertToDensity_Template(pauliObj, imagesStruct, XmlStr)
    % convertToDensity_Template    Template for conversion to density
    %    This method is responsible for calculating a density image from
    %    the loaded images that were saved there by CameraControl. Since
    %    what you do here depends heavily on your experiments, you will
    %    have to write it yourself. It is called once for every density 
    %    image to be calculated.
    %    INPUT: 
    %       pauliObj      -  A reference to the main Pauli object, by means
    %           of which you can access 
    %           natural constants (pauliObj.constants), 
    %           your user defined constants (pauliObj.constants.user), 
    %           the loading parameters (pauliObj.parameters), 
    %           your user defined parameters (pauliObj.parameters.user), 
    %           the data loaded so far (pauliObj.data.density), 
    %           the current values of the loopvars
    %           ( pauliObj.parameters.loopvars{index}.value() ), and
    %           whatever else you may need. 
    %       imagesStruct  -  A struct containing a field for each image you
    %           specified in pauliObj.parameters.imagesToLoad . 
    %           Example: Your Images to load is {'Atoms', 'Bright'}. Then,
    %           the fields are imagesStruct.Atoms and imagesStruct.Bright .
    %       XmlStr        - A char array with the entire XML header written
    %           into the PNG files by CameraControl. You can use this to
    %           access variables, hardware definitions, events and so forth
    %           via Regular Expressions. I advocate against parsing the
    %           XML, as that takes a lot longer than just a simple regexp.
    %           For example, if you wish to determine the value of the
    %           variable named "Time_Of_Flight", the expression to use
    %           would be 
    %               regexp(XmlStr,['<name>Time_Of_Flight</name>'        ...
    %               '(?:\s*)<value>([0-9eE.-]+)</value>'],'tokens','once');
    %           , which returns a cell array with the value in it if found.
    %   OUTPUT:
    %       density_image - A matrix of the same dimensions as the images
    %           in the imagesStruct that will be saved into
    %           pauliObj.data.density{The indices of the loopvars}.
    %
    %       If you wish to save any additional results, please do so using
    %       the user fields in pauliObj.parameters, pauliObj.constants and
    %       pauliObj.data :)
    %
    %   For Inspiration, feel free to check out the functions found in
    %   other experiments and modes! And dont forget to replace this
    %   comment with a description of what your method does ;)
    
    % DUMMY CODE
    density_image = NaN;
end