// code/nodes/labelEncode/labelEncode.q - Label encoding node
// Copyright (c) 2021 Kx Systems Inc
//
// Apply label encoding on symbolic data returning an encoded version of the
// data in this instance or the original dataset in the case that does not
// require this modification

\d .automl

// @kind function
// @category node
// @desc Encode target data if target is a symbol vector 
// @param target {number[]|symbol[]} Numerical or symbol target vector
// @return {dictionary} Mapping between symbol encoding and encoded target data 
labelEncode.node.function:{[target]
  symMap:()!();
  if[11h~type target;
    encode:.ml.labelEncode.fit target;
    symMap:encode`modelInfo;
    target:encode[`transform] target
    ];
  `symMap`target!(symMap;target)
  }

// Input information
labelEncode.node.inputs:"F"

// Output information
labelEncode.node.outputs:`symMap`target!"!F"
