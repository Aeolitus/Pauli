## Pauli
Pauli is a flexible tool for loading and working with ExpWiz-created PNG files. It builds heavily on its predecessor, QMLi, trying to streamline and generalize the process of working with the images taken by CameraControl.

### Who should use Pauli and what does it do?
Pauli is written as a general as possible and should thus be useful for anybody who runs their experiment using the ExperimentWizard. 
At its core, Pauli does everything neccessary for going from a folder full of .png images taken by CameraControl to a useable data structure filled with density matrices. To accomplish that, Pauli can detect the shots and loopvars taken, load the images, extract the XML, and run the images through a user defined function to convert them to density matrices. 

### How is Pauli structured?
Generally speaking, a user should not need to modify Pauli except for the files specific to their experiment and mode. 
Each "Experiment" (for example, the Lithium-6 machine in Hamburg) has its own subfolder in Pauli/Experiments/ - and inside that subfolder, configuration files can be found for the "Modes" - which can, for example, be different Cameras.
These files, however, do not need to be created by hand - a setup script is provided for that.
The structure of the Pauli object is defined by the classes found in the main folder. 

`
Pauli (Main Object)
|
|-	PauliConstants (Physical Constants)
|	|-	user (struct for all user defined constants, such as atomic masses of the element used) 
|
|-	PauliData (Data loaded from Images)
|	|-	images (All images the user requested to be saved in matrix form)
|	|-	density (Cell array of density matrices)
|	|- 	xml (Cell array of extracted XML in text form)
|	|- 	user (struct for all user defined data)
|
|-	PauliParameters (Parameters defining the operation of Pauli defined by the user)
	|-	verbose (flag defining whether output is written to the console)
	|-	loopvars (loopvars used for this run in ExpControl)
	|-	files (Cell array of all filenames found in the folder)
	|-	images (Cell array of shots taken in the folder)
	|-	imagesToLoad (Cell array of shots to be loaded by Pauli)
	|-	imagesToSave (Cell array of shots the user wants to keep after calculating the density matrices) 
	|-	crop (Array with the amount of pixels to be cropped from the images in from {Left, Right, Top Bottom})
	|-	convertToDensityFunctionName (For internal use)
	|-	user (struct for all user defined parameters, such as current, non-constant info about the setup like the magnification)
`

### How is Pauli Setup
- Clone the repository to your MATLAB-Folder (or elsewhere and add it to your path)
- Type Pauli_Setup into the MATLAB console and follow the instructions on screen.
  - You will first be prompted whether you want to create a new Experiment or a new Mode. An Experiment refers to a specific Quantum Gas Machine. A Mode can be anything else - a new Camera, a different density computation method...
  - You then get to set a name for your new Experiment and Mode.
  - The setup script automatically creates all relevant files for you and opens them.
- At this stage, you should have a file open called `make_EXPERIMENTNAME_MODENAME.m` as well as one called `convertToDensity_EXPERIMENTNAME_MODENAME.m`
  - Fill in the parameters and constants you need in the `make_EXPERIMENTNAME_MODENAME.m` and run it once. This will create a `MODENAME.pauli` file, which you can later load to obtain a Pauli object with all your configuration presets.
  - Enter your Experiments prefered method to calculate a density matrix from the images loaded in the `convertToDensity_EXPERIMENTNAME_MODENAME.m`. There is an extensive comment describing how and what the parameters are. Feel free to check out other experiments methods for inspiration!
- Thats it! Pauli is ready to be used. If you want to modify your parameters, just modify the `make_EXPERIMENTNAME_MODENAME.m` and run it again.

### How is Pauli used
- Make sure Pauli is on your Matlab Path
- Type `pauli = Pauli('Experiments/EXPERIMENTNAME/MODENAME.pauli', 'PATH TO THE FOLDER WITH YOUR IMAGES');`
- You are done! Pauli will automatically load your configuration, scan the files in the folder, and load and convert all images.

### Advanced use
If you do not want to automatically load all images, but for example only a specific set:
- Type `pauli = Pauli('Experiments/EXPERIMENTNAME/MODENAME.pauli');`
- Type `pauli.autoDetect('PATH TO THE FOLDER WITH YOUR IMAGES');`
- Now, `pauli.parameters.loopvars` contains the different loopvariables detected and the values found in the folder.
- Modify the values to your wishes
- Finally, type `pauli.createDensities;` to load the images and convert them to densities and run `pauli.save;` to save the results to speed up future evaluations

