function density_image =                                                ...
    convertToDensity_HH_Li6_Micro(pauliObj, imagesStruct, XmlStr)
    % CONVERTTODENSITY_HH_LI6_MICRO    Calculates densities from images
    %    This method is specific to the Li6 Experiment in the Moritz group
    %    in Hamburg. The methodology is described in Hueck, Klaus, et al. 
    %    "Calibrating high intensity absorption imaging of ultracold 
    %    atoms." Optics express 25.8 (2017): 8670-8679.
    %    First, the relevant fields from the XML are extracted and values
    %    such as the magnetic field during imaging are calculated. Then,
    %    the density is calculated using a modified Beer-Lambert's law.
    %    This Density Determination Method is only valid for the
    %    "Micro"-Camera, which is an Andor Ixon.
    
    %% Extract useful values from XML
    % This is done via regexp, because converting the string to something
    % useful takes a lot of time that we dont want to spend.
    if ~isfield(pauliObj.parameters.user,'ImgIlluminationTime') ||      ...
            isnan(pauliObj.parameters.user.ImgIlluminationTime)
        
        binx = NaN;
        biny = NaN;
        imgIlluminationTime = NaN;
        FB_I_Img = NaN;
        HH_I_Img = NaN;
        High_Curvature_Q = NaN;

        match = regexp(XmlStr,['<camera type="Ixon">(?:.*)<binx>'       ...
            '([0-9]+)</binx>(?:.*)<name>Micro</name>'],'tokens','once');
        if ~isempty(match)
            binx = str2double(match{1});
        end
        
        match = regexp(XmlStr,['<camera type="Ixon">(?:.*)<biny>'       ...
            '([0-9]+)</biny>(?:.*)<name>Micro</name>'],'tokens','once');
        if ~isempty(match)
            biny = str2double(match{1});
        end
        
        match = regexp(XmlStr,['<name>Img_Illumination_Time</name>'     ...
            '(?:\s*)<value>([0-9eE.-]+)</value>'],'tokens','once');
        if ~isempty(match)
            imgIlluminationTime = str2double(match{1});
        end
        
        match = regexp(XmlStr,['<name>FB_I_Img</name>'                  ...
            '(?:\s*)<value>([0-9eE.-]+)</value>'],'tokens','once');
        if ~isempty(match)
            FB_I_Img = str2double(match{1});
        end
        
        match = regexp(XmlStr,['<name>HH_I_Img</name>'                  ...
            '(?:\s*)<value>([0-9eE.-]+)</value>'],'tokens','once');
        if ~isempty(match)
            HH_I_Img = str2double(match{1});
        end
        
        match = regexp(XmlStr,['<name>High_Curvature_Q</name>'          ...
            '(?:\s*)<value>([0-9eE.-]+)</value>'],'tokens','once');
        if ~isempty(match)
            High_Curvature_Q = str2double(match{1});
        end

        pauliObj.parameters.user.ImgIlluminationTime = imgIlluminationTime;
        pauliObj.parameters.user.Binning = binx;
        pauliObj.parameters.user.Binning_X = binx;
        pauliObj.parameters.user.Binning_Y = biny;

        if (binx ~= biny)
            disp('Binnings are not the same! Please check densities!');
        end

        if High_Curvature_Q
            pauliObj.parameters.user.imagingfield =                     ...
                FB_I_Img*pauliObj.parameters.user.GperA -               ...
                HH_I_Img*pauliObj.parameters.user.GperA/1.544;
        else
            pauliObj.parameters.user.imagingfield =                     ...
                FB_I_Img*pauliObj.parameters.user.GperA +               ...
                HH_I_Img*pauliObj.parameters.user.GperA/1.544;
        end
    end
    
    
    %% Code taken from QMLi.prepareImages.convertToDensity
    
    % calculate fraction of photons reemitted into the objective due to the
    % high numerical aperture of 0.61
    % opening angle theta of the microscope:
    theta = asin(pauliObj.parameters.user.NA);
    % normalized solid angle SA= \Omega/(4*pi) = \int_0^\theta\int_0^\theta
    %  \sin(\phi)d\phi' d\theta' = theta * (-cos(theta) + cos(0))
    % photon reemission: see "Ultra-sensitive atom imaging for
    % matter-wave optics" NJP 13 (2011) 115012 (20pp), M. Pappa et al.
    % http://www.physics.uq.edu.au/BEC/Papers/NJP_13_115012_2011.pdf
    SA = 2*pi*(1-cos(theta))/(4*pi);
    
    % Calculate beta factor for BEC side fields
    if pauliObj.parameters.user.imagingfield < 690
        beta = 1;
    else
        % beta according to lennarts evaluation done on 20170112
        a = 0.777;
        b0 = 52.38;
        t = 41.86;
        beta = 1-a*exp(-((pauliObj.parameters.user.imagingfield/        ...
            pauliObj.parameters.user.GperA-b0)/t)^4);
    end
    
    % Subtract Dark Images
    Bright = imagesStruct.BrightM - imagesStruct.BrightDarkM;
    Atoms = imagesStruct.AtomsM - imagesStruct.AtomsDarkM;
    
    if pauliObj.parameters.user.ImgIlluminationTime ~= 5e-6
        disp(['The ImgIlluminationTime extracted from the XML is '      ...
            'wrong!\nOur Density evaluation is designed to work for a ' ...
            'ImgIlluminationTime of 5e-6 - the XML reports ' num2str(   ...
            pauliObj.parameters.user.ImgIlluminationTime) 'instead. '   ...
            'Be careful, since your calculated densities will be wrong!']);
    end
    
    % Create Linear Term
    LinTerm = Bright - Atoms;
    LinTerm = LinTerm / pauliObj.constants.user.sigma / beta / (1 - SA);
    LinTerm = LinTerm / (pauliObj.parameters.user.Csat/4);
    LinTerm = LinTerm / (pauliObj.parameters.user.Binning^2);
    LinTerm = LinTerm / pauliObj.parameters.user.ImgIlluminationTime / 1e6; 
    
    % Create Logarithmic Term
    LogTerm = log(Atoms ./ Bright);
    LogTerm = LogTerm / pauliObj.constants.user.sigma / beta / (1 - SA);
    
    density_image = LinTerm - LogTerm;
end