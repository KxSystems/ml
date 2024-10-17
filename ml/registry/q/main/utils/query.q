// query.q - Utilities relating to querying the modelStore
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities relating to querying the modelStore
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Check user-defined keys in config and generate the correct format for
// where clauses
//
// @param config {dict} Any additional configuration needed for
//   retrieving the modelStore. Can also be an empty dictionary `()!()`.
// @param whereClause {(fn;symbol;any)[]|()} List of whereClauses. Can
//   initially be an empty list which will be popultated within the below.
//   Individual clauses will contain the function (like/=) to use in
//   the where clause, followed by the column name as a symbol and the
//   associated value to check.
// @param keys2check {symbol[]} List of config keys to check
// @param function {function} `like/=` to be used in where clause
//
// @return {(fn;symbol;any)[]|()} Updated whereClause
registry.util.query.checkKey:{[config;whereClause;key2check;function]
  if[any b:key2check in key config;
    key2check@:where b;
    whereClause,:{(x;z;y z)}[function;config]each key2check
    ];
  whereClause
  }
