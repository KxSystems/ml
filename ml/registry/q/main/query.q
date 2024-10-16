// query.q - Main callable functions for querying the modelStore
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Querying the modelStore table. Currently, the below features can
// be referenced by users to query the modelStore table:
// 1. registrationTime
// 2. experimentName
// 3. modelName
// 4. modelType
// 5. version
// 6. uniqueID
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category main
// @subcategory query
//
// @overview
// Query the modelStore
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param config {dict} Any additional configuration needed for
//   retrieving the modelStore. Can also be empty dictionary `()!()`.
//
// @return {table} Most recent version of the modelStore
registry.query.modelStore:{[folderPath;config]
  if[config~(::);config:()!()];
  // Retrieve entire modelStore
  modelStore:registry.get.modelStore[folderPath;config];
  // If no user-defined config return entire modelStore
  k:`modelName`experimentName`modelType`version`registrationTime`uniqueID;
  if[not any k in key config;:modelStore];
  // Generate where clause and query modelStore
  keys2check:(`modelName`experimentName`modelType;enlist`version;`registrationTime`uniqueID);
  whereClause:registry.util.query.checkKey[config]/[();keys2check;(like;{all each x=\:y};=)];
  ?[modelStore;whereClause;0b;()]
  }
