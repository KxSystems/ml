\d .auto
  
i.savefname:{[cfg]
  file:hsym`$$[`dir in key cfg;cfg`key;"."],"/",cfg fname;
  if[not ()~key file;'"file exists"];
  file}

i.savedset.txt:{[cfg;dset]i.savefname[cfg]0:.h.tx[cfg`typ;dset];}
i.savedset[`csv`xml`xls]:i.savedset.txt
i.savedset.binary:{[cfg;dset]i.savefname[cfg]set dset;}
i.savedset.json:{[cfg;dset]
  h:hopen i.savefname cfg;
  h @[.j.j;dset;{'"error converting to json"}];
  hclose h;}
i.savedset.hdf5:{[cfg;dset]
  if[not`hdf5 in key`;@[system;"l hdf5.q";{'"unable to load hdf5 lib"}]];
  .hdf5.createFile fname:i.savefname cfg;
  .hdf5.writeData[fname;cfg`dname;dset];
  }
i.savedset.splay:{[cfg;dset]
  dname:first` vs fname:i.savefname cfg;
  fname:` sv fname,`;
  fname set .Q.en[dname]dset;}

i.savefunc:{[cfg;dset]
  if[null func:i.savedset cfg`typ;'"dataset type not supported"];
  func dset}

savedset:`function`inputs`outputs!(i.savefunc;`cfg`dset!"!+";" ")
