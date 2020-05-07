\d .ml

/ values between x and y in steps of length z
arange:{x+z*til 0|ceiling(y-x)%z}
/ combinations of k elements from 0,1,...,n-1
combs:{[n;k]flip(k-1){[n;x]j@:i:where 0<>k:n-j:1+last x;(x@\:where k),enlist -1_sums@[(1+sum k i)#1;0,sums k i;:;(j,0)-0,-1+j+k i]}[n]/enlist til n}
/ identity matrix
eye:{@[x#0.;;:;1.]each til x}
/ indexing functions
imax:{x?max x}
imin:{x?min x}
/ z evenly spaced values between x and y
linspace:{x+til[z]*(y-x)%z-1}
/ shape of matrix/table
shape:{-1_count each first scan x}
/ split into train/test sets with sz% in test
traintestsplit:{[x;y;sz]`xtrain`ytrain`xtest`ytest!raze(x;y)@\:/:(0,floor n*1-sz)_neg[n]?n:count x}

/ q vector to numpy datetime
i.q2npdt:{.p.import[`numpy;`:array;("p"$@[4#+["d"$0];-16+type x]x)-"p"$1970.01m;"datetime64[ns]"]`.}
/ q tab to pandas dataframe
tab2df:{
 r:.p.import[`pandas;`:DataFrame;@[flip 0!x;i.fndcols[x]"pmdznuvt";i.q2npdt]][@;cols x];
 $[count k:keys x;r[`:set_index]k;r]}
/ pandas dataframe to q tab
df2tab_tz:{
 n:$[enlist[::]~x[`:index.names]`;0;x[`:index.nlevels]`];
 c:`$(x:$[n;x[`:reset_index][];x])[`:columns.to_numpy][]`;
 d:x[`:select_dtypes][pykwargs enlist[`exclude]!enlist`float32`datetime`datetimetz`timedelta][`:to_dict;`list]`;
 d,:dt_convert x[`:select_dtypes][`include pykw`datetime];
 d,:dt_dict[x[`:select_dtypes][`include pykw`timedelta]]+"n"$0;
 d,:tz_convert[;y]x[`:select_dtypes][`include pykw`datetimetz];
 d,:float32_convert[;y]x[`:select_dtypes][`include pykw`float32][`:to_dict;`list]`;
 / check if the first value in columns are foreign
 if[0<count dti:where 112h=type each first each value d;
    d,:dtk!date_time_convert[;z] each d dtk:key[d]dti];
 n!flip c#d}
/ Convert python float32 function to produce correct precision without conversion to real
/ note check for x~()!() which is required in cases where underlying representation is float32 for dates/times
float32_convert:{$[(y~0b)|x~()!();x;?[0.000001>x;"F"$string x;0.000001*floor 0.5+x*1000000]]}
/ Convert time zone data (0b -> UTC time; 1b -> local time)
tz_convert:{$[y~0b;dt_convert;{"P"$neg[6]_/:'x[`:astype;`str][`:to_dict;<;`list]}]x}
/ Convert datetime/datetimetz to timestamp
dt_convert:{"p"$dt_dict[x]+1970.01.01D0}
/ Convert data to integer representation and return as a dict
dt_dict:{x[`:astype;`int64][`:to_dict;<;`list]}
/ Convert datetime.date/time types to kdb+ date/time
date_time_convert:{
  $[y~0b;x;
    [ fval:.p.wrap first x;
     / convert datetime.time/date to iso string format and convert to kdb+
     / otherwise return foreign
     $[i.isinstance[fval;i.dt`:time];{"N"$.p.wrap[x][`:isoformat][]`}each x;
       i.isinstance[fval;i.dt`:date];{"D"$.p.wrap[x][`:isoformat][]`}each x;
       x]]]}
/ function defaults to return UTC timezone(y) and non converted date/times(z)
df2tab:df2tab_tz[;0b;0b]

/ apply to list, mixed list, dictionary, table, keyed table
i.ap:{$[0=type y;x each y;98=type y;flip x each flip y;99<>type y;x y;98=type key y;key[y]!.z.s value y;x each y]}
/ find columns of x with type in y
i.fndcols:{m[`c]where(m:0!meta x)[`t]in y}
/ required python utilities for df2tab
i.isinstance:.p.import[`builtins][`:isinstance;<]
i.dt        :.p.import[`datetime]
