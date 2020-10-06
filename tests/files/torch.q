\d .automl

// import pytorch as torch
npa    :.p.import[`numpy]`:array
torch  :.p.import`torch
optim  :.p.import`torch.optim
dloader:.p.import[`torch.utils.data]`:DataLoader
.p.set[`nn;nn:.p.import`torch.nn]
.p.set[`F;.p.import`torch.nn.functional]

torchmdl:{[d;s;mtype]
  classifier:.p.get`classifier;
  classifier[count first d[0]0;200]
  }

torchpredict:{[d;m]
  d_x:torch[`:from_numpy][npa d[1]0][`:float][];
  {(.p.wrap x)[`:detach][][`:numpy][][`:squeeze][]`}last torch[`:max][m d_x;1]`
  }

torchfit:{[d;m]
  optimizer:optim[`:Adam][m[`:parameters][];pykwargs enlist[`lr]!enlist .9];
  criterion:nn[`:BCEWithLogitsLoss][];
  data_x:torch[`:from_numpy][npa d[0]0][`:float][];
  data_y:torch[`:from_numpy][npa d[0]1][`:float][];
  tt_xy:torch[`:utils.data][`:TensorDataset][data_x;data_y];
  mdl:.p.get`runmodel;
  pyinputs:pykwargs`batch_size`shuffle`num_workers!(count first d[0]0;1b;0);
  mdl[m;optimizer;criterion;dloader[tt_xy;pyinputs];10|`int$count[d[0]0]%1000]
  }

i.torchlist:`Pytorch
i.nnlist:i.keraslist,i.torchlist