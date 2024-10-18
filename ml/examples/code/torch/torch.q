\d .torch

// Example invocation of a torch model being fit using embedPy
fitModel:{[xtrain;ytrain;model]
  optimArg:enlist[`lr]!enlist 0.9;
  optimizer:.p.import[`torch.optim][`:Adam][model[`:parameters][];pykwargs optimArg];
  criterion:.p.import[`torch.nn][`:BCEWithLogitsLoss][];
  dataX:.p.import[`torch][`:from_numpy][.p.import[`numpy][`:array][xtrain]][`:float][];
  dataY:.p.import[`torch][`:from_numpy][.p.import[`numpy][`:array][ytrain]][`:float][];
  tensorXY:.p.import[`torch.utils.data][`:TensorDataset][dataX;dataY];
  modelValues:(count first xtrain;1b;0);
  modelArgs:`batch_size`shuffle`num_workers!$[.pykx.loaded;.pykx.topy each modelValues;modelValues];
  dataLoader:.p.import[`torch.utils.data][`:DataLoader][tensorXY;pykwargs modelArgs];
  nEpochs:10|`int$(count[xtrain]%1000);
  .p.get[`runmodel][model;optimizer;criterion;dataLoader;nEpochs]
  }
