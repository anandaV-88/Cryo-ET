%% Data Organization
% Prior to generating structure of interest, if you have not, please install Dynamo-EM package on MATLAB,
% GPU availability and 3D reconstructed tomogram(s).

%% Activate Dynamo
clear;clc; % Good practice to make sure workspace is clean to avoid variable duplicates.
% Load Dynamo package: Adjust path if needed.
run C:\CoursNavarro\Dynamo\dynamo_temp_1.1.555\dynamo_activate.m

%% Create a catalogue
% Catalogue is where your tomograms and associated particle models are
% stored. Please adjust VLPtomograms.vll path here.
dcm -create myVLP -fromvll VLPtomograms.vll

%% Pre-bin the tomograms
% A good practice so Dynamo will know the scaling size of your tomograms.
% Catalogue name, binning factor, and 300 zlices at a time in XY plane.
dynamo_catalogue_bin('myVLP',1,'zchunk',300); % This should alrady been done.

%% Load tutorial path
% For most of the metadata, we'll be using the following results from
% tutorial except for a few of our STA. Here, we specify the path to the
% catalogue: Adjust if needed.
cat_Path = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\HIV_Capsid\');

%% Generate dipoleSet model: GUI
% Open one volume at a time, and generate dipole model and save into disk.
% The model will eventually be saved into myVLP catalogue we just created.

% 1 here refers to un-binned. If your data happens to be bigger than the
% tutorials, you may select 2. This will provide quicker visualization on
% Dynamo without crashes.
tomo_path = fullfile(cat_Path, 'DownloadLinkVLPs/vlp_1.mrc');
dtmslice(tomo_path, 'c', 'myVLP','prebinned',1);
% You can create one model and save to disk. However, we will proceed with the
% models that have been created for tutorials.

% So what just happened?
% When we assign C (center) and N (north) / S (south) on the widest mid
% section of the viral capsid, we are calculating the maximum sphere radius of our
% particle of interest, providing us the ability to detect particles that
% are within the specified area for further processing.

%% Load the tutorial models into our catalogue
catName = 'myVLP'; % Put our catalogue name here
% Full path to the models available from tutorial data
modelDir = 'Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\DipoleModels';

% Loop from tomo 1 to tomo 6 according to the dipoleSet model name.
for i = 1:6
    dipoleMod = fullfile(modelDir, sprintf('dipoleSet_%d.omd',i)); % Based on our model name.
    dcm('c', catName, 'i', i, 'add_model',dipoleMod); % add model to associated unique tomogram.
end

% Notice that under myVLP catalogue, we can see more models appearing.
% These are all dipoleSet models similar to what we generated.

%% Define crop points
% Load dipoleSet model of each tomogram from catalogue into workspace
dcmodels myVLP -nc dipoleSet -ws o -gm 1;

% nc : name contains, -ws: workspace output , -gm 1 (dipole)
%% Create a table from each vesicle model

% This loop function loads the dipoleSet model associated with each
% tomogram in our myVLP catalogue. For each dipole model, we create a
% vesicle model where the center and radius information are adjusted based
% on what we have assigned with C and N. Then, we created points 60A away from one another on the
% vesicle surface layer of each vesicle model.

% We then converted these vesicle models into table format where we can
% evaluate their angles, unique ID, and positions of each tomogram, and
% merge them into one dataset table to ease our averaging processes later
% on.

c = 1; % Counter for table
for tomo = 1:6 % Loop over 6 tomos
    ds = o.models{tomo};
    NDipoles = length(ds.dipoles); 
    for i=1:NDipoles % Loop over models (1 per tomogram)
        v = dmodels.vesicle(); % Create empty vesicle model
        v.center = ds.dipoles{i}.center; % Add center from dipole to vesicle
        v.radius = norm(ds.dipoles{i}.north - ds.dipoles{i}.center); % Add radius
        v.separation = 60; % Separation from crop points
        v.crop_distance_from_surface = 0;
        v.updateCrop(); % Update vesicle model

        tv{c} = v.grepTable(); % Create crop table from using vesicle model
        tv{c}(:,22) = i; % Add model unique ID to table
        tv{c}(:,20) = tomo; % Add tomogram unique ID to the table
        c=c+1;
    end
end

%% Merge and save into one variable table
% Here we use linear tags with 1 to ensure they are merged sequentially
% (linearly). This way, each particle has its own unique ID when merged.
tAll = dynamo_table_merge(tv,'linear_tags',1);

%% Evaluate merged dipoleSet models
% This is where we evaluate the metadata of our models which have been
% converted to table format.
dtinfo(tAll);

% Column 2 and 3: Number of particles in total
% Column 4 to 6: All zero. No alignment has been done yet.
% Column 7 to 9: angles reflect local geometry especially when we have
% dipole type of models.
% Column 20: List of unique tomograms. Make sure there are 6 total
% tomograms here.
%% Visualize all dipole models in one plot
% Here we visualize how each dipoleSet model looks like per tomogram. 
dtplot(tAll, 'pf', 'oriented_positions');
axis equal;

% You can also view this after you aligned the particles and see if the
% orientation changed. The points here refer to the cropped particles of
% the viral capsid surface from each model 3D, with an adjustment of
% separation parameter.

%% Create unique ID to map our model to the list of different tomograms
% Let's make sure that the points we are cropping are based on the tomogram's associated model. Assigning a .doc file creates a unique ID so that our algorithm does not crop the wrong tomogram.
% Our list of tomograms are stored here
fid_read = fopen('VLPtomograms.vll', 'r');
paths = textscan(fid_read, '%s');
fclose(fid_read);

% Assign each row with unique ID
fid = fopen('VLPtomograms.doc', 'w');
for i = 1:length(paths{1})
    fprintf(fid, '%d %s\n', i, paths{1}{i});
end
fclose(fid);

%% Crop particles: DON'T RUN THIS (FOLLOW TUTORIAL)

% We are extracting 3D subvolumes of those particles on surface
% and average the signal inside specified box size.

% Cropped particles stored in: SKIP THIS
%targetFolder = './particlesSize128';
% Using the generated table, we crop the particles with 128 box size: SKIP
% THIS
%dtcrop('VLPtomograms.doc',tAll,targetFolder,128);
%% Generate initial averages
% Load as variable
% Load generated particles
targetFolder = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\mySTA\HIV_Capsid_SP1\particlesSize128');
finalTbl = dread([targetFolder '\crop.tbl']);

%% Visualize individual particles
% Visualize in y axis: Normally it would be difficult to view our results
% here if our tomograms are not denoised. In our case, the tutorial data
% has not been denoised, so you can skip this at the moment.
dslices(targetFolder,'projy','*','t',finalTbl,'align',1,'tag',1:10:500,'labels','on');

%% Generate coarse average
% Here we average out our cropped file with 'fc' as 1. 'fc' here stands for
% fourier compensation. SKIP THIS.
%oa = daverage(targetFolder, 't', finalTbl, 'fc',1);
%% Visualze
%dview(oa.average); % SKIP THIS
dview([targetFolder '/template.em']);

%% Save
% Save initial average
%dwrite(oa.average,[targetFolder '/template.em']);

%% PART 1

%% First Alignment Project
% Variable for alignment project
pr = 'myfirst_VLP';
% Generate parameter
dcp.new(pr,'d',targetFolder,'t',[targetFolder '/crop.tbl'], 'template', ...
    [targetFolder '/template.em'],'masks','default','show',0, 'forceOverwrite', 1);

%% First Alignment: Adjust Numerical Parameters
% No. of iteration: 4. 2 for quick search. (How many times this alignment and averaging should be done?)
dvput(pr,'ite_r1',2);
% No. of particle dimension: rescale to 32. (Box size in px. for each particle)
dvput(pr,'dim_r1',32);
% No. of cone aperture: 40 (How much the particle is allowed to tilt away from its current direction?)
dvput(pr,'cr_r1',40);
% No. of cone sampling: 20 (How finely would you want to perform cone range search?)
dvput(pr,'cs_r1',20);
% No. of in-plane range (azimuth): 360 (How much particle can rotate around its own axis?)
dvput(pr,'ir_r1',360);
% No. of in-plane sampling (azimuth sampling): 40 (How finely would you want to perform in plane range search?)
dvput(pr,'is_r1',40);
% No. of refine: 4 (How many times we'd like to refine the alignment)
dvput(pr,'rf_r1',4);
% No. of refine factor (How narrow would you like to apply your refinement? The smaller the more detailed the refinement becomes)
dvput(pr,'rff_r1',2);
% shift limits (Define 3D distances where particles can move). Allow 40px
% in XYZ during alignment.
dvput(pr,'lim_r1',[40,40,40]);
% shift limiting way (How strongly particles are prevented from drifting away from their original position?)
dvput(pr,'limm_r1',1);
% Computing Env.
dvput(pr,'dst','matlab_gpu','cores',1,'mwa',2);

% *For more information regarding numerical parameter refinement, please
% follow the document shared on GitHub.

%% First Alignment: Check Numerical Parameters
dvcheck myfirst_VLP

%% First Alignment: Confirm Numerical Parameters
dvunfold myfirst_VLP

%% Submit alignment script to cluster
% On terminal, run the following and enter your password
% ssh yourusername@curnagl.dcsr.unil.ch "bash /work/FAC/FBM/DMF/pnavarr1/default/Aurelien/dynamo_submit.sh ./users/vananda/mySTA/HIV_Capsid_SP1/myfirst_VLP --test"

%% Short Quiz Session
% 1. Can we perform subvolume cropping on denoised tomogram?
% 2. Can we perform particle picking on denoised tomogram?
% 3. How important is box size adjustment in STA?

%% First Alignment: Check status of alignment
dvstatus myfirst_VLP

%% Check first alignment result
ddb myfirst_VLP:a -v % last computed average

%% First Alignment: Subboxing

% Subboxing might be necessary when we'd like to slighly re-center our
% particle of interest in our box size. Unfortunately, in some Dynamo
% programs, this function can no longer be used, so we follow tutorial
% here. 
% To recenter, we use 65,65,65 (128px) for our subvolume, and 57,64,69 as
% our subunit.
%rSubunitFromCenter = [57,64,69] - [65,65,65];

%% First Alignment: Recenter the particles
% Load the last computed table from first alignment project
%ddb myfirst_VLP:rt -ws t;

% Apply new center to the table
%ts = dynamo_subboxing_table(t,rSubunitFromCenter);

%% First Alignment: Adjust table
% Use the adjusted table to recrop the particles
%targetFolder = './particlesSize96r';

% Crop: reduce box size to 96 just to align things more closely.
%dtcrop('VLPtomograms.doc',ts,targetFolder,96);

%% Evaluate cropped particles
targetFolder = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\mySTA\HIV_Capsid_SP1\particlesSize96r');

%% First Alignment: Evaluate
% Average and visualize the re-cropped particles
%finalTbl = dread([targetFolder,'/crop.tbl']);
%oa = daverage(targetFolder, 't', finalTbl,'fc',1);
%dview(oa.average);
%% Save
%dwrite(oa.average,[targetFolder '/template.em']);
dview([targetFolder '/template.em']);

%% First Alignment: Align Symmetry Axis
% Here we create a mask to better align our averaged result. We can either
% use the following script, or on GUI through dynamo_mask();
mr = dpktomo.examples.motiveTypes.Membrane();
mr.thickness = 22;
mr.sidelength = 96;
mr.getMask();
mem  = (mr.mask)*(-1)+1;  % invert contrast
cyl = dynamo_cylinder(7,96,[48,48,48]);  % create a cylinder (this will be the 'hole')
templateSum = mem+cyl;    % sum the two masks
template = templateSum;
template(template>0) = 1; % binarize the new mask

%% First Alignment: Evaluate aligned symmetry axis
%dview(template);
%dwrite(template, 'mask_align_1_96.em');
mask_path = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\mySTA\HIV_Capsid_SP1');
dview([mask_path '\mask_align_1_96.em']);

%% First Alignment: Apply Mask Alignment
% dalign() can help us align our current average with the mask we
% generated.

% template is the customized mask
%sal = dalign(oa.average, template, 'cr',30,'cs',5,'ir',0, ...
%    'dim',48,'limm',1,'lim',[15,15,15]);

%% First Alignment: Evaluate adjusted average
%dmapview(sal.aligned_particle);
%dwrite(sal.aligned_particle, 'sal_aligned_average.em');
dmapview([mask_path '\sal_aligned_average.em']);

%% First Alignment: Save parameters
% Perform table rigid to make sure the table information of each individual
% particles are aligned based on our mask adjustment.
%tr = dynamo_table_rigid(finalTbl,sal.Tp);

%% First Alignment: Adjust Oversampling
% Exclude subvolumes that are closer than 20 px. of each other.
% Here from the adjust table above containing particle points, we excluse
% those that are too close (20px) away from another point.

% Why? So that we can minimize duplicated points.
%trEx = dpktbl.exclusionPerVolume(tr,20);

%% First Alignment: Save
%targetFolder = './particlesSize96r';
%dwrite(trEx,[targetFolder, '/crop_trEx.tbl']);
%oa = daverage(targetFolder, 't', trEx, 'fc', 1);
%dwrite(oa.average,[targetFolder '/template_trEx.em']);
dview([targetFolder '/template_trEx.em']);

%% PART 2

%% Second Alignment: Adjust Mask Refinement
% Create an alignment mask
mr = dpktomo.examples.motiveTypes.Membrane();
mr.thickness = 55;
mr.sidelength = 96;
mr.getMask();
mem_mask = mr.mask;

%% Second Alignment: Save Mask Ref.
%dwrite(mem_mask,'mem_mask_thick.em');
dview([mask_path '\mem_mask_thick.em']);

%% Second Alignment: Visualize mask overlay
dslices([targetFolder '/template_trEx.em'],'y','-ov',[mask_path '/mem_mask_thick.em'],'-ovas','mask','-ovc','r');
% We should see that our masks are quite aligned with the ROI

%% Second Alignment: Create Alignment Project
pr = 'mysecond_VLP';
dcp.new(pr,'d',targetFolder,'t',[targetFolder '/crop_trEx.tbl'],'template',[targetFolder '/template_trEx.em'], ...
    'masks','default','show',0);

%% Second Alignment: Adjust Numerical Parameters
% Add new tight alignment mask
dvput(pr, 'file_mask', [mask_path '/mem_mask_thick.em']);
%%
% Parameters Round: 1
dvput(pr,'ite_r1',2);
dvput(pr,'dim_r1',48);
dvput(pr,'cr_r1',30);
dvput(pr,'cs_r1',10);
dvput(pr,'ir_r1',30);
dvput(pr,'is_r1',10);
dvput(pr,'rf_r1',4);
dvput(pr,'rff_r1',2);
dvput(pr,'lim_r1',[15,15,15]);
dvput(pr,'limm_r1',1);
dvput(pr,'sym_r1','c6');

% Parameters Round: 2
dvput(pr,'ite_r2',1);
dvput(pr,'dim_r2',96);
dvput(pr,'cr_r2',12);
dvput(pr,'cs_r2',4);
dvput(pr,'ir_r2',12);
dvput(pr,'is_r2',4);
dvput(pr,'rf_r2',4);
dvput(pr,'rff_r2',2);
dvput(pr,'lim_r2',[5,5,5]);
dvput(pr,'limm_r2',2);
dvput(pr,'sym_r2','c6');

% Computing Env.
dvput(pr,'dst','matlab_gpu','cores',1,'mwa',2);

%% Second Alignment: Check Parameters
dvcheck mysecond_VLP

%% Second Alignment: Confirm Parameters
dvunfold mysecond_VLP

%% Submit alignment script to cluster
% On terminal, run the following and enter your password
% ssh yourusername@curnagl.dcsr.unil.ch "bash /work/FAC/FBM/DMF/pnavarr1/default/Aurelien/dynamo_submit.sh ./users/vananda/mySTA/HIV_Capsid_SP1/mysecond_VLP --test"

%% Short Quiz Session
% 1. How can dalign() with customized mask adjustment help with our
% alignment?

% 2. Can we replace numerical parameter alignment entirely with customized
% mask adjustment?

% 3. What's the difference between cone and azimuth (in-plane) range?

%% Second Alignment: Check status of alignment
dvstatus mysecond_VLP

%% Check second alignment result
ddb mysecond_VLP:a -v % last computed average
% We can view this on Dynamo mapview from the panel
%% Second Alignment: Evaluate the averages
% Evaluate the averages of all iterations from initial to the last.

% Load the last computed average
%ddb second_VLP:rt -ws t
%%
% Assign target folder to store results
%targetFolder = './particlesSize128_align_2';
%dtcrop('VLPtomograms.doc', t, targetFolder, 128);

%% Second Alignment: Re-compute average
% Average and visualize the re-cropped particles
%finalTbl = dread([targetFolder,'/crop.tbl']);
%oAfter = daverage(targetFolder, 't', finalTbl,'fc',1);
%dview(oAfter.average);

%% Second Alignment: Save Re-cropped template
%dwrite(oAfter.average,[targetFolder '/template.em']);
targetFolder = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\mySTA\HIV_Capsid_SP1\particlesSize128_align_2');
dview([targetFolder '/template.em']);

%% PART 3

%% Third Alignment: Adjust Mask Refinement
% Create an alignment mask
mr = dpktomo.examples.motiveTypes.Membrane();
mr.thickness = 40;
mr.sidelength = 128;
mr.getMask();
mem_mask = mr.mask;

%% Third Alignment: Save Mask Ref.
%dwrite(mem_mask,'mem_mask_thick_128.em');
dview([mask_path '/mem_mask_thick_128.em']);

%% Third Alignment: Visualize mask overlay
dslices([targetFolder '/template.em'],'x','-ov',[mask_path '/mem_mask_thick_128.em'],'-ovas','mask','-ovc','r');
% We should see that our masks are quite aligned with the ROI

%% Third Alignment: Create Alignment Project
pr = 'mythird_VLP';
dcp.new(pr,'d',targetFolder,'t',[targetFolder '/crop.tbl'],'template',[targetFolder '/template.em'],'masks','default','show',0, ...
    'forceOverwrite',1);

%% Second Alignment: Adjust Numerical Parameters
% Add new tight alignment mask
dvput(pr, 'file_mask', [mask_path '/mem_mask_thick_128.em']);
%%
% Parameters Round: 1
dvput(pr,'ite_r1',1);
dvput(pr,'cr_r1',20);
dvput(pr,'cs_r1',5);
dvput(pr,'ir_r1',20);
dvput(pr,'is_r1',5);
dvput(pr,'rf_r1',5);
dvput(pr,'rff_r1',2);
dvput(pr,'high_r1',2);
dvput(pr,'low_r1',23);
dvput(pr,'sym_r1','c6');
dvput(pr,'dim_r1',64);
dvput(pr,'lim_r1',[10 10 10]);
dvput(pr,'limm_r1',1);
dvput(pr,'sep_r1',0);
dvput(pr,'rm_r1',0);
dvput(pr,'thr_r1',0.20);
dvput(pr,'thrmod_r1',0);

% Parameters Round: 2
dvput(pr,'ite_r2',1);
dvput(pr,'cr_r2',10);
dvput(pr,'cs_r2',3);
dvput(pr,'ir_r2',10);
dvput(pr,'is_r2',3);
dvput(pr,'rf_r2',5);
dvput(pr,'rff_r2',2);
dvput(pr,'high_r2',2);
dvput(pr,'low_r2',23);
dvput(pr,'sym_r2','c6');
dvput(pr,'dim_r2',128);
dvput(pr,'lim_r2',[5 5 5]);
dvput(pr,'limm_r2',2);
dvput(pr,'sep_r2',0);
dvput(pr,'rm_r2',0);
dvput(pr,'thr_r2',0.20);
dvput(pr,'thrmod_r2',0);

% Computing Env.
dvput(pr,'dst','matlab_gpu','cores',1,'mwa',2);

%% Third Alignment: Check Parameters
dvcheck mythird_VLP

%% Third Alignment: Confirm Parameters
dvunfold mythird_VLP

%% Submit alignment script to cluster
% On terminal, run the following and enter your password
% ssh yourusername@curnagl.dcsr.unil.ch "bash /work/FAC/FBM/DMF/pnavarr1/default/Aurelien/dynamo_submit.sh ./users/vananda/mySTA/HIV_Capsid_SP1/mythird_VLP --test"

%% Short Quiz Session
% 1. How do you choose a proper box size?
% 2. From your current understanding, what makes STA different than SPA?
% 3. How can STA answer and/or support your structural biology research?

%% Third Alignment: Check status of alignment
dvstatus mythird_VLP

%% To visualize
% Connect and activate our Chimera
dynamo_chimera -path 'C:\Program Files\Chimera 1.19\bin\chimera.exe'
%% Check first alignment result
ddb mythird_VLP:a -v % last computed average

%% Create a cropping mask
dynamo_mask()

%% Third Alignment: Visualize mask overlay
crop_mask = dread('tube_map_masked.em');
inv_mask = -crop_mask;
dview(inv_mask)
% dview([mask_path, '/tube_map_masked.em']);
%% Third Alignment: Save
%dwrite(inv_mask,'inv_tube_mask_128.em');
dview([mask_path, '/inv_tube_mask_128.em']);
%% Third Alignment: Apply Cropped Mask Alignment
% Here, we no longer adjust the numerical parameters because our previous
% computed average from third alignment was alredy decent.
sal = dalign('temp.em', [mask_path, '/inv_tube_mask_128.em'], 'cr',0,'cs',0,'ir',0, ...
    'dim',128,'limm',1, 'lim',[0,0,0]);

%% Third Alignment: Evaluate adjusted average
dmapview(sal.aligned_particle);
%dwrite(sal.aligned_particle, 'sal_aligned_average_final.em');
