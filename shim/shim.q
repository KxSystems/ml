// shim.q - pykx / embedpy shim.
// Copyright (c) 2024 Kx Systems Inc
//
// Conditionally load pykx or embedpy.
// Includes additional helpers to improve compatability.


if[not `e in key `.p;
    @[{system"l ",x;.pykx.loaded:1b};"pykx.q";
        {@[{system"l ",x;.pykx.loaded:0b};"p.q";
        {'"Failed to load PyKX or embedPy with error: ",x}]}];
    if[.pykx.loaded;.p,:.pykx]];

// Coerse to string/sym
coerse:{$[11 10h[x]~t:type y;y;not[x]&-11h~t;y;0h~t;.z.s[x] each y;99h~t;.z.s[x] each y;t in -10 -11 10 11h;$[x;string;`$]y;y]}
cstring:coerse 1b;
csym:coerse 0b;

// Ensure plain python string (avoid b' & numpy arrays)
pydstr:$[.pykx.loaded;{.pykx.eval["lambda x:x.decode()"].pykx.topy x};::]
