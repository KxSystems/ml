\l automl.q

.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// don't run tests if torch can't be loaded
if[not 0~.automl.checkimport[1];exit 0];

// Create feature and target data
nGeneral:100

featureDataNormal:([]nGeneral?1f;asc nGeneral?1f;nGeneral?`a`b`c)

targetBinary     :asc 100?0b

// language agnostic function for moving a file to a new location
.test.moveFiles:{[filePaths]
  os:.z.o like "w*";
  filePaths:{" "sv raze each x,/:y}[.automl.path;filePaths];
  if[os;filePaths:ssr[filePaths;"/";"\\"]];
  system $[os;"move ";"mv "],filePaths;
  }

// file paths to allow torch model tests to be added and reverted to original
.test.filePaths:(("/code/customization/models/libSupport/torch.q";"/code/customization/models/libSupport/oldTorch.q");
          ("/code/customization/models/libSupport/torch.p";"/code/customization/models/libSupport/oldTorch.p");
          ("/code/customization/models/modelConfig/models.json";"/code/customization/models/modelConfig/oldModels.json");
          ("/code/tests/files/torch/torch.q";"/code/customization/models/libSupport/torch.q");
          ("/code/tests/files/torch/torch.p";"/code/customization/models/libSupport/torch.p");
          ("/code/tests/files/torch/models.json";"/code/customization/models/modelConfig/models.json"));

.test.moveFiles each .test.filePaths;

// reload the library contents to ensure the correct torch files used
.automl.loadfile`:init.q

// Create function to ensure fit runs correctly
.test.checkFit:{[params]fitReturn:(key;value)@\:.automl.fit . params;type[first fitReturn],type each last fitReturn}

-1"\nTesting appropriate inputs to fit function for with torch models loaded\n";

passingTest[.test.checkFit;(featureDataNormal;targetBinary;`normal;`class;::);1b;11 99 104h]

// Revert to the default torch setup
.test.moveFiles each reverse each .test.filePaths rotate[3;til 6];

// Revert the automl library version to use 
.automl.loadfile`:init.q
