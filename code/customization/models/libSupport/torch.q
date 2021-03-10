// code/customization/models/libSupport/torch.q - Customized PyTorch models
// Copyright (c) 2021 Kx Systems Inc
//
// The purpose of this file is to include all the necessary utilities to 
// create a minimal interface for the support of PyTorch models. It also 
// acts as a location to which users defined PyTorch models could be added

\d .automl

// import pytorch as torch
torch:.p.import[`torch];
