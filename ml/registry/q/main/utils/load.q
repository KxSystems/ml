// load.q - Utilties related to loading items into the registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities relating to object loading within the registry
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Load any code with a file extension '*.p','*.py','*.q'
// that has been saved with a model. NB: at the moment there is
// no idea of precedence within this load process so files should
// not be relied on to be loaded in a specific order.
//
// @todo
// Add some level of load ordering to the process
//
// @param codePath {string} The absolute path to the 'code'
//   folder containing any source code
//
// @return {null}
registry.util.load.code:{[codePath]
  files:key hsym`$codePath;
  if[0~count key hsym`$codePath;:(::)];
  qfiles:files where files like "*.q";
  registry.util.load.q[codePath;qfiles];
  pfiles:files where files like "*.p";
  registry.util.load.p[codePath;pfiles];
  pyfiles:files where files like "*.py";
  mlops.load.py[codePath;pyfiles];
  }

// @private
//
// @overview
// Load code with the file extension '*.q'
//
// @param codePath {string} The absolute path to the 'code'
//   folder containing any source code
// @param files {symbol|symbols} q files which should be loadable
//
// @return {null}
registry.util.load.q:{[codePath;files]
  sfiles:string files;
  {system "l ",x,y}[codePath]each $[10h=type sfiles;enlist;]sfiles
  }

// @private
//
// @overview
// Load code with the file extension '*.p'
//
// @param codePath {string} The absolute path to the 'code'
//   folder containing any source code
// @param files {symbol|symbol[]} Python files which should be loadable
//
// @return {null}
registry.util.load.p:{[codePath;files]
  pfiles:string files;
  {system "l ",x,y}[codePath]each $[10h=type pfiles;enlist;]pfiles;
  }
