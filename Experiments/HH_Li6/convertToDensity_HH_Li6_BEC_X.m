function density_image =                                                ...
    convertToDensity_HH_Li6_BEC_X(pauliObj, imagesStruct, XmlStr)
    % convertToDensity_HH_Li6_BEC_X    Simple Beer-Lambert
    
    Bright = imagesStruct.BrightBECX - imagesStruct.DarkBECX;
    Atoms = imagesStruct.AtomsBECX - imagesStruct.DarkBECX;
        
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