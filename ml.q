// ml.q - Setup for ml namespace
// Copyright (c) 2021 Kx Systems Inc
//
// Define version, path, and loadfile 


@[{system"l ",x;.pykx.loaded:1b};"pykx.q";{@[{system"l ",x;.pykx.loaded:0b};"p.q";{'"Failed to load PyKX or embedPy with error: ",x}]}]
if[.pykx.loaded;.p:.pykx];
if[not `toraw in key `.p;.p.toraw:(::)]

\d .ml
version:@[{TOOLKITVERSION};`;`development]
path:{string`ml^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
loadfile:{$[.z.q;;-1]"Loading ",x:_[":"=x 0]x:$[10=type x;;string]x;system"l ",path,"/",x;}

// The following functionality should be available for all initialized sections of the library

// @private
// @kind function
// @category utility
// @fileoverview If set to `1b` deprecation warnings are ignored
i.ignoreWarning:0b

// @private
// @kind function
// @category utilities
// @fileoverview Change ignoreWarnings
updateIgnoreWarning:{[]i.ignoreWarning::not i.ignoreWarning}
