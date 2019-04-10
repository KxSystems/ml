\d .ml

fresh.sigfeatvals:{[t;sigfeat;id]
  split:{vs["_";string x]}each sigfeat;
  featidx:{where x like"feat*"}each split;
  feat:raze`${x y}'[split;featidx];
  func:{x _ first y}'[split;featidx];
  extFunc:{x[0]:".ml.fresh.feat.",x 0;x}each func;
  featDict:(!).(feat;extFunc);
  vals:{[sig;x;y;z] flip sig!enlist each{[x;y;z]base:(first y;x z);
   $[1>=count y;value base;
    $[-11h~type y[1]:{@[value;x;`$x]}y[1];[r:value base;r y 1];value base,y 1]]
   }[z]'[x;y]}[sigfeat;value featDict;key featDict]each {?[x;enlist(=;y;enlist z);0b;()]}[t;id]each idcol:distinct idcol:t id;
  (flip (enlist id)!enlist idcol)!raze vals}
