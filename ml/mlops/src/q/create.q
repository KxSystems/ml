\d .ml

// .ml.registry.util.create.binExpected - Separate the expected values into bins
// @param expected {float[]} The expected data
// @param nGroups {long} The number of groups
// @returns {dict} The splitting values and training distributions
mlops.create.binExpected:{[expected;nGroups]
  expected:@["f"$;expected;{'"Cannot convert the data to floats"}];
  splits:mlops.create.splitData[expected;nGroups],0w;
  expectDist:mlops.create.percSplit[expected;splits];
  (`$string splits)!expectDist
  }

// .ml.registry.util.create.splitData - Split the data into equallly distributed
//    bins
// @param expected {float[]} The expected predictions
// @param nGroups {int} The number of data groups 
// @return {float[]} The splitting points in the expected set
mlops.create.splitData:{[expected;nGroups]
  n:1%nGroups;
  mlops.percentile[expected;-1_n*1+til nGroups]
  }

// .ml.registry.util.create.percSplit - Get the percentage of data points that
//   are in each distribution bin
// @param data {float[]} The data to be split
// @param split {float[]} The splitting values defining how the data is to be
//   distributed 
// @return {float[]} The splitting values and training distributions
mlops.create.percSplit:{[data;splits]
  groups:deltas 1+bin[asc data;splits];
  groups%count data
  }
