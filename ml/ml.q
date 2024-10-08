// ml.q - Setup for ml namespace
// Copyright (c) 2021 Kx Systems Inc
//
// Define version, path, and loadfile


\d .ml

if[not `e in key `.p;
    @[{system"l ",x;.pykx.loaded:1b};"pykx.q";
        {@[{system"l ",x;.pykx.loaded:0b};"p.q";
        {'"Failed to load PyKX or embedPy with error: ",x}]}]];

if[not `loaded in key `.pykx;.pykx.loaded:`import in key `.pykx];
if[.pykx.loaded;.p,:.pykx];

// Coerse to string/sym
coerse:{$[11 10h[x]~t:type y;y;not[x]&-11h~t;y;0h~t;.z.s[x] each y;99h~t;.z.s[x] each y;t in -10 -11 10 11h;$[x;string;`$]y;y]}
cstring:coerse 1b;
csym:coerse 0b;

// Ensure plain python string (avoid b' & numpy arrays)
pydstr:$[.pykx.loaded;{.pykx.eval["lambda x:x.decode()"].pykx.topy x};::]

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
