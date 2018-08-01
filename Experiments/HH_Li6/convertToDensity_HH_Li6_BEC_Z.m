function density_image =                                                ...
    convertToDensity_HH_Li6_BEC_Z(pauliObj, imagesStruct, XmlStr)
    % CONVERTTODENSITY_HH_LI6_BEC_Z    Calculates densities from images
    %    This method is specific to the Li6 Experiment in the Moritz group
    %    in Hamburg. It is a very standard Beer-Lambert law for one of our
    %    auxillary cameras.
    
    
    Bright = imagesStruct.BrightBECZ - imagesStruct.DarkBECZ;
    Atoms = imagesStruct.AtomsBECZ - imagesStruct.DarkBECZ;
        
    % Create Logarithmic Term
    LogTerm = log(Atoms ./ Bright);
    LogTerm = LogTerm / pauliObj.constants.user.sigma;
    
    density_image = - LogTerm;
    
    if pauliObj.parameters.user.dirtyHack
        density_image(isnan(density_image)) = 0;
        density_image(isinf(density_image)) = 0;
        density_image = real(density_image);
    end
end