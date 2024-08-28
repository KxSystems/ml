// code/commandLine/utils.q - Command line utility functions
// Copyright (c) 2021 Kx Systems Inc
//
// Utility functions for the handling of command line arguments 

\d .automl

// @kind function
// @category cliUtility
// @desc Retrieve the path to a custom JSON file to be used on command
//   line or as the final parameter to the .automl.run function. This file must
//   exist in either the users defined path relative to 'pwd' or in 
//   "/code/customization/configuration/customConfig/"
// @param fileName {string} JSON file to be retrieved or path to this file
// @return {string} Full path to the JSON file if it exists or an error 
//   indicating that the file could not be found
cli.i.checkCustom:{[fileName]
  fileName:raze fileName;
  filePath:path,"/code/customization/configuration/customConfig/",fileName;
  $[not()~key hsym`$filePath;
    :filePath;
      not()~key hsym`$filePath:"./",fileName;
    :filePath;
      'fileName," does not exist in current directory or '",path,
        "/code/configuration/customConfig/'"
    ]
  }

// @kind function
// @category cliUtility
// @desc Parse the contents of the 'problemParameters' sections of the
//   JSON file used to define command line input and convert to an appropriate 
//   kdb+ type
// @param cliInput {string} The parsed content of the JSON file using .j.k 
//   which have yet to be transformed into their final kdb+ type
// @param sectionType {symbol} Name of the section within the 
//   'problemParameters' section to be parsed
// @returns {dictionary} Mapping of parameters required by AutoML to an 
//   assigned value cast appropriately
cli.i.parseParameters:{[cliInput;sectionType]
  section:cliInput[`problemParameters;sectionType];
  cli.i.convertParameters each section
  }

// @kind function
// @category cliUtility
// @desc Main parsing function for the JSON parsing functionality this 
//   applies the appropriate conversion logic to the value provided based on a
//   user assigned type
// @param param {dictionary} Mapping of parameters required by specific 
//   sections of AutoML to their value and associated type
// @returns {dictionary} Mapping of parameters to their appropriate kdb+ type 
//   converted values
cli.i.convertParameters:{[param]
  $["symbol"~param`type;
    `$param`value;
      "lambda"~param`type;
    get param`value;
      "string"~param`type;
    param`value;
      (`$param`type)$param`value
    ]
  }
