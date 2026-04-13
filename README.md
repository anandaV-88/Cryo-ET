
# Cryo-ET: Subtomogram Averaging (STA)
**Determining macromolecular complexes in their native environment**<br>
#### Affiliation: Navarro Lab, Department of Fundamental Microbiology, Faculty of Biology and Medicine, University of Lausanne
---
 
**Subtomogram averaging (STA)** is one of the main structural biology techniques used to obtain structure of macromolecular complexes *in situ*. Unlike **Single Particle Analysis (SPA)** where structure is obtained from purified states, STA allows researchers to evaluate structural conformations in cellular context where those particles sit in space.


**Structure of Interest** <br>
In this tutorial, we will be visualizing an **HIV-1 capsid-SP1** (shown below) derived from tomography data. While the high-resolution STA structure (3.9 A) of this has been published here [**EMD-4015**](https://www.ebi.ac.uk/emdb/EMD-4015?tab=overview), this walkthrough provides an introductory session how we can obtain lower-resolution version of it. <br>


<img  src="https://github.com/user-attachments/assets/aa78864e-44e3-4d8e-951b-1f4113a55de5" width = "450" /> <img src="https://github.com/user-attachments/assets/ca97b18e-dc12-48dc-9691-a3efd53b44b9" width = "380"/>

**Data Requirement** <br>
- Tutorial data<br>

**Reminder: If you are part of UNIL MLS program, tutorial metadata and dependencies will be shared with you during class.** <br>

**Installation and Dependencies** <br>
- [MATLAB Dynamo-EM](https://drive.google.com/file/d/1x5he7ctkC4BUCNFhfXLk6heggGohELoM/view?usp=sharing)
- [UCSF ChimeraX](https://www.cgl.ucsf.edu/chimera/download.html)
- GPUs <br>
  Use your organization/institution GPU clusters. <br>
- Sufficient memory (~38GB RAM) <br>
  STA will require sufficient RAM memory to process images. Using tutorial data should not be an issue at the moment. Contact your local IT support if you encounter memory issue.


#### Organize Data
To run the script, make sure you create your working directory as shown below. <br>
```
mySTA/
├── HIV_Capsid_SP1/
│   ├── STA4Students.m
│   ├── VLPtomograms.vll
```
Open the **STA.m** or **STA4Students.m** script and adjust with your data. On MATLAB, your variables can be viewed under **Workspace** while your command output can be viewed under **Command Windows**. <br>

#### Setting up working environment
In this section, we will setup our main catalogue and associated tomograms that we have. **Catalogue** on Dynamo-EM is a management directory where our tomograms (including the different scaling sizes) and particle models will be stored. Creating a catalogue helps the package to organize the metadata in order. <br>
```
%% Data Organization
% Prior to generating structure of interest, please install Dynamo-EM package on MATLAB,
% GPU availability and 3D reconstructed tomogram(s).

%% Activate Dynamo
clear;clc; % Good practice to make sure workspace is clean to avoid variable duplicates.
% Load Dynamo package: Adjust path if needed.
run C:\CoursNavarro\Dynamo\dynamo_temp_1.1.555\dynamo_activate.m
```

A text file called VLPtomograms.vll contains the full path to tomograms that will be used. In this case, please use the already generated .vll by adjusting the full paths inside. You can open the .vll on MATLAB by right-click and open as text. <br>
```
%% Create a catalogue
% Catalogue is where your tomograms and associated particle models are
% stored. Please adjust VLPtomograms.vll path here.
dcm -create myVLP -fromvll VLPtomograms.vll
```

#### Setting up tomograms

Here you may adjust the scale size of your original tomogram. Since tutorial data may already been binned, we can proceed by using the default with "1". The 'zchunk' refers to how many Z slices chunk can the algorithm process this binning. This method helps minimize excessive computing overload.
```
%% Confirm the tomograms scale size
dynamo_catalogue_bin('myVLP',1,'zchunk',300);
```
If your own tomogram is at its highest resolution, it would be wise to switch the bin size to "2" so that it will be faster for you to visualize your model on Dynamo GUI. It is highly advised to follow this step even if you are not binning your tomogram. The *dynamo_catalogue_bin* helps Dynamo to confirm your tomogram scale size along the way.<br>

**How can we specify box size value?** <br>
Similar to Single Particle Analysis (SPA), STA follows the same box size rules which you can refer ([here](https://blake.bcm.edu/emanwiki/doku.php?id=eman2:boxsize)).

#### Generating model: Dynamo-GUI
To perform particle selection, we always use GUI to make sure we can visualize what we are collecting. Always use tomograms where scaling have been adjusted to avoid memory complications. Here, we will generate a model based on **dipoleSet**. Particularly for this viral capsid, the dipoleSet model will allow us to: <br>

**- Manually label capsid center and pole (north and/or south) per capsid model.** <br>

**- Measure the distance between the 2 points you labeled (e.g., center and north/south)**. <br>

```
%% Load tutorial path
% For most of the metadata, we'll be using the following results from
% tutorial except for a few of our STA. Here, we specify the path to the
% catalogue: Adjust if needed.
cat_Path = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\HIV_Capsid\');
```

Theoretically, if you point labels are accurate on the tomogram, you would obtain a sphere. However, if your labeling is off, you'd create either oversized or undersized sphere per viral capsid. <br>

*We already prepare models for you in case your labels are off, so you do not have to collect each model from all the tomograms. You may follow the steps below to get an overview how collecting model works.*

```
%% Generate dipoleSet model: GUI
% Open one volume at a time, and generate dipole model and save into disk.
% The model will eventually be saved into myVLP catalogue we just created.

% 1 here refers to un-binned. If your data happens to be bigger than the
% tutorials, you may select 2. This will provide quicker visualization on
% Dynamo without crashes.
tomo_path = fullfile(cat_Path, 'DownloadLinkVLPs/vlp_1.mrc');
dtmslice(tomo_path, 'c', 'myVLP','prebinned',1);

```
 You can create one model and save to disk. However, we will proceed with the models that have been created for tutorials. <br>

Once the GUI opens up, adjust the threshold of the tomogram by selecting the icon on the top panel shown below and start creating dipoleSet model wherever you see the viral capsid. Dynamo built-in function will automatically calculate the sphere as shown below:<br>
To label *center* and *north* of your capsid, use your keyboard and press **C** in the center and **N** on the north edge of the capsid. <br>

<p align="center">
  <img src="https://github.com/user-attachments/assets/6e3c7e49-9fb8-44ca-acb2-9e0f077b2755" width="800"><br>
  <em>Tomoslice adjustment</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/4f20db3f-a0e0-4766-9095-c0d87ca66107" width="800"><br>
  <em>Create dipole model</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/cb7987b6-9e8f-447f-b7bd-26b7e5e6e825" width="800"><br>
  <em>Evaluate and save model</em>
</p>
<br>

#### So what just happened?
When we assign C (center) and N (north) / S (south) on the widest mid section of the viral capsid, we are calculating the maximum sphere radius of our particle of interest, providing us the ability to detect particles that are within the specified area for further processing.

#### Importing existing models to current myVLP catalogue

```
%% Load the tutorial models into our catalogue
catName = 'myVLP'; % Put our catalogue name here
% Full path to the models available from tutorial data. Adjust if needed.
modelDir = 'Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\DipoleModels';

% Loop from tomo 1 to tomo 6 according to the dipoleSet model name.
for i = 1:6
    dipoleMod = fullfile(modelDir, sprintf('dipoleSet_%d.omd',i)); % Based on our model name.
    dcm('c', catName, 'i', i, 'add_model',dipoleMod); % add model to associated unique tomogram.
end

% Notice that under myVLP catalogue, we can see more models appearing.
% These are all dipoleSet models similar to what we generated.
```

#### Extract dipole models across tomograms

Now that we already have our models representing where our viral capsids are across tomograms, we then proceeds to extracting surface particles. Unfortunately, the dipoleSet models do not indicate we have point particles yet, so we need to create another model with **vesicle** feature as a model and generate discrete point particles found on surface layer of our viral capsids. Below is an example of how we can create a **vesicle** model (this feature has already been given by Dynamo) with parameters we have labeled previously. <br>

```
%% Define crop points
% Load dipoleSet model of each tomogram from catalogue into workspace
dcmodels myVLP -nc dipoleSet -ws o -gm 1;

% nc : name contains, -ws: workspace output , -gm 1 (dipole)
%% Create a table from each vesicle model
```

The following loop function loads the dipoleSet model associated with each tomogram in our myVLP catalogue. For each dipole model, we create a  vesicle model where the center and radius information are adjusted based  on what we have assigned with C and N. Then, we created points 60A away from one another on the vesicle surface layer of each vesicle model. We then converted these vesicle models into table format where we can evaluate their angles, unique ID, and positions of each tomogram, and  merge them into one dataset table to ease our averaging processes later on.<br>

```
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
```

```
%% Merge and save into one variable table
% Here we use linear tags with 1 to ensure they are merged sequentially
% (linearly). This way, each particle has its own unique ID when merged.
tAll = dynamo_table_merge(tv,'linear_tags',1);
```

##### Evaluate merged dipoleSet models

```
% This is where we evaluate the metadata of our models which have been
% converted to table format.
dtinfo(tAll);
```

- Column 2 and 3: Number of particles in total
- Column 4 to 6: All zero. No alignment has been done yet.
- Column 7 to 9: angles reflect local geometry especially when we have dipole type of models.
- Column 20: List of unique tomograms. Make sure there are 6 total tomograms here.

```
%% Visualize all dipole models in one plot
% Here we visualize how each dipoleSet model looks like per tomogram. 
dtplot(tAll, 'pf', 'oriented_positions');
axis equal;

% You can also view this after you aligned the particles and see if the
% orientation changed. The points here refer to the cropped particles of
% the viral capsid surface from each model 3D, with an adjustment of
% separation parameter.
```

<p align="center">
  <img src="https://github.com/user-attachments/assets/91a5602a-152e-4c08-8b14-0be0c6717359" width = "400"/> 
 <img src="https://github.com/user-attachments/assets/fbf472e3-a5b5-47c7-8bd3-38b4b7170a08" width = "400" /> <br>

  <em>Compilation of all of our dipoleSet models derived from tutorial data.</em>
</p>
<br>
The images shown above show how our dipoleSet models generate sphere-like for the each capsid we labeled in 3D. Notice that the point coordinates are assigned on the surface of each model which we will extract those areas to capture the capsid surface layer.<br>

#### Create unique ID to map our model to the list of different tomograms
```
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
```

#### Subtomograms Extractions (NO NEED TO RUN THIS. WE WILL LOAD THE ALREADY CROPPED PARTICLESFROM TUTORIAL HERE.)
Once we assigned unique ID between tomograms and we can proceed to the critical part, to generate **subtomograms** (or **subparticles**). To do this, we crop our particle points into specified box size. In our case, we will crop the points present on the surface layer of the capsid and set a **box size of 128px** to crop each particle area. <br>

```
%% Crop particles: DON'T RUN THIS (FOLLOW TUTORIAL)

% We are extracting 3D subvolumes of those particles on surface
% and average the signal inside specified box size.

% Cropped particles stored in: SKIP THIS
%targetFolder = './particlesSize128';
% Using the generated table, we crop the particles with 128 box size: SKIP
% THIS
%dtcrop('VLPtomograms.doc',tAll,targetFolder,128);
```
**What happened there?** <br>
From the surface layer particles we generated per capsid, we assign a **box** to contain each particle with a size of **128vx**. Assigning a proper **box size** is necessary to capture our particles of interest. There is no standard box size for all particles, so you would have to manually measure on Dynamo's GUI, and evaluate which one works best as you align and average. In our case, **128** is set as our baseline boxsize, we can always reduce the size along the way if it helps clarify our particles. <br>

Activating fourier compensation during averaging so that the intensity signals for each particle that were affected my missing wedge gets averaged properly. The output of **daverage()** will contain several metadata. We normally evaluate the *.average* result to evaluate. <br>

#### Subtomograms Coarse Averaging

```
% Load as variable
% Load generated particles
targetFolder = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\mySTA\HIV_Capsid_SP1\particlesSize128');
finalTbl = dread([targetFolder '\crop.tbl']);
```

```
%% Visualize individual particles
% Visualize in y axis: Normally it would be difficult to view our results
% here if our tomograms are not denoised. In our case, the tutorial data
% has not been denoised, so you can skip this at the moment.
dslices(targetFolder,'projy','*','t',finalTbl,'align',1,'tag',1:10:500,'labels','on');
```

```
%% Generate coarse average
% Here we average out our cropped file with 'fc' as 1. 'fc' here stands for
% fourier compensation. SKIP THIS.
%oa = daverage(targetFolder, 't', finalTbl, 'fc',1);
%% Visualze
%dview(oa.average); % SKIP THIS
dview([targetFolder '/template.em']);
```

<p align="center"> 
 <img src="https://github.com/user-attachments/assets/a8c383bf-cc7d-4f0e-a26e-f5b4342f3abd" width = "300" />
 <img src="https://github.com/user-attachments/assets/95b8d05b-906f-41b4-a2ac-696fb74359fc" width = "300"/>
 <img src="https://github.com/user-attachments/assets/c710bfb1-ebb0-45a4-9d64-c4cd8e4dcadf" width = "300"/> <br>
  <em>Coarse average prior to any alignment in X,Y,Z.</em>
</p>
<br>

**Can you see describe anything from here?** <br>

```
%% Save
% Save initial average
%dwrite(oa.average,[targetFolder '/template.em']);
```
Since this is merely coarse average done before any alignment, we cannot see distinguish any feature just yet, but we can see a rough feature of curvature on X/Y depicting outer surface layer of the capsid. We will save this as our initial template to guide the alignment. <br>

### Subtomograms Alignment
The alignment is one of the most critical steps in STA because this alignment project is how we will be rotating and spinning each particle in our subtomograms to one aligned state. We should always perform project alignment before performing any other customized alignment due to our limited understanding of the current particles at hand. <br>

### First Alignment Project

```
%% First Alignment Project
% Variable for alignment project
pr = 'myfirst_VLP';
% Generate parameter
dcp.new(pr,'d',targetFolder,'t',[targetFolder '/crop.tbl'], 'template', ...
    [targetFolder '/template.em'],'masks','default','show',0, 'forceOverwrite', 1);
```
Next, we determine our **numerical parameters**, which refers to the rotations, angles, and shifting fine tuning so that our particles are aligned. This step is one of the most cumbersome methods because there is no definitive parameters for every structure. This means you must perform this on 1 structure state at a time from your selected particle model. In our case, we will perform 2-3 alignment projects for all the VLP capsid dipoleSet models at once. <br>

For more information on the command lines, you can refer on ('[Dynamo_Command_Info.pdf](https://github.com/anandaV-88/Cryo-ET/blob/main/Dynamo_Command_Info.pdf)').

```
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
% No. of refine: 4 (How many times we'd like to refine the alignment?)
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
```

**Check if our metadata are compatible before proceeding** <br>
```
%% First Alignment: Check Numerical Parameters
dvcheck myfirst_VLP
```

**Unfold our metadata and alignment parameters** <br>
```
%% First Alignment: Confirm Numerical Parameters
dvunfold myfirst_VLP
```

**Run alignment project** <br>
```
%% Submit alignment script to cluster
% On terminal, run the following and enter your password
% ssh yourusername@curnagl.dcsr.unil.ch "bash /work/FAC/FBM/DMF/pnavarr1/default/Aurelien/dynamo_submit.sh ./users/your_username/mySTA/HIV_Capsid_SP1/myfirst_VLP --test"
```

1. Log in to your curnagl and check if your project is running on GPU cluster. <br>

#### Short Quiz Session
**1. Can we perform subvolume cropping on denoised tomogram?**<br>
**2. Can we perform particle picking on denoised tomogram?**<br>
**3. How important is box size adjustment in STA?** <br>

```
%% Check first alignment result
ddb myfirst_VLP:a -v % last computed average
```
<p align="center"> 
 <img src="https://github.com/user-attachments/assets/7cb3d211-2e55-4d5c-bfaa-ca4a082e6163" width="300"/>
 <img src="https://github.com/user-attachments/assets/46fbc2f7-22e4-46f7-a32b-b5aa989ec1b2" width="300"/>
 <img src="https://github.com/user-attachments/assets/5a3d0163-c91a-4a18-86c2-d4d93810e5a4" width="300"/><br>
  <em>Last computed average after alignment in **myfirst_vlp**.</em>
</p>
<br>

Notice that we are now able to evaluate some feature after the first alignment. However, to further maximize our structure of interest, we can perform **subboxing**. This function allows us to reposition our particle of interest to the center of the box. Depending on how well your alignment project goes, in this case we see a slight shift of the particle based on the last computed average from **myfirst_vlp**. To do this, we follow the method below:<br>

**First Alignment with Customization: Subboxing** <br>

Subboxing might be necessary when we'd like to slighly re-center our particle of interest in our box size. Unfortunately, in some Dynamo programs, this function can no longer be used, so we follow tutorial here. <br>

```
% To recenter, we use 65,65,65 (128px) for our subvolume, and 57,64,69 as
% our subunit.
%rSubunitFromCenter = [57,64,69] - [65,65,65];

%% First Alignment: Recenter the particles
% Load the last computed table from first alignment project
%ddb myfirst_VLP:rt -ws t;

% Apply new center to the table
%ts = dynamo_subboxing_table(t,rSubunitFromCenter);
```

**center of subunits** - **center of subvolume** <br>

**C** : Center of subvolume <br>
**N**: Center of subunit <br>
As shown below, you can adjust our last computed average from **myfirst_vlp** based on the center of box (subvolume) and our particle of interest (center of subunit). You can use your mouse and left click for **C** and right click for **N** positions. On the **Click** panel, you can see the different positional coordinates.  <br>
![subboxing_balance](https://github.com/user-attachments/assets/2db019a3-337e-479f-8d67-341064ef0a85) 
<img src="https://github.com/user-attachments/assets/cb6101bb-24bf-40ab-9642-7a5ae55ecef8" width = "800"/>

To further align our particles, we crop our box size smaller to easily evaluate our alignment. Below we use box size of 96: <br>

```
%% First Alignment: Adjust table
% Use the adjusted table to recrop the particles
%targetFolder = './particlesSize96r';

% Crop: reduce box size to 96 just to align things more closely.
%dtcrop('VLPtomograms.doc',ts,targetFolder,96);

```
Now we average the adjusted crop made on the last computed average with subboxing parameters: <br>

```
%% Evaluate cropped particles from tutorial data
targetFolder = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\mySTA\HIV_Capsid_SP1\particlesSize96r');

%% First Alignment: Evaluate
% Average and visualize the re-cropped particles
%finalTbl = dread([targetFolder,'/crop.tbl']);
%oa = daverage(targetFolder, 't', finalTbl,'fc',1);
%dview(oa.average);
%% Save
%dwrite(oa.average,[targetFolder '/template.em']);
dview([targetFolder '/template.em']);
```

<p align="center"> 
<img src="https://github.com/user-attachments/assets/7853b987-3e56-4131-88ad-a545bcd8c8ab" width = "300" />
<img src="https://github.com/user-attachments/assets/8c2ffc0e-625d-4dbc-bd51-84564c58f63e" width = "300"/>
<img src="https://github.com/user-attachments/assets/e8601842-e5c7-4fb1-bdc9-84346eca397d" width = "300"/> <br>
  <em>Last computed average after alignment in **myfirst_vlp**.</em>
</p>
<br>

Do you notice anything? If the surface in X and Y are too low or too high, we can re-adjust with a mask for a tighter adjustment. <br>

#### Alignment with customized mask
In this section, we generate a mask to adjust the height of the our particle of interest. <br>

```
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
```

```
%% First Alignment: Evaluate aligned symmetry axis
%dview(template);
%dwrite(template, 'mask_align_1_96.em');
mask_path = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\mySTA\HIV_Capsid_SP1');
dview([mask_path '\mask_align_1_96.em']);
```

<p align="center"> 
<img src="https://github.com/user-attachments/assets/b9d3a2e3-f363-4e80-82c1-1fa9b1a6d0b1" width = "300" />
<img src="https://github.com/user-attachments/assets/58693ff6-9db0-40e4-8c40-409da9d4ca99" width = "300" />
<img src="https://github.com/user-attachments/assets/cda95baf-b741-4e61-bf21-4054ec7abbb2" width = "300" /><br>
  <em>Customized mask to re-center of last computed average.</em>
</p>
<br>

```
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
```

```
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
```

```
%% First Alignment: Save
%targetFolder = './particlesSize96r';
%dwrite(trEx,[targetFolder, '/crop_trEx.tbl']);
%oa = daverage(targetFolder, 't', trEx, 'fc', 1);
%dwrite(oa.average,[targetFolder '/template_trEx.em']);
dview([targetFolder '/template_trEx.em']);
```

<p align="center"> 
<img src="https://github.com/user-attachments/assets/6b338d63-2888-4fed-8b55-f0f99d4412fe" width = "300"/>
<img src="https://github.com/user-attachments/assets/6010ef2a-d62f-4c3c-b9df-24be3337f9d9" width = "300"/>
<img src="https://github.com/user-attachments/assets/68254f2f-219c-4184-a355-4834be68b258" width = "300"/><br>
    <em>Last computed average after mask adjustment.</em>
</p>
<br>
Notice that the Z is now more re-centered than in previous average.<br>

### Second Alignment Project

#### Prepare tigher mask for alignment procedure
```
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
```
<p align="center"> 
<img src="https://github.com/user-attachments/assets/c3168e10-c31f-47fd-8754-d94d3afefbf6" width = "300"/>
<img src="https://github.com/user-attachments/assets/73e68ab3-af02-431a-addc-c2b2cc3f4bfd" width = "300"/>
<img src="https://github.com/user-attachments/assets/07341652-a413-4ac0-8016-af6ee1bd1646" width = "300"/><br>
    <em>A refinement mask generated.</em>
</p>
<br>

```
%% Second Alignment: Visualize mask overlay
dslices([targetFolder '/template_trEx.em'],'y','-ov',[mask_path '/mem_mask_thick.em'],'-ovas','mask','-ovc','r');
% We should see that our masks are quite aligned with the ROI
```

In the previous run, we aligned the last computed average from **myfirst_VLP** alignment project with subboxing and customized masks. The result of the adjusted average will now be used as a better template to further align our subvolumes (subtomograms). Notice how we improved the first template to the mask adjustment one? <br>

To run the second alignment project, we use the following commands: <br>

#### Second Alignment Project: Setting up

```
%% Second Alignment: Create Alignment Project
pr = 'mysecond_VLP';
dcp.new(pr,'d',targetFolder,'t',[targetFolder '/crop_trEx.tbl'],'template',[targetFolder '/template_trEx.em'], ...
    'masks','default','show',0);
```

```
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
```

```
%% Second Alignment: Check Parameters
dvcheck mysecond_VLP
```

```
%% Second Alignment: Confirm Parameters
dvunfold mysecond_VLP
```

%% Submit alignment script to cluster
% On terminal, run the following and enter your password
% ssh yourusername@curnagl.dcsr.unil.ch "bash /work/FAC/FBM/DMF/pnavarr1/default/Aurelien/dynamo_submit.sh ./users/yourusername/mySTA/HIV_Capsid_SP1/mysecond_VLP --test"

%% Short Quiz Session
% 1. How can dalign() with customized mask adjustment help with our
% alignment?

% 2. Can we replace numerical parameter alignment entirely with customized
% mask adjustment?

% 3. What's the difference between cone and azimuth (in-plane) range?

Once completed, we can evaluate the last computed average from **mysecond_VLP**. <br>

```
%% Second Alignment: Check status of alignment
dvstatus mysecond_VLP
```

```
%% Check second alignment result
ddb mysecond_VLP:a -v % last computed average
% We can view this on Dynamo mapview from the panel
```

<p align="center"> 
<img src="https://github.com/user-attachments/assets/3715d310-2d25-481a-ba3f-9757317c5369" width = "300"/>
<img src="https://github.com/user-attachments/assets/53a5fb56-c765-474f-92ae-adda95226b4b" width = "300"/>
<img src="https://github.com/user-attachments/assets/eacac421-3f84-4564-aad3-05d00ec61441" width = "300"/>
    <em>Last computed average from **mysecond_VLP**.</em>
</p>
<br>

The last computed average from **mysecond_VLP** is now interpretable! Unfortunately, we must go back to the original size of **128px** to fully visualize them. We don't need intensive alignment on our third project, so we will perform light alignment with higher cropping size. <br>
```
% Load the last computed average
%ddb second_VLP:rt -ws t

% Assign target folder to store results
%targetFolder = './particlesSize128_align_2';
%dtcrop('VLPtomograms.doc', t, targetFolder, 128);
```


#### Second Alignment: Re-compute average

```
% Average and visualize the re-cropped particles
%finalTbl = dread([targetFolder,'/crop.tbl']);
%oAfter = daverage(targetFolder, 't', finalTbl,'fc',1);
%dview(oAfter.average);

%% Second Alignment: Save Re-cropped template
%dwrite(oAfter.average,[targetFolder '/template.em']);
targetFolder = fullfile('Z:\TRAINING\UNIL\FBM\pnavarr1\navarro_teaching\Dynamo_STA_data\mySTA\HIV_Capsid_SP1\particlesSize128_align_2');
dview([targetFolder '/template.em']);
```

<p align="center"> 
<img src="https://github.com/user-attachments/assets/97ea6c7f-535a-40a2-b2fa-56d13c607023" width = "300"/>
<img src="https://github.com/user-attachments/assets/51e9170a-089a-4624-8040-54468fd3bfee" width = "300"/>
<img src="https://github.com/user-attachments/assets/1153805e-66c0-42ba-b427-5fd08e522ef1" width = "300"/><br>
    <em> 128 box size template.</em>
</p>
<br>
Notice that here we can get a larger overview of the capsid. We can then use this for our third alignment project as a template. <br>


### Third Alignment Project

#### Prepare tighter mask for third alignment project

```
% Create an alignment mask
mr = dpktomo.examples.motiveTypes.Membrane();
mr.thickness = 40;
mr.sidelength = 128;
mr.getMask();
mem_mask = mr.mask;
```

```
%% Third Alignment: Save Mask Ref.
%dwrite(mem_mask,'mem_mask_thick_128.em');
dview([mask_path '/mem_mask_thick_128.em']);
```

<p align="center"> 
<img src="https://github.com/user-attachments/assets/c9302afa-6a29-4a49-a31a-de257dc8f816" width = "300" />
<img src="https://github.com/user-attachments/assets/db7fa240-02ca-4347-9b94-7db10fbf7120" width = "300"/>
<img src="https://github.com/user-attachments/assets/af18877b-ba8f-4d3a-89eb-25cb07b00062" width = "300"/> <br>
    <em> 128 box size mask.</em>
</p>
<br>

```
%% Third Alignment: Visualize mask overlay
dslices([targetFolder '/template.em'],'x','-ov',[mask_path '/mem_mask_thick_128.em'],'-ovas','mask','-ovc','r');
% We should see that our masks are quite aligned with the ROI
```

#### Third Alignment Project: Setting up

```
%% Third Alignment: Create Alignment Project
pr = 'mythird_VLP';
dcp.new(pr,'d',targetFolder,'t',[targetFolder '/crop.tbl'],'template',[targetFolder '/template.em'],'masks','default','show',0, ...
    'forceOverwrite',1);
```

#### Third Alignment: Adjust Numerical Parameters

```
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
```

```
%% Third Alignment: Check Parameters
dvcheck mythird_VLP
```
```
%% Third Alignment: Confirm Parameters
dvunfold mythird_VLP
```

#### Submit alignment script to cluster
% On terminal, run the following and enter your password
% ssh yourusername@curnagl.dcsr.unil.ch "bash /work/FAC/FBM/DMF/pnavarr1/default/Aurelien/dynamo_submit.sh ./users/yourusername/mySTA/HIV_Capsid_SP1/mythird_VLP --test"

#### Short Quiz Session
**1. How do you choose a proper box size?** <br>
**2. From your current understanding, what makes STA different than SPA?**<br>
**3. How can STA answer and/or support your structural biology research?**<br>


```
%% Third Alignment: Check status of alignment
dvstatus mythird_VLP
```

#### Visualizing STA

```
% Connect and activate our Chimera
dynamo_chimera -path 'C:\Program Files\Chimera 1.19\bin\chimera.exe'
```

```
%% Check first alignment result
ddb mythird_VLP:a -v % last computed average
```

<p align="center"> 
<img src="https://github.com/user-attachments/assets/e56d0302-38e9-431d-8813-e4384cd75838" width = "300"/>
<img src="https://github.com/user-attachments/assets/96899f9e-e6ab-4ee2-8f15-f77063b8d4dc" width = "300"/>
<img src="https://github.com/user-attachments/assets/b2a74974-e024-49a6-9435-69fa57afe8ca" width = "300"/> <br>
    <em> Last computed average of **mythird_VLP** alignment.</em>
</p>
<br>

On **dview**, go to top panel and select **Export** > **Invert, send to Chimera UCSF**. This will give you the finalized result of the HIV capsid structure. You can also explore **Chimera** platform to adjust 3D visualization. <br>

```
% Run this to create mask while viewing every result
dynamo_mask();
```

This will return the following GUI, and you can follow the parameters below. You can visualize each mask with *view* button. <br>

<p align="center"> 
<img src="https://github.com/user-attachments/assets/ca88d5b5-ca30-4bbf-8755-e96fae335ccb" width = 400 /> <br>
<img src="https://github.com/user-attachments/assets/3e22a95c-65a3-47aa-92c2-50ff796bef32" width = 300 />
<img src="https://github.com/user-attachments/assets/7c65c91a-04bf-4d11-abba-2ca9143b6640" width = 300/>
<img src="https://github.com/user-attachments/assets/8c203874-15f7-4724-b932-e5b1353850ba" width = 300/><br>
    <em> Tube mask view .</em>
</p> <br>

<p align="center">
<img src="https://github.com/user-attachments/assets/940be9d0-c82c-44ef-845d-1032041df7af" width = 300 />
<img src="https://github.com/user-attachments/assets/e990fc24-85c7-4f15-b00c-adacb81e6fd8" width = 300/>
<img src="https://github.com/user-attachments/assets/9e193b86-e85f-4abc-9c76-3ffd595d933e" width = 300/><br>
    <em> Tube mask after reference adjustment view .</em>
</p> <br>

```
%% Third Alignment: Visualize mask overlay
crop_mask = dread('tube_map_masked.em');
inv_mask = -crop_mask;
dview(inv_mask)
% dview([mask_path, '/tube_map_masked.em']);
%% Third Alignment: Save
%dwrite(inv_mask,'inv_tube_mask_128.em');
dview([mask_path, '/inv_tube_mask_128.em']);
```

```
%% Third Alignment: Apply Cropped Mask Alignment
% Here, we no longer adjust the numerical parameters because our previous
% computed average from third alignment was alredy decent.
sal = dalign('temp.em', [mask_path, '/inv_tube_mask_128.em'], 'cr',0,'cs',0,'ir',0, ...
    'dim',128,'limm',1, 'lim',[0,0,0]);

%% Third Alignment: Evaluate adjusted average
dmapview(sal.aligned_particle);
%dwrite(sal.aligned_particle, 'sal_aligned_average_final.em');
```
To visualize our STA (subtomogram averaged) volume,  we select the **Chimera** panel on top then proceeds to **Invert + Append current volume to running Chimera session**. Chimera GUI should now open up with our STA structure. The box noise is now removed since we applied the cropping mask previously, but to further clean our noise, proceed to **Tools > Volume Data > Hide Dust** and adjust by sliding the *Hide Dust* slide. Your volume should roughly look similar to the original lattice but with lower resolution. <br>

<p align="center">
<img src="https://github.com/user-attachments/assets/d2df2a92-8a80-4aa6-ad9e-158c93363443" width = 300 />
<img src="https://github.com/user-attachments/assets/830e18a7-9e5f-4193-af5e-56db457b3fab" width = 300/>
<img src="https://github.com/user-attachments/assets/4abeeb5c-0b11-4268-839f-c8fafe5da46b" width = 300/><br>
    <em> Averages in X,Z,Y after cropping mask adjustment .</em>
</p> <br>
<p align="center">
<img src="https://github.com/user-attachments/assets/edf8950a-5fa5-436e-b419-f70f47aa3da9" width = 450/><br>
</p> <br>
<p align="center">
<img src="https://github.com/user-attachments/assets/4b3e99ae-883f-4ccc-b8ea-71d0427746bd" width = 300/>
<img src="https://github.com/user-attachments/assets/07d81f7f-a5b4-40f1-be59-77e87dcbc99a" width = 300/>
<img src="https://github.com/user-attachments/assets/88f2850e-298d-44eb-9ab3-8ec1aeb8e6be" width = 300/><br>
    <em> Inverting averaged volume to Chimera UCSF .</em>
</p> <br>
<p align="center">
<img src="https://github.com/user-attachments/assets/90c75a63-891a-46b5-901a-1b1a7d49b525" width = 500/>
<img src="https://github.com/user-attachments/assets/bf011f11-7c87-4b30-9d88-d1257fbe8c06" width = 500/> <br>
</p> <br>

In case you would like to analyze the mid-section of the structure, you can "slice" from side angle by going to panel **Tools > Viewing control > Sideview**. On the main Chimera window, adjust the angle and on the sideview window, adjust the vertical lines outside your structure. <br>

<p align="center">
<img src="https://github.com/user-attachments/assets/dbe268bb-67fc-4be1-9407-4e7f28430440" width = 500/>
 <img src="https://github.com/user-attachments/assets/e939eabd-7477-42d0-8e33-d4a203c06168" width = 500/><br>
 <em> Evaluating STA volume on Chimera .</em>
</p> <br>

<p align="center">
<img src="https://github.com/user-attachments/assets/77fe33a4-9be7-4186-9eb2-17ffcce97605" />
<img src="https://github.com/user-attachments/assets/cedd14cf-6a57-49ac-be44-9341dfeda24c" />
<img src="https://github.com/user-attachments/assets/39379b67-acb0-4e68-9d0c-6c07fd255426" /> <br>
 <em> High-res (green) and low-res (gray) .</em>
</p> <br>

<p align="center">
<img src="https://github.com/user-attachments/assets/1ffa8e58-4100-434a-91b3-43dc33e1f0e8" width =350/>
<img src="https://github.com/user-attachments/assets/80a6303e-4577-4043-be56-3d573853dee6" width = 370/> <br>
 <em> High-res (green) and low-res (gray) overlay STA. Box size difference.</em>
</p> <br>




#### References
[1] Navarro PP, Stahlberg H, Castaño-Díez D. Protocols for Subtomogram Averaging of Membrane Proteins in the Dynamo Software Package. Front Mol Biosci. 2018 Sep 4;5:82. doi: 10.3389/fmolb.2018.00082. PMID: 30234127; PMCID: PMC6131572. <br>
[2] Gregor A. CryoNAV<br>
[3] Buchholz TO, Krull A, Shahidi R, Pigino G, Jékely G, Jug F. Content-aware image restoration for electron microscopy. Methods Cell Biol. 2019;152:277-289. doi: 10.1016/bs.mcb.2019.05.001. Epub 2019 Jul 11. PMID: 31326025.<br>
[4] Castaño-Díez D, Kudryashev M, Arheit M, Stahlberg H. Dynamo: a flexible, user-friendly development tool for subtomogram averaging of cryo-EM data in high-performance computing environments. J Struct Biol. 2012 May;178(2):139-51. doi: 10.1016/j.jsb.2011.12.017. Epub 2012 Jan 8. PMID: 22245546.<br>
[5] Kimanius D, Dong L, Sharov G, Nakane T, Scheres SHW. New tools for automated cryo-EM single-particle analysis in RELION-4.0. Biochem J. 2021 Dec 22;478(24):4169-4185. doi: 10.1042/BCJ20210708. PMID: 34783343; PMCID: PMC8786306.<br>
[6] Pettersen EF, Goddard TD, Huang CC, Meng EC, Couch GS, Croll TI, Morris JH, Ferrin TE. UCSF ChimeraX: Structure visualization for researchers, educators, and developers. Protein Sci. 2021 Jan;30(1):70-82. doi: 10.1002/pro.3943. Epub 2020 Oct 22. PMID: 32881101; PMCID: PMC7737788.<br>
 
