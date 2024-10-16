// delete.q - Functionality for the deletion of items locally
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Delete local items
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category local
// @subcategory delete
//
// @overview
// Delete a registry and the entirety of its contents locally
//
// @param cli {dict} UNUSED
// @param folderPath {string|null} A folder path indicating the location
//   the registry to be deleted or generic null to remove registry in the current
//   directory
// @param config {dict} Information relating to registry being deleted
//
// @return {null}
registry.local.delete.registry:{[folderPath;config]
  config:registry.util.getRegistryPath[folderPath;config];
  registry.util.delete.folder config`registryPath;
  -1 config[`registryPath]," deleted.";
  }
