## Cryo-ET
**Affiliation: Navarro Lab, Department of Fundamental Microbiology, Department of Biology and Medicine, University of Lausanne**
### Subtomogram Averaging (STA)

Cryo-Electron Tomography (ET) has become a standard choice in retrieving visual proteomics information in situ, particularly in studying ultrastructure of the organelles and structure of macromolecular machineries in the cells. The following page is dedicated to provide a step-by-step workflow on how to obtain macromolecular structure in its native environment on tomography data through subtomogram averaging (STA). [1] <br>

#### Data Requirements:
- Aligned Tilt Series [2]
- 3D Reconstructed Tomograms (Denoised and Un-denoised) [2][3]
- MATLAB Dynamo-EM package installed[4]
- RELION 4 or 5 installed [5]
- ChimeraX or Chimera USCF installed [6] <br>
*Tutorial data is available here. In the case you would like to use your own tomograms, you may use CryoNAV platform and follow its tutorials to align, reconstruct and denoise your tomography data.*

#### Computing Requirements:
- GPUs
- 2+ Cores <br>
*Sufficient storage on your computer is necessary to perform this image processing. You may use your organization's GPU/CPU cluster if available.*

**UNIL Users** <br>
To those who have access to UNIL computing cluster, GPU work will be run separately with a customized slurm script. <br>

**Structure of Interest** <br>
In this tutorial, we will be visualizing an HIV-1 capsid-SP1 derived from tomography data. While the high-resolution structure of this has been published here [**EMD-4015**](https://www.ebi.ac.uk/emdb/EMD-4015?tab=overview), this walkthrough provides an introductory session how we can obtain lower-resolution version of it.<br>




#### References
[1] Navarro PP, Stahlberg H, Castaño-Díez D. Protocols for Subtomogram Averaging of Membrane Proteins in the Dynamo Software Package. Front Mol Biosci. 2018 Sep 4;5:82. doi: 10.3389/fmolb.2018.00082. PMID: 30234127; PMCID: PMC6131572. <br>
[2] Gregor A. CryoNAV<br>
[3] Buchholz TO, Krull A, Shahidi R, Pigino G, Jékely G, Jug F. Content-aware image restoration for electron microscopy. Methods Cell Biol. 2019;152:277-289. doi: 10.1016/bs.mcb.2019.05.001. Epub 2019 Jul 11. PMID: 31326025.<br>
[4] Castaño-Díez D, Kudryashev M, Arheit M, Stahlberg H. Dynamo: a flexible, user-friendly development tool for subtomogram averaging of cryo-EM data in high-performance computing environments. J Struct Biol. 2012 May;178(2):139-51. doi: 10.1016/j.jsb.2011.12.017. Epub 2012 Jan 8. PMID: 22245546.<br>
[5] Kimanius D, Dong L, Sharov G, Nakane T, Scheres SHW. New tools for automated cryo-EM single-particle analysis in RELION-4.0. Biochem J. 2021 Dec 22;478(24):4169-4185. doi: 10.1042/BCJ20210708. PMID: 34783343; PMCID: PMC8786306.<br>
[6] Pettersen EF, Goddard TD, Huang CC, Meng EC, Couch GS, Croll TI, Morris JH, Ferrin TE. UCSF ChimeraX: Structure visualization for researchers, educators, and developers. Protein Sci. 2021 Jan;30(1):70-82. doi: 10.1002/pro.3943. Epub 2020 Oct 22. PMID: 32881101; PMCID: PMC7737788.<br>
 
