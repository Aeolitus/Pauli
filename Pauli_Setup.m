function Pauli_Setup()
% This script will create a new experiment or camera. It will guide the
% user through the entire process, so that nothing has to be done by hand. 

disp('Welcome to Pauli!');
disp( ['This Wizard will guide you through creating a new Experiment ' ...
    'or setting up a new evaluation Mode.']);

flag = true;
exp = false;
mode = false;
while(flag)
    resp = input('Do you wish to set up a new Experiment (E) or a new Mode (M)? ', 's');
    switch lower(resp)
        case 'e'
            exp = true;
            mode = true;
            flag = false;
        case 'm'
            mode = true;
            flag = false;
        otherwise
            disp('Invalid Input. Please try again.');
    end
end

flag = true;
if exp
    disp('How would you like to name your experiment?');
    disp('A good practice is something like Place_Element, e.g. HH_Li6.');
    disp('It should be easy to recognize.');
    while flag
        flag = false;
        resp = input('Name of the new Experiment: ', 's');
        if length(resp) < 3
            disp('Please choose a longer, telling name!');
            flag = true;
        end
        if exist(fullfile('Experiments', resp), 'file') == 7
            disp('That name is already chosen. Please choose another!');
            flag = true;
        end
    end
    mkdir(fullfile('Experiments', resp));
    expName = resp;
else
    disp('For which experiment would you like to create a new mode?');
    while flag
        flag = false;
        resp = input('Name of the Experiment: ', 's');
        if ~exist(fullfile('Experiments', resp), 'file') == 7
            disp('That experiment does not exist yet. Chose another!');
            flag = true;
        else
            expName = resp;
        end
    end
end

flag = true;
if mode
    disp('How would you like to name the new mode?');
    while flag
        flag = false;
        resp = input('Name of the new Mode: ', 's');
        if length(resp) < 2
            disp('Please choose a longer, telling name!');
            flag = true;
        end
        if exist(fullfile('Experiments', expName, [resp '.pauli']), 'file') == 2
            disp('A mode with that name already exists. Please choose a different one!');
            flag = true;
        end
    end
    modeName = resp;
end

% Make Files
fid = fopen(fullfile('Experiments', 'Templates', 'make_Pauliobject.m'),'r');
i = 1;
tline = fgetl(fid);
if ischar(tline)
    tline = strrep(tline, 'convertToDensMethodName', ['convertToDensity_' expName '_' modeName]);
    tline = strrep(tline, 'saveConfigPath', fullfile('Experiments', expName, modeName));
    tline = strrep(tline, 'make_Pauliobject', ['make_' expName '_' modeName]);
end
A = {};
A{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    if ischar(tline)
        tline= strrep(tline, 'convertToDensMethodName', ['convertToDensity_' expName '_' modeName]);
        tline = strrep(tline, 'saveConfigPath', fullfile('Experiments', expName, modeName));
        tline = strrep(tline, 'make_Pauliobject', ['make_' expName '_' modeName]);
    end
    A{i} = tline;
end
fclose(fid);
fid = fopen(fullfile('Experiments', expName, ['make_' expName '_' modeName '.m']), 'w');
for i = 1:numel(A)
    if A{i+1} == -1
        fprintf(fid,'%s', A{i});
        break
    else
        fprintf(fid,'%s', A{i});
        fprintf(fid,'\n');
    end
end

fid = fopen(fullfile('Experiments', 'Templates', 'convertToDensity_Template.m'),'r');
i = 1;
tline = fgetl(fid);
if ischar(tline)
    tline = strrep(tline, 'convertToDensity_Template', ['convertToDensity_' expName '_' modeName]);
end
A = {};
A{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    if ischar(tline)
        tline= strrep(tline, 'convertToDensity_Template', ['convertToDensity_' expName '_' modeName]);
    end
    A{i} = tline;
end
fclose(fid);
fid = fopen(fullfile('Experiments', expName, ['convertToDensity_' expName '_' modeName '.m']), 'w');
for i = 1:numel(A)
    if A{i+1} == -1
        fprintf(fid,'%s', A{i});
        break
    else
        fprintf(fid,'%s', A{i});
        fprintf(fid,'\n');
    end
end

message = sprintf(['You are done! \n'...
    'I created a script to initialize your Pauli object for you. This script is ' ...
    'saved as Experiments/' expName '/make_' expName '_' modeName '.m and' ...
    'opens for you afterwards. Please add in all the values you wish to have '...
    'available when running Pauli. Dont forget to set preferences such as the '...
    'names of the images to save and all the physical properties of your element '...
    'so you can use them later. When you are done, please run the script once ' ...
    'to save a config file with your settings that you can use from now on. ' ...
    'When you want to modify any values, just edit that script and run it again. \n\n' ...
    'I furthermore created a function called ' '"convertToDensity_' expName '_' ...
    modeName '.m" ' 'for you. In it, you will need to define how for your experiment' ...
    'and this mode, a density is computed from the images saved by CameraControl.' ...
    'It has an extensive comment describing how it is used and will open automatically '...
    'afterwards. Dont forget to save your changes! \n\nThat should be it! Now, your '...
    'configuration script and the ' ...
    'convertToDensity function will be opened. Feel free to commit your files ' ...
    'to the github repository so other people in your lab can benefit from your work!']);
uiwait(msgbox(message, 'Success!'));


edit(fullfile('Experiments', expName, ['convertToDensity_' expName '_' modeName '.m']));
edit(fullfile('Experiments', expName, ['make_' expName '_' modeName '.m']));
