// util/pickle.q - pickle file utilities 
// Copyright (c) 2021 Kx Systems Inc
//
// Save and load python objects to and from pickle files

\d .ml

// @kind function
// @cateogory pickle
// @fileoverview Generate python pickle dump module to save a python object
pickleDump:.p.import[`pickle;`:dumps;<]

// @kind function
// @cateogory pickle
// @fileoverview Generate python pickle lodas module to load a python object
pickleLoad:.p.import[`pickle;`:loads]

// @kind function
// @cateogory pickle
// @fileoverview A wrapper function to load and save python
//   objects using pickle 
// @param module {boolean} Whether the pickle load module (1b) or dump module (0b) 
//   is to be invoked
// @param obj {<} Python object to be saved/loaded
// @return {::;<} Object is saved/loaded  
pickleWrap:{[module;obj]
  $[module;{.ml.pickleLoad y}[;pickleDump obj];{y}[;obj]]
  }
