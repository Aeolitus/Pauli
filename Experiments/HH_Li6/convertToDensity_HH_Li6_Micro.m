function density_image = convertToDensity_HH_Li6_Micro(pauliObj, imagesStruct)
    % CONVERTTODENSITY_HH_LI6_MICRO    Calculates densities from images
    %    This method is specific to the Li6 Experiment in the Moritz group
    %    in Hamburg. The methodology is described in Hueck, Klaus, et al. 
    %    "Calibrating high intensity absorption imaging of ultracold 
    %    atoms." Optics express 25.8 (2017): 8670-8679.
    
    %% Code taken from QMLi.prepareImages.convertToDensity
    
    % calculate fraction of photons reemitted into the objective due to the
    % high numerical aperture of 0.61
    % opening angle theta of the microscope:
    theta = asin(pauliObj.parameters.user.NA);
    % normalized solid angle SA = \Omega/(4*pi) = \int_0^\theta\int_0^\theta
    %  \sin(\phi)d\phi' d\theta' = theta * (-cos(theta) + cos(0))
    % photon reemission: see "Ultra-sensitive atom imaging for
    % matter-wave optics" NJP 13 (2011) 115012 (20pp), M. Pappa et al.
    % http://www.physics.uq.edu.au/BEC/Papers/NJP_13_115012_2011.pdf
    SA = 2*pi*(1-cos(theta))/(4*pi);
    
    % Calculate beta factor for BEC side fields
    if pauliObj.parameters.user.imagingField < 690
        beta = 1;
    else
        % beta according to lennarts evaluation done on 20170112
        a = 0.777;
        b0 = 52.38;
        t = 41.86;
        beta = 1-a*exp(-((pauliObj.parameters.user.imagingField/        ...
            pauliObj.parameters.user.GperA-b0)/t)^4);
    end
    
    % Subtract Dark Images
    Bright = imagesStruct.BrightM - imagesStruct.BrightDarkM;
    Atoms = imagesStruct.AtomsM - imagesStruct.AtomsDarkM;
    
    % Create Linear Term
    LinTerm = Bright - Atoms;
    LinTerm = LinTerm / pauliObj.constants.user.sigma / beta / (1 - SA);
    LinTerm = LinTerm / (pauliObj.parameters.user.Csat/4);
    LinTerm = LinTerm / pauliObj.parameters.user.Binning^2;
    LinTerm = LinTerm / 5; % Illumination Time
    
    % Create Logarithmic Term
    LogTerm = log(Atoms ./ Bright);
    LogTerm = LogTerm / pauliObj.constants.user.sigma / beta / (1 - SA);
    
    density_image = LinTerm - LogTerm;
end