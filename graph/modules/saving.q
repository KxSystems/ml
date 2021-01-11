\d .ml
  

// Utility Functions for loading data

// @private
// @kind function
// @category savingUtility
// @fileoverview Construct path to location where data is to be saved
// @param config {dict} Any configuration information about the dataset being 
//   saved
// @return {str} Path to a file location
i.saveFileName:{[cfg]
  file:hsym`$$[`dir in key cfg;cfg`key;"."],"/",cfg fname;
  if[not ()~key file;'"file exists"];
  file}


// @private
// @kind function
// @category savingUtility
// @fileoverview Save data as a text file
// @param config {dict} Any configuration information about the dataset being 
//   saved
// @param data {tab} Data which is to be saved
// @return {null} Data is saved as a text file 
i.saveFunc.txt:{[config;data]
  i.saveFileName[config]0:.h.tx[config`typ;data];
  }


// @private
// @kind function
// @category savingUtility
// @fileoverview Save data as a text file
// @param config {dict} Any configuration information about the dataset being 
//   saved
// @param data {tab} Data which is to be saved
// @return {null} Data is saved as a text file 
i.saveFunc[`csv`xml`xls]:i.saveFunc.txt


// @private
// @kind function
// @category savingUtility
// @fileoverview Save data as a binary file
// @param config {dict} Any configuration information about the dataset being 
//   saved
// @param data {tab} Data which is to be saved
// @return {null} Data is saved as a binary file 
i.saveFunc.binary:{[config;data]
  i.saveFileName[config]set data;
  }


// @private
// @kind function
// @category savingUtility
// @fileoverview Save data as a json file
// @param config {dict} Any configuration information about the dataset being 
//   saved
// @param data {tab} Data which is to be saved
// @return {null} Data is saved as a json file 
i.saveFunc.json:{[config;data]
  h:hopen i.saveFileName config;
  h @[.j.j;data;{'"error converting to json"}];
  hclose h;
  }


// @private
// @kind function
// @category savingUtility
// @fileoverview Save data as a HDF5 file
// @param config {dict} Any configuration information about the dataset being 
//   saved
// @param data {tab} Data which is to be saved
// @return {null} Data is saved as a HDF5 file 
i.saveFunc.hdf5:{[config;data]
  if[not`hdf5 in key`;@[system;"l hdf5.q";{'"unable to load hdf5 lib"}]];
  .hdf5.createFile filePath:i.saveFilename config;
  .hdf5.writeData[filePath;config`dname;data];
  }


// @private
// @kind function
// @category savingUtility
// @fileoverview Save data as a splayed table
// @param config {dict} Any configuration information about the dataset being 
//   saved
// @param data {tab} Data which is to be saved
// @return {null} Data is saved as a splayed table 
i.saveFunc.splay:{[config;data]
  dataName:first` vs filePath:i.saveFileName config;
  filePath:` sv filePath,`;
  filePath set .Q.en[dataName]data;
  }


// @private
// @kind function
// @category savingUtility
// @fileoverview Save data in a defined format
// @param config {dict} Any configuration information about the dataset being 
//   saved
// @param data {tab} Data which is to be saved
// @return {null} Data is saved in the defined format 
i.saveDataset:{[config;data]
  if[null func:i.saveFunc cfg`typ;'"dataset type not supported"];
  func data
  }

// Saving functionality

// @kind function
// @category saving
// @fileoverview Node to save data from a defined source
// @return {dict} Node in graph to be used for saving data
saveDataset:`function`inputs`outputs!(i.saveDataset;`cfg`dset!"!+";" ")
