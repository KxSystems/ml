system "S ",21_-4_string[.z.p];
\d .ml

fresh.peachcreatefeatures:{
 .z.pd:`u#hopen each .i.prt;
 data:fresh.util.chunktab[x;"j"$.i.slvs];
 cfunc:{fresh.createfeatures[x;y;z _ cols x;fresh.getsingleinputfeatures[]]};
 pdata:cfunc[;y;z] peach data;
 {x uj y}/[();pdata]}


/ utils
fresh.util.chunktab:{{[x;y]flip[[[cols x][0,y]]!x[cols x][0,y]]}[x;]each (y,0N)#1_til count cols x}
.i.n:rand 3000+til 10000
.i.prt:.i.n+til .i.slvs:abs system"s"


/ system execution for opening ports, fresh and logs to the ports
system each ("q ml/init.q -p "),/:string[.i.prt];


// Example:
// This example works given the current path setup and assuming
// ml is placed in $QHOME.
// $ q -s -4
// q)\l peachfresh.q
// q)tab:("SIIIIIII"; enlist ",") 0:`:notebooks/SampleDatasets/waferdata.csv
// q)data:delete time from tab
// q).ml.fresh.peachcreatefeatures[data;`id;1]
~                                                         
