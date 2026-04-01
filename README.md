
# Cryo-ET: Subtomogram Averaging (STA)
**Determining macromolecular complexes in their native environment**<br>
#### Affiliation: Navarro Lab, Department of Fundamental Microbiology, Faculty of Biology and Medicine, University of Lausanne
---
 
**Subtomogram averaging (STA)** is one of the main structural biology techniques used to obtain structure of macromolecular complexes *in situ*. Unlike Single Particle Analysis (SPA) where structure is obtained from purified states, STA allows researchers to evaluate structural conformations in cellular context where those particles sit in space.


**Structure of Interest** <br>
In this tutorial, we will be visualizing an **HIV-1 capsid-SP1** (shown below) derived from tomography data. While the high-resolution STA structure (3.9 A) of this has been published here [**EMD-4015**](https://www.ebi.ac.uk/emdb/EMD-4015?tab=overview), this walkthrough provides an introductory session how we can obtain lower-resolution version of it. <br>


<img  src="https://github.com/user-attachments/assets/aa78864e-44e3-4d8e-951b-1f4113a55de5" width = "350" /> <img src="https://github.com/user-attachments/assets/ca97b18e-dc12-48dc-9691-a3efd53b44b9" width = "380"/>

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
dcm -create catVLP -fromvll VLPtomograms.vll;
```

#### Setting up tomograms

Here you may adjust the scale size of your original tomogram. Since tutorial data may already been binned, we can proceed by using the default with "1". The 'zchunk' refers to how many Z slices chunk can the algorithm process this binning. This method helps minimize excessive computing overload.
```
%% Confirm the tomograms scale size
dynamo_catalogue_bin('catVLP',1,'zchunk',300);
```
If your own tomogram is at its highest resolution, it would be wise to switch the bin size to "2" so that it will be faster for you to visualize your model on Dynamo GUI. It is highly advised to follow this step even if you are not binning your tomogram. The *dynamo_catalogue_bin* helps Dynamo to confirm your tomogram scale size along the way.<br>

#### Generating model: Dynamo-GUI
To perform particle selection, we always use GUI to make sure we can visualize what we are collecting. Always use tomograms where scaling have been adjusted to avoid memory complications. Here, we will generate a model based on **dipoleSet**. Particularly for this viral capsid, the dipoleSet model will allow us to: <br>

**Manually label capsid center and pole per capsid model.** <br>

**Measure the distance between the 2 points you labeled (e.g., center and north/south)**. <br>

Theoretically, if you point labels are accurate on the tomogram, you would obtain a sphere. However, if your labeling is off, you'd create either oversized or undersized sphere per viral capsid. <br>

*We already prepare models for you in case your labels are off, so you may run the following the exact same script below.*

```
% Open one volume at a time, and generate dipole model and save into disk.
dtmslice Tomograms/vlp_1.mrc -c catVLP -prebinned 1;
%dtmslice Tomograms/vlp_2.mrc -c catVLP -prebinned 1;
%dtmslice Tomograms/vlp_3.mrc -c catVLP -prebinned 1;
%dtmslice Tomograms/vlp_4.mrc -c catVLP -prebinned 1;
%dtmslice Tomograms/vlp_5.mrc -c catVLP -prebinned 1;
%dtmslice Tomograms/vlp_6.mrc -c catVLP -prebinned 1;
```
Once the GUI opens up, adjust the threshold of the tomogram by selecting the icon on the top panel shown below and start creating dipoleSet model wherever you see the viral capsid. Dynamo built-in function will automatically calculate the sphere as shown below:<br>
To label *center* and *north* of your capsid, use your keyboard and press **C** in the center and **N** on the north edge of the capsid. <br>

<img width="1325" height="709" alt="image" src="https://github.com/user-attachments/assets/d9b11f12-aa30-4985-a89e-72f2b039d653" />



#### References
[1] Navarro PP, Stahlberg H, Castaño-Díez D. Protocols for Subtomogram Averaging of Membrane Proteins in the Dynamo Software Package. Front Mol Biosci. 2018 Sep 4;5:82. doi: 10.3389/fmolb.2018.00082. PMID: 30234127; PMCID: PMC6131572. <br>
[2] Gregor A. CryoNAV<br>
[3] Buchholz TO, Krull A, Shahidi R, Pigino G, Jékely G, Jug F. Content-aware image restoration for electron microscopy. Methods Cell Biol. 2019;152:277-289. doi: 10.1016/bs.mcb.2019.05.001. Epub 2019 Jul 11. PMID: 31326025.<br>
[4] Castaño-Díez D, Kudryashev M, Arheit M, Stahlberg H. Dynamo: a flexible, user-friendly development tool for subtomogram averaging of cryo-EM data in high-performance computing environments. J Struct Biol. 2012 May;178(2):139-51. doi: 10.1016/j.jsb.2011.12.017. Epub 2012 Jan 8. PMID: 22245546.<br>
[5] Kimanius D, Dong L, Sharov G, Nakane T, Scheres SHW. New tools for automated cryo-EM single-particle analysis in RELION-4.0. Biochem J. 2021 Dec 22;478(24):4169-4185. doi: 10.1042/BCJ20210708. PMID: 34783343; PMCID: PMC8786306.<br>
[6] Pettersen EF, Goddard TD, Huang CC, Meng EC, Couch GS, Croll TI, Morris JH, Ferrin TE. UCSF ChimeraX: Structure visualization for researchers, educators, and developers. Protein Sci. 2021 Jan;30(1):70-82. doi: 10.1002/pro.3943. Epub 2020 Oct 22. PMID: 32881101; PMCID: PMC7737788.<br>
 
