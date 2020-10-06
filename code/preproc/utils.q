\d .automl

// For the following code the parameter naming convention
// defined here is applied to avoid repetition throughout the file
/* t   = input table
/* typ = symbol type of the problem being solved (this determines accepted types)
/* tgt = target data
/* p   = parameter dictionary passed as default or modified by user
/* c   = columns to apply the transformation, if c~(::) then apply to all appropriate columns 


// Utilities for preproc.q

// Automatic type checking
/. r   > the table with acceptable types only and error message with removed columns named
prep.i.autotype:{[t;typ;p]
  $[typ in `tseries`normal;
    [cls:.ml.i.fndcols[t;"sfihjbepmdznuvt"];
      tb:flip cls!t cls;
      prep.i.errcol[cols t;cls;typ]];
    typ=`fresh;
    // ignore the aggregating columns for FRESH as these can be of any type
    [aprcls:flip(l:p[`aggcols])_ flip t;
      cls:.ml.i.fndcols[aprcls;"sfiehjb"];
      // restore the aggregating columns 
      tb:flip(l!t l,:()),cls!t cls;
      prep.i.errcol[cols t;cols tb;typ]];
    typ=`nlp;
    [cls:.ml.i.fndcols[t;"sfihjbepmdznuvtC"];
      tb:flip cls!t cls;prep.i.errcol[cols t;cls;typ]];
    '`$"This form of feature extraction is not currently supported"];
  tb}

// Description of tabular data
/. r > keyed table with information about each of the columns
prep.i.describe:{[t]
  columns :`count`unique`mean`std`min`max`type;
  numcols :.ml.i.fndcols[t;"hijef"];
  timecols:.ml.i.fndcols[t;"pmdznuvt"];
  boolcols:.ml.i.fndcols[t;"b"];
  catcols :.ml.i.fndcols[t;"s"];
  textcols:.ml.i.fndcols[t;"C"];
  num  :prep.i.metafn[t;numcols ;(count;{count distinct x};avg;sdev;min;max;{`numeric})];
  symb :prep.i.metafn[t;catcols ;prep.i.nonnumeric[{`categorical}]];
  times:prep.i.metafn[t;timecols;prep.i.nonnumeric[{`time}]];
  bool :prep.i.metafn[t;boolcols;prep.i.nonnumeric[{`boolean}]];
  text :prep.i.metafn[t;textcols;prep.i.nonnumeric[{`text}]];
  flip columns!flip num,symb,times,bool,text
  }

// Length checking to ensure that the table and target are appropriate for the task being performed
/. r > on successful execution returns null, will return error if execution unsuccessful
prep.i.lencheck:{[t;tgt;typ;p]
  $[-11h=type typ;
    $[`fresh=typ;
      // Check that the number of unique aggregating sets is the same as number of targets
      if[count[tgt]<>count distinct $[1=count p`aggcols;t[p`aggcols];(,'/)t p`aggcols];
         '`$"Target count must equal count of unique agg values for fresh"];
      typ in`tseries`normal`nlp;
      if[count[tgt]<>count t;
         '`$"Must have the same number of targets as values in table"];
    '`$"Input for typ must be a supported type"];
    '`$"Input for typ must be a supported symbol"]}

prep.i.tgtcheck:{[tgt]
  if[not 0<var tgt;'"Target must have more than one unique value"]
  }

// Null encoding of table
/* fn = function to be applied to column from which the value to fill nulls is derived (med/min/max)
/. r  > the table will null values filled if required
prep.i.nullencode:{[t;fn]
  vals:l k:where 0<sum each l:flip null t;
  nms:`$string[k],\:"_null";
  // 0 filling needed if return value also null (encoding maintained through added columns)
  $[0=count k;t;flip 0^(fn each flip t)^flip[t],nms!vals]}

//  Symbol encoding function allowing encoding scheme to be persisted or encoding to be applied
/* n   = number of distinct values in a column after which we frequency encode
/* b   = boolean flag indicating if table is to be returned (0) or encoding type returned (1)
/* enc = how encoding is to be applied, if dictionary outlining encoding perform encoding accordingly
/*       otherwise, return a table with symbols encoded appropriately on all relevant columns
/*       or the dictionary outlining how the encoding would be performed (based on 'b' above)
/. r   > the data encoded appropriately for the task table with symbols 
/.       encoded or dictionary denoting how to encode the data (based on 'b' above)
prep.i.symencode:{[t;n;b;p;enc]
  $[99h=type enc;
    r:$[`fresh~p`typ;
        // Both frequency and one hot encoding is to be applied if true
        $[all {not ` in x}each value enc;
          // Encoding for FRESH is performed on aggregation sub table basis not entire columns
          .ml.onehot[raze .ml.freqencode[;enc`freq]each flip each 0!p[`aggcols]xgroup t;enc`ohe];
          // one hot encode if freq is empty
          ` in enc`freq;.ml.onehot[t;enc`ohe];
          // frequency encode if ohe is empty
          ` in enc`ohe;raze .ml.freqencode[;enc`freq]each flip each 0!p[`aggcols]xgroup t;
          t];
        p[`typ]in`nlp`normal;
        $[all {not ` in x}each value enc;
          .ml.onehot[.ml.freqencode[t;enc`freq];enc`ohe];
          ` in enc`freq;.ml.onehot[t;enc`ohe];
          ` in enc`ohe;raze .ml.freqencode[t;enc`fc];
          t];
        '`$"This form of encoding has yet to be implemented for the specified type of automl"];
    [sc:.ml.i.fndcols[t;"s"]except $[tp:`fresh~p`typ;acol:p`aggcols;(::)];
      // if no symbol columns return table or empty encoding schema
      if[0=count sc;r:$[b=1;`freq`ohe!``;t]];
      if[0<count sc;
        // list of frequency encoding columns
        fc:where n<count each distinct each sc!flip[t]sc;
        ohe:sc where not sc in fc;
        // return encoding schema or appy encoding as appropriate
        r:$[b=1;`freq`ohe!(fc;ohe);
            tp;.ml.onehot[raze .ml.freqencode[;fc]each flip each 0!acol xgroup t;ohe];
            .ml.onehot[.ml.freqencode[t;fc];ohe]]];
      if[b=0;r:flip sc _ flip r]]];
  r}


// Utils.q utilities

// Error flag for removal of inappropriate columms
/* cl = entire column list
/* sl = sublist of columns to be used
prep.i.errcol:{[cl;sl;typ]
  if[count[cl]<>count sl;
  -1 "\n Removed the following columns due to type restrictions for ",string typ;
  0N!cl where not cl in sl]}

// Metadata information based on list of transforms and supplied columns
/* sl = sub list of columns to apply functions to
/* fl = list of functions which will provide the appropriate metadata
/. r  > dictionary with the appropriate metadata returned
prep.i.metafn:{[t;sl;fl]$[0<count sl;fl@\:/:flip(sl)#t;()]}

// Default list of functions to be applied in metadata function for non-numeric data
prep.i.nonnumeric:{[t](count;{count distinct x};{};{};{};{};t)}

