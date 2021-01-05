\d .automl

// Apply label encoding on symbolic data returning an encoded version of the
//   data in this instance or the original dataset in the case that does not
//   require this modification

// @kind function
// @category node
// @fileoverview Encode target data if target is a symbol vector 
// @param target {(num[];sym[])} Numerical or symbol target vector
// @return {dict} Mapping between symbol encoding and encoded target data 
labelEncode.node.function:{[target]
  symMap:()!();
  if[11h~type target;
    encode:.ml.labelencode target;
    symMap:encode`mapping;
    target:encode`encoding
    ];
  `symMap`target!(symMap;target)
  }

// Input information
labelEncode.node.inputs  :"F"

// Output information
labelEncode.node.outputs :`symMap`target!"!F"
