// Names of the folders containing q scripts whose line lengths are to be tested
folders:enlist"code"

// Function for retrieval of all q files
getFiles:{
  files:key hsym `$x;
  pathStem:x,"/";
  qfiles:files where files like "*.q";
  `$pathStem,/:string qfiles
  }

// List of all the q files within the appropriate folders
files:raze getFiles each folders

// For an individual file test that the lines of the file do no exceed 80 characters unless
// exempt using '// noqa' at the end of the line
testLineLength:{[file]
  fileContent:read0 hsym file;
  excessCharacters:80<count each fileContent;
  excessLocations:where excessCharacters;
  excessContent:trim fileContent excessLocations;
  testFail:lineTest[file]'[excessLocations;excessContent];
  $[any testFail;[-1"";0b];1b]
  }

// Check that an individual line conforms with the acceptable line length, return 0b
// if there are no issues, print line information and return 1b otherwise. Note lines
// with a following '// noqa' will be ignored
lineTest:{[file;loc;line]
  // find all lines that are not exempt from unit tests i.e. don't end with
  // '// noqa' these are ignored from the line length tests
  exempt:"\/\/ noqa"~-7#line;
  $[exempt;0b;[-1 "Line: ",string[loc+1]," File: '",string[file],"' Content: ",line;1b]]
  }

all testLineLength each files
