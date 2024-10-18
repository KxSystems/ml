// copy.q - Functionality for copying items from one location to another
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities for copying items
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Copy a file from one location to another, ensuring that the file exists
// at the source location
//
// @todo
// Update this to use the axfs OS agnostic functionality provided by Analyst
//   this should ensure that the functionality will operate on Windows/MacOS/Linux
//
// @param src {#hsym} Source file to be copied.
// @param dest {#hsym} Destination file to which the file is to be copied.
// @return {null}
registry.util.copy.file:{[src;dest]
  // Expecting an individual file for copying -> should return itself
  // if the file exists at the correct location
  src:key src;
  if[()~src;
    logging.error"File expected at '",string[src],"' did not exist"
    ];
  if[not(1=count src)&all src like":*";
    logging.error"src must be an individual file not a directory"
    ];
  if[(not all(src;dest)like":*") & not all -11h=type each (src;dest);
    logging.error"Both src and dest directories must be a hsym like path"
    ];
  system sv[" "]enlist["cp"],1_/:string(src;dest)
  }

// @private
//
// @overview
// Copy a directory from one location to another
//
// @todo
// Update this to use the axfs OS agnostic functionality provided by Analyst
//   this should ensure that the functionality will operate on Windows/MacOS/Linux
//
// @param src {#hsym} Source destination to be copied.
// @param dest {#hsym} Destination to which to be copied.
// @return {null}
registry.util.copy.dir:{[src;dest]
  // Expecting an individual file for copying -> should return itself
  // if the file exists at the correct location
  if[(not all(src;dest)like":*") & not all -11h=type each (src;dest);
    logging.error"Both src and dest directories must be a hsym like path"
    ];
  system sv[" "]enlist["cp -r"],1_/:string(src;dest)
  }
