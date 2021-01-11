\d .ml  

// Utility Functions for loading data

// @private
// @kind function
// @category loadingUtility
// @fileoverview Construct path to a data file
// @param config {dict} Any configuration information about the dataset being 
//   loaded in
// @return {str} Path to the data file
i.loadFileName:{[config]
  file:hsym`$$[(not ""~config`directory)&`directory in key config;
    config`directory;
    "."],"/",cfg`fileName;
  if[()~key file;'"file does not exist"];
  file}


// @private
// @kind function
// @category loadingUtility
// @fileoverview Load splayed table or binary file
// @param config {dict} Any configuration information about the dataset being 
//   loaded in
// @return {tab} Date obtained from splayed table or binary file
i.loadFunc.splay:i.loadFunc.binary:{[config] get i.loadFileName config}


// @private
// @kind function
// @category loadingUtility
// @fileoverview Load data from csv file
// @param config {dict} Any configuration information about the dataset being 
//   loaded in
// @return {tab} Data obtained from csv
i.loadFunc.csv:{[config]
  (config`schema;config`separator)0: i.loadFileName config
  }


// @private
// @kind function
// @category loadingUtility
// @fileoverview Load data from json file
// @param config {dict} Any configuration information about the dataset being 
//   loaded in
// @return {tab} Data obtained from json file
i.loadFunc.json:{[config].j.k first read0 i.loadFileName config}


// @private
// @kind function
// @category loadingUtility
// @fileoverview Load data from HDF5 file
// @param config {dict} Any configuration information about the dataset being 
//   loaded in
// @return {tab} Data obtained from HDF5 file  
i.loadFunc.hdf5:{[config]
  if[not`hdf5 in key`;@[system;"l hdf5.q";{'"unable to load hdf5 lib"}]];
  if[not .hdf5.ishdf5 filePath:i.loadFileName cfg;'"file is not an hdf5 file"];
  if[not .hdf5.isObject[filePath;config`dname];'"hdf5 dataset does not exist"];
  .hdf5.readData[fpath;config`dname]
  }


// @private
// @kind function
// @category loadingUtility
// @fileoverview Load data from ipc
// @param config {dict} Any configuration information about the dataset being 
//   loaded in
// @return {tab} Data obtained via IPC
i.loadFunc.ipc:{[config]
  h:@[hopen;config`port;{'"error opening connection"}];
  ret:@[h;config`select;{'"error executing query"}];
  @[hclose;h;{}];
  ret
  }


// @private
// @kind function
// @category loadingUtility
// @fileoverview Load data from config dictionary
// @param config {dict} Any configuration information about the dataset being 
//   loaded in
// @return {dict} Data obtained from config dictionary
i.loadFunc.process:{[config]
  if[not `data in key config;'"Data to be used must be defined"];
  cfg[`data]
  }


// @private
// @kind function
// @category loadingUtility
// @fileoverview Load data from a defined source
// @param config {dict} Any configuration information about the dataset being 
//   loaded in
// @return {dict} Data obtained from a defined source
i.loadDataset:{[config]
  if[null func:i.loadFunc config`typ;'"dataset type not supported"];
  func config
  }

// Loading functionality

// @kind function
// @category loading
// @fileoverview Node to load data from a defined source
// @return {dict} Node in graph to be used for loading data
loadDataSet:`function`inputs`outputs!(i.loadDataset;"!";"+")

