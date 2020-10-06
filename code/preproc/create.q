\d .automl
  
// Apply feature creation based on problem type. Individual functions relating to thi
// functionality are use case dependant and contained within [fresh/normal/nlp]/create.q
/* t   = input table
/* p   = parameter dictionary passed as default or modified by user
/* typ = feature creation type (`normal;`fresh)
/* spaths = save paths used for saving word2vec model unused for saveopt = 1
/. r   > dictionary `preptab`preptime!(tab with creation completed;time taken to complete creation)
prep.create:{[t;p;typ;spaths]
  $[typ=`fresh;prep.freshcreate[t;p];
    typ=`normal;prep.normalcreate[t;p];
    typ=`nlp;prep.nlpcreate[t;p;]$[p[`saveopt]in 1 2;spaths[`models]0;(::)];
    '`$"Feature extraction type is not currently supported"]
  }
