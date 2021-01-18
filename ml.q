\l p.q /embedPy
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
