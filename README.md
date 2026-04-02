
# Cryo-ET: Subtomogram Averaging (STA)
**Determining macromolecular complexes in their native environment**<br>
#### Affiliation: Navarro Lab, Department of Fundamental Microbiology, Faculty of Biology and Medicine, University of Lausanne
---
 
**Subtomogram averaging (STA)** is one of the main structural biology techniques used to obtain structure of macromolecular complexes *in situ*. Unlike Single Particle Analysis (SPA) where structure is obtained from purified states, STA allows researchers to evaluate structural conformations in cellular context where those particles sit in space.


**Structure of Interest** <br>
In this tutorial, we will be visualizing an **HIV-1 capsid-SP1** (shown below) derived from tomography data. While the high-resolution STA structure (3.9 A) of this has been published here [**EMD-4015**](https://www.ebi.ac.uk/emdb/EMD-4015?tab=overview), this walkthrough provides an introductory session how we can obtain lower-resolution version of it. <br>


<img  src="https://github.com/user-attachments/assets/aa78864e-44e3-4d8e-951b-1f4113a55de5" width = "450" /> <img src="https://github.com/user-attachments/assets/ca97b18e-dc12-48dc-9691-a3efd53b44b9" width = "380"/>

**Data Requirement** <br>
- Tutorial data <br>
*If you'd like to use your own dataset, we recommend you to crop your original tomogram or bin your tomogram by 4 to familiarize with the whole processing pipeline. Once satisifed with your tutorial structure, you may lower binning level to obtain higher resolution.

**Installation and Dependencies** <br>
- [MATLAB Dynamo-EM](https://drive.google.com/file/d/1x5he7ctkC4BUCNFhfXLk6heggGohELoM/view?usp=sharing)
- [UCSF ChimeraX](https://www.cgl.ucsf.edu/chimera/download.html)
- GPUs <br>
  Use your organization/institution GPU clusters. For **UNIL** members, you may run the same script with *dynamo_submit()* function. <br>
- Sufficient memory (~38GB RAM) <br>
  STA will require sufficient RAM memory to process images. Using tutorial data should not be an issue at the moment. Contact your local IT support if you encounter memory issue.


#### Organize Data
To run the script, make sure you create your working directory as shown below. <br>
```
HIV_Capsid_SP1/
├── Tomograms/
│   ├── vlp_7.mrc
│   ├── vlp_6.mrc
│   ├── vlp_5.mrc
│   ├── vlp_4.mrc
│   ├── vlp_3.mrc
│   ├── vlp_2.mrc
│   └── vlp_1.mrc
└── STA.m
└── tutorialVLP
└── tutorialVLP.ctlg
```
Open the **STA.m** script and adjust with your data. On MATLAB, your variables can be viewed under **Workspace** while your command output can be viewed under **Command Windows**. <br>

#### Setting up working environment
In this section, we will setup our main catalogue and associated tomograms that we have. **Catalogue** on Dynamo-EM is a management directory where our tomograms (including the different scaling sizes) and particle models will be stored. Creating a catalogue helps the package to organize the metadata in order. <br>
```
%% Data Organization
% Prior to generating structure of interest, please install Dynamo-EM package on MATLAB,
% GPU availability and 3D reconstructed tomogram(s).

%% Activate Dynamo-EM package
clear;clc; % Good practice to make sure workspace is clean to avoid variable duplicates.
% Load Dynamo package: Adjust path if needed.
run /usr/local/Dynamo_v.1.1.555/dynamo_activate.m
```

```
%% Create a .vll file containing our tomograms
% This .vll file will help us connect our processing to the full path to
% our tomograms.
mrc = dir(fullfile(pwd,'**','Tomograms/vlp_*.mrc'));
path = string(fullfile({mrc.folder},{mrc.name})).';
% Load based on our current workdir
path = replace(path, string(pwd) + filesep , "");
% Create .vll file containing fullpath of the location
writelines(path, 'VLPtomograms.vll');
```

```
%% Create a catalogue
% Catalogue is where your tomograms and associated particle models will be
% stored.
dcm -create myVLP -fromvll VLPtomograms.vll;
```

#### Setting up tomograms

Here you may adjust the scale size of your original tomogram. Since tutorial data may already been binned, we can proceed by using the default with "1". The 'zchunk' refers to how many Z slices chunk can the algorithm process this binning. This method helps minimize excessive computing overload.
```
%% Confirm the tomograms scale size
dynamo_catalogue_bin('myVLP',1,'zchunk',300);
```
If your own tomogram is at its highest resolution, it would be wise to switch the bin size to "2" so that it will be faster for you to visualize your model on Dynamo GUI. It is highly advised to follow this step even if you are not binning your tomogram. The *dynamo_catalogue_bin* helps Dynamo to confirm your tomogram scale size along the way.<br>

#### Generating model: Dynamo-GUI
To perform particle selection, we always use GUI to make sure we can visualize what we are collecting. Always use tomograms where scaling have been adjusted to avoid memory complications. Here, we will generate a model based on **dipoleSet**. Particularly for this viral capsid, the dipoleSet model will allow us to: <br>

**Manually label capsid center and pole per capsid model.** <br>

**Measure the distance between the 2 points you labeled (e.g., center and north/south)**. <br>

Theoretically, if you point labels are accurate on the tomogram, you would obtain a sphere. However, if your labeling is off, you'd create either oversized or undersized sphere per viral capsid. <br>

*We already prepare models for you in case your labels are off, so you do not have to collect each model from all the tomograms. You may follow the steps below to get an overview how collecting model works.*

```
% Open one volume at a time, and generate dipole model and save into disk.
dtmslice Tomograms/vlp_1.mrc -c myVLP -prebinned 1;
%dtmslice Tomograms/vlp_2.mrc -c myVLP -prebinned 1;
%dtmslice Tomograms/vlp_3.mrc -c myVLP -prebinned 1;
%dtmslice Tomograms/vlp_4.mrc -c myVLP -prebinned 1;
%dtmslice Tomograms/vlp_5.mrc -c myVLP -prebinned 1;
%dtmslice Tomograms/vlp_6.mrc -c myVLP -prebinned 1;
```
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

#### Extract dipole models across tomograms

```
% Load dipoleSet models from catalogue. In the meantime, we'll use our tutorial labeled data. Each tomogram already has dipole model saved.
dcmodels tutorialVLP -tc dipoleSet -ws o -gm 1;
```

```
%% Create a table from each vesicle model
c = 1; % Counter for table
for tomo = 1:6 % Loop over 6 tomos
    ds = o.models{tomo};
    NDipoles = length(ds.dipoles);
    for i=1:NDipoles
        v = dmodels.vesicle();
        v.center = ds.dipoles{i}.center;
        v.radius = norm(ds.dipoles{i}.north - ds.dipoles{i}.center);
        v.separation = 60;
        v.crop_distance_from_surface = 0;
        v.updateCrop();
        tv{c} = v.grepTable();
        tv{c}(:,22) = i;
        tv{c}(:,20) = tomo;
        c=c+1;
    end
end

%% Merge all table
tAll = dynamo_table_merge(tv, 'linear_tags', 1);
```

```
%% Visualize all dipole models in one plot
dtplot(tAll, 'pf', 'oriented_positions');
axis equal;
```

<p align="center">
  <img src="https://github.com/user-attachments/assets/91a5602a-152e-4c08-8b14-0be0c6717359" width = "400"/> 
 <img src="https://github.com/user-attachments/assets/fbf472e3-a5b5-47c7-8bd3-38b4b7170a08" width = "400" />

  <em>Compilation of all of our dipoleSet models derived from tutorial data.</em>
</p>
<br>
The images shown above show how our dipoleSet models generate sphere-like for the each capsid we labeled in 3D. Notice that the point coordinates are assigned on the surface of each model which we will extract those areas to capture the capsid surface layer.<br>

```
% The columns mention all the angles information.
dtinfo(tAll);
```

```
%% Create unique ID to map our model to the list of different tomograms
% Let's make sure that the points we are cropping are based on the tomogram's associated model. Assigning a .doc file creates a unique ID so that our algorithm does not crop the wrong tomogram.
folder = 'Tomograms/';  % Our list of tomograms are stored here
fid = fopen('VLPtomograms.docx','w');

% Loop for our 6 tomograms and assign ID:
for i = 1:6
    fprintf(fid, '%d %svlp_%d.mrc\n', i, folder, i);
end

fclose(fid);
```

#### Subtomograms Extractions
Once we assigned unique ID between tomograms and we can proceed to the critical part, to generate **subtomograms**. To do this, we crop our particle points into specified box size. In our case, we will crop the points present on the surface layer of the capsid and set a **box size of 128px** to crop each particle area. <br>

```
% Directory where cropped particles will be stored:
targetFolder = './myparticlesSize128';
% Using the generated table, we crop the particles with desired box size
dtcrop('VLPtomograms.doc', tAll, targetFolder, 128);
```

```
%% Generate initial averages
% Load our cropped particles that are stored as .crop.tbl.
finalTbl = dread([targetFolder '/crop.tbl']);
```

Activating fourier compensation during averaging so that the intensity signals for each particle that were affected my missing wedge gets averaged properly.
```
%% Generate coarse average
% Here we average out our cropped file with 'fc' as "1" to activate fourier compensation.
oa = daverage(targetFolder, 't', finalTbl, 'fc',1);
```
The output of **daverage()** will contain several metadata. We normally evaluate the *.average* result to evaluate. <br>

```
%% Visualze
dview(oa.average);
```


<p align="center"> 
 <img src="https://github.com/user-attachments/assets/a8c383bf-cc7d-4f0e-a26e-f5b4342f3abd" width = "300" />
 <img src="https://github.com/user-attachments/assets/95b8d05b-906f-41b4-a2ac-696fb74359fc" width = "300"/>
 <img src="https://github.com/user-attachments/assets/c710bfb1-ebb0-45a4-9d64-c4cd8e4dcadf" width = "300"/>


  <em>Coarse average prior to any alignment in X,Y,Z.</em>
</p>
<br>

```
%% Save
% Save initial average
dwrite(oa.average,[targetFolder '/template.em']);
```
Since this is merely coarse average done before any alignment, we cannot see distinguish any feature just yet, but we can see a rough feature of curvature on X/Y depicting outer surface layer of the capsid. We will save this as our initial template to guide the alignment. <br>

### Subtomograms Alignment
The alignment is one of the most critical steps in STA because this alignment project is how we will be rotating and spinning each particle in our subtomograms to one aligned state. <br>

#### First Alignment Project

```
%% First Alignment Project
% Variable to assign name for alignment project
pr = 'myfirst_VLP';
% Generate parameter
dcp.new(pr,'d',targetFolder,'t',[targetFolder '/crop.tbl'], 'template', ...
    [targetFolder '/template.em'],'masks','default','show',0);
```
Next, we determine our **numerical parameters**, which refers to the rotations, angles, and shifting fine tuning so that our particles are aligned. This step is one of the most cumbersome methods because there is no definitive parameters for every structure. This means you must perform this on 1 structure state at a time from your selected particle model. In our case, we will perform 2-3 alignment projects for all the VLP capsid dipoleSet models at once. <br>

For more information on the command lines, you can refer on ('[Dynamo_Command_Info.pdf](https://github.com/anandaV-88/Cryo-ET/blob/main/Dynamo_Command_Info.pdf)').

```
%% First Alignment: Adjust Numerical Parameters
% No. of iteration: 4
dvput(pr,'ite_r1',4);
% No. of particle dimension: rescale to 32
dvput(pr,'dim_r1',32);
% No. of cone aperture: 40
dvput(pr,'cr_r1',40);
% No. of cone sampling: 20
dvput(pr,'cs_r1',20);
% No. of in-plane range (azimuth): 360
dvput(pr,'ir_r1',360);
% No. of in-plane sampling (azimuth sampling): 40
dvput(pr,'is_r1',40);
% No. of refine: 4
dvput(pr,'rf_r1',4);
% No. of refine factor
dvput(pr,'rff_r1',2);
% shift limits
dvput(pr,'lim_r1',[40,40,40]);
% shift limiting way
dvput(pr,'limm_r1',1);
% Computing Env.
dvput(pr,'dst','standalone_gpu','cores',1,'mwa',2);
```

```
%% First Alignment: Check Numerical Parameters
% This is to ensure your input metadata are valid. The system will respond "seems safe enough" if your metadata is good to proceed.
dvcheck myfirst_VLP
```
```
%% First Alignment: Confirm Numerical Parameters
% Run this to compile the project prior to submitting into cluster.
dvunfold myfirst_VLP
```

```
%% First Alignment: Submit alignment job into cluster
% For **UNIL** user, we can submit to our cluster. Here we use 2 GPUs and request for 2 hours slot. This should be done within 10mins.
dynamo_submit('first_VLP','gpus',1,'time','2:00:00');
```

```
%% First Alignment: Check status of alignment
% On the command window, you can see whether your project has started running or even completed.
dvstatus myfirst_VLP
```
Evaluate our **myfirst_vlp** averaged result after aligning:

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

```
%% First Alignment: Evaluate the averages
% Evaluate the averages of all iterations from initial to the last.
dpkdev.legacy.dynamo_mapview('myfirst_VLP:a:ite=0:last');
```

[insert gif] <br>

**center of subunits** - **center of subvolume**

```
%% First Alignment: Subboxing
% To recenter, we use 65,65,65 (128px) for our subvolume, and 57,64,69 as
% our subunit.
rSubunitFromCenter = [57,64,69] - [65,65,65];
```


```
%% First Alignment: Recenter the particles
% Load the last computed table from first alignment project
ddb myfirst_VLP:rt -ws t

% Apply new center to the table
ts = dynamo_subboxing_table(t,rSubunitFromCenter);
```
**C** : Center of subvolume <br>
**N**: Center of subunit <br>
As shown below, you can adjust our last computed average from **myfirst_vlp** based on the center of box (subvolume) and our particle of interest (center of subunit). You can use your mouse and left click for **C** and right click for **N** positions. On the **Click** panel, you can see the different positional coordinates.  <br>
![subboxing_balance](https://github.com/user-attachments/assets/2db019a3-337e-479f-8d67-341064ef0a85) 
<img src="https://github.com/user-attachments/assets/cb6101bb-24bf-40ab-9642-7a5ae55ecef8" width = "800"/>

To further align our particles, we crop our box size smaller to easily evaluate our alignment. Below we use box size of 96: <br>

```
%% First Alignment: Adjust table with subboxing
% Use the adjusted table to recrop the particles
targetFolder = './myparticlesSize96r';

% Crop: reduce box size to 96
dtcrop('VLPtomograms.doc',ts,targetFolder,96);
```
Now we average the adjusted crop made on the last computed average with subboxing parameters: <br>

```
%% First Alignment: Average table with subboxing
% Average and visualize the re-cropped particles
finalTbl = dread([targetFolder,'/crop.tbl']);
oa = daverage(targetFolder, 't', finalTbl,'fc',1);
dview(oa.average);
```

<p align="center"> 
<img src="https://github.com/user-attachments/assets/7853b987-3e56-4131-88ad-a545bcd8c8ab" width = "400" />
<img src="https://github.com/user-attachments/assets/8c2ffc0e-625d-4dbc-bd51-84564c58f63e" width = "400"/>
<img src="https://github.com/user-attachments/assets/e8601842-e5c7-4fb1-bdc9-84346eca397d" width = "400"/><br>
  <em>Last computed average after alignment in **myfirst_vlp**.</em>
</p>
<br>

Do you notice anything? If the surface in X and Y are too low or too high, we can re-adjust. However, it seems that they are quite well adjusted so don't need further adjustment. <br>

```
%% Save
dwrite(oa.average,[targetFolder '/template.em']);
```




#### References
[1] Navarro PP, Stahlberg H, Castaño-Díez D. Protocols for Subtomogram Averaging of Membrane Proteins in the Dynamo Software Package. Front Mol Biosci. 2018 Sep 4;5:82. doi: 10.3389/fmolb.2018.00082. PMID: 30234127; PMCID: PMC6131572. <br>
[2] Gregor A. CryoNAV<br>
[3] Buchholz TO, Krull A, Shahidi R, Pigino G, Jékely G, Jug F. Content-aware image restoration for electron microscopy. Methods Cell Biol. 2019;152:277-289. doi: 10.1016/bs.mcb.2019.05.001. Epub 2019 Jul 11. PMID: 31326025.<br>
[4] Castaño-Díez D, Kudryashev M, Arheit M, Stahlberg H. Dynamo: a flexible, user-friendly development tool for subtomogram averaging of cryo-EM data in high-performance computing environments. J Struct Biol. 2012 May;178(2):139-51. doi: 10.1016/j.jsb.2011.12.017. Epub 2012 Jan 8. PMID: 22245546.<br>
[5] Kimanius D, Dong L, Sharov G, Nakane T, Scheres SHW. New tools for automated cryo-EM single-particle analysis in RELION-4.0. Biochem J. 2021 Dec 22;478(24):4169-4185. doi: 10.1042/BCJ20210708. PMID: 34783343; PMCID: PMC8786306.<br>
[6] Pettersen EF, Goddard TD, Huang CC, Meng EC, Couch GS, Croll TI, Morris JH, Ferrin TE. UCSF ChimeraX: Structure visualization for researchers, educators, and developers. Protein Sci. 2021 Jan;30(1):70-82. doi: 10.1002/pro.3943. Epub 2020 Oct 22. PMID: 32881101; PMCID: PMC7737788.<br>
 
