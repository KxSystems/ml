\d .automl

// Definitions of the main callable functions used in the application of
//   .automl.pathConstruct

// @kind function
// @category pathConstruct
// @fileoverview Create the folders that are required for the saving of the 
//   config, models, images and reports
// @param preProcParams {dict} Data generated during the preprocess stage
// @return {dict} File path where paths/graphs are to be saved
pathConstruct.constructPath:{[preProcParams]
  cfg:preProcParams`config;
  saveOpt:cfg`saveOption;
  if[saveOpt=0;:()!()];
  pathName:-1_value[cfg]where key[cfg]like"*SavePath";
  pathName:utils.ssrWindows each pathName;
  pathConstruct.createFile each pathName;
  }

// @kind function
// @category pathConstruct
// @fileoverview Create the folders that are required for the saving of the
//   config, models, images and reports
// @param pathName {str} Name of paths that are to be created
// @return {null} File paths are created
pathConstruct.createFile:{[pathName]
  windowsChk:$[.z.o like"w*";" ";" -p "];
  system"mkdir",windowsChk,pathName
  }
