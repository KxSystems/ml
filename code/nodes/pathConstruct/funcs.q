// code/nodes/pathConstruct/funcs.q - Functions called in pathConstruct node
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of
// .automl.pathConstruct

\d .automl

// @kind function
// @category pathConstruct
// @desc Create the folders that are required for the saving of the 
//   config, models, images and reports
// @param preProcParams {dictionary} Data generated during the preprocess stage
// @return {dictionary} File path where paths/graphs are to be saved
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
// @desc Create the folders that are required for the saving of the
//   config, models, images and reports
// @param pathName {string} Name of paths that are to be created
// @return {::} File paths are created
pathConstruct.createFile:{[pathName]
  windowsChk:$[.z.o like"w*";" ";" -p "];
  system"mkdir",windowsChk,pathName
  }
