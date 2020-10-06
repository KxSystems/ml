// The purpose of this file is to include all the necessary utilities to create a minimal
// interface for the support of PyTorch models. It also acts as a location to which users defined
// PyTorch models could be added

\d .automl

// import pytorch as torch
torch:.p.import[`torch];

// list all defined PyTorch models defined by the user, here `null as none are to be used by default
i.torchlist:`null;
i.nnlist:i.keraslist,i.torchlist

