\d .ml
  
i.loadfname:{[cfg]
  file:hsym`$$[(not ""~cfg`directory)&`directory in key cfg;cfg`directory;"."],"/",cfg`fileName;
  if[()~key file;'"file does not exist"];
  file}

i.loadfunc.splay:i.loadfunc.binary:{[cfg]get i.loadfname cfg}
i.loadfunc.csv:{[cfg](cfg`schema;cfg`separator)0: i.loadfname cfg}
i.loadfunc.json:{[cfg].j.k first read0 i.loadfname cfg}
i.loadfunc.hdf5:{[cfg]
  if[not`hdf5 in key`;@[system;"l hdf5.q";{'"unable to load hdf5 lib"}]];
  if[not .hdf5.ishdf5 fname:i.loadfname cfg;'"file is not an hdf5 file"];
  if[not .hdf5.isObject[fpath;cfg`dname];'"hdf5 dataset does not exist"];
  .hdf5.readData[fpath;cfg`dname]}
i.loadfunc.ipc:{[cfg]
  h:@[hopen;cfg`port;{'"error opening connection"}];
  ret:@[h;cfg`select;{'"error executing query"}];
  @[hclose;h;{}];
  ret}
i.loadfunc.process:{[cfg]if[not `data in key cfg;'"Data to be used must be defined"];cfg[`data]}

i.loaddset:{[cfg]
  if[null func:i.loadfunc cfg`typ;'"dataset type not supported"];
  func cfg}

loaddset:`function`inputs`outputs!(i.loaddset;"!";"+")
