/ #define qtemplate(x,y) y
/ qtemplate((name:funcname|types:TYPE1%TYPE2|ptypes:TYPE1=A&B&C%TYPE2=D&E&F),
/ ccode
/ )
/ replacement types must all be upper case, ptypes correspond to possible types for each replacement types
/ e.g. suppose ptypes:TYPE1=F
/ TYPE1 -> F
/ kTYPE1 -> kF
/ ktype1 -> kf
/ somekobject->TYPE1 -> somekobject->f
/ somekobject.TYPE1 -> somekobject.f
/ KTYPE1 -> KF
/ anytok_TYPE1_en -> anytok_F_en
E:"\\";Q:"\"";C:"/"
f:{$[x like "qtemplate<*";g x;x]}
ut:{x[0]+til 1+x[1]-x 0};w:{x in"\t "}; / x until y
fcq:{(-1+count x)^where[(00b{$[x 0;00b;y=E,Q]}\x)[;1]]1}; / find closing quote of string
fc:{sums[sum 1 -1*x=\:Xq y]?0}                            / close brace ind of string y starting with opening paren x[0] and closing with x[y]
qts:{$[Q in x;first(();0;x){$[y<x 1;x;Q~c:x[2]y;(x[0],enlist y,u;1+u:y+fcq y _x 2;x 2);@[x;1;:;y+(y _x 2)?"\n"]]}/asc raze 0 1+x ss/:(Q;"[\t ]/");()]} / intervals of strings in x
Xq:(Xi:{@[y;raze ut each x y;:;"X"]})qts; / XXX out strings

cqt:count qt:"qtemplate"
temp2c:{
 poss:ss[x;"qtemplate"]except count["#define "]+ss[x;"#define qtemplate"];
 chunks:(0,poss)cut x;
 /output:(count[x]^first poss)#x;
 :""{x,process y}/chunks;
 }
process:{$[qt~9#x;processqtemp x;x]}
processqtemp:{
 i:cqt+fc["()";cqt _x];
 td:`$.j.k (cqt+1)_(tdi:x?"|")#x;
 /td:(!/)"S:|"0:(cqt+1)_(tdi:x?csv)#x;
 /td[`types]:`$"%"vs td`types;
 /td[`ptypes]:`$"&"vs'(!/)"S=%"0:td`ptypes;
 if[not {asc[x]~asc y}[td`types;key td`ptypes];'missing];
 typedicts:key[td`ptypes]!/:cross/[{enlist each x}each td`ptypes];
 code:(1+tdi)_i#x;
 nc:munge[string td`names;code]each typedicts;
 raze[nc],1 _ i _ x}
\l p.q
re:.p.import`re
mungename:{
 code:re[`:sub][u,x,u:"([^0-9A-Za-z_])";"\\1",mungename,"\\2";y]`;
 code}
munge:{
 mungenames:{"_"sv(y;"_"sv string value x)}[z]each x;
 code:y{re[`:sub][u,y[0],u:"([^0-9A-Za-z_])";"\\1",y[1],"\\2";x]`}/flip(x;mungenames);
 reps:brep'[key z;value z];
 code:code{ssr[x;y 0;y 1]}/raze reps;
 code} / functions in .. 
brep:{
 x:string x;y:string y;
 ((".",lower x;".",lower y);
  ("->",lower x;"->",lower y);
  ("K",x;"K",y);
  ("k",x;"k",y);
  ("w",lower x;"w",lower y);
  ("k",lower x;"k",lower y);
  ("_",x,"_";"_",y,"_");
  (x;y))}
if[count .z.x;-1 temp2c"c"$read1 hsym`$.z.x 0;exit 0];

