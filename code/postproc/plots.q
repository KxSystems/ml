\d .automl

//  calculate impact of each feature and save plot of top 20
/* bs   = best model name as a symbol
/* mdl  = best model as a fitted embedPy object or a kdb function
/* data = list containing test features and values
/* cnm  = column names for all columns being shuffled    
/* scf  = scoring function used to determine the best model
/* dt   = dictionary denoting the start time and date of a run
/* fp   = file path dictionaries with the full save path and subsection for printing
/. r    > null value on successful execution with image saved to "output/.../plots"
post.featureimpact:{[bs;mdl;data;cnm;scf;dt;fp;p]
  r:post.i.predshuff[bs;mdl;data;scf;;p`seed]each til count cnm;
  // Appropriate ordering of results
  ord:proc.i.ord scf;
  im:post.i.impact[r;cnm;ord];
  post.i.impactplot[im;bs;dt;fp];
  -1"\nFeature impact calculated for features associated with ",string[bs]," model";
  -1 "Plots saved in ",i.ssrsv[fp[1][`images]],"\n";}

// Print a confusion matrix to output if the problem is a classification problem
/* pred     = Predictions
/* ytest    = Actual values 
/* mdl_name = Name of the model 
/* spaths   = Save paths 
/. r        > Prints confmat to console in classification, will not return otherwise
post.confmat:{[pred;ytest;mdl_name;spaths;dict]
  if[not type[pred]~type[ytest];pred:`long$pred;ytest:`long$ytest];
  -1 i.runout[`cnf];show .ml.conftab[pred;ytest];
  if[dict[`saveopt]in 1 2;
    conf_mat:value .ml.confmat[pred;ytest];
    post.i.displayCM[conf_mat;`$string asc distinct pred,ytest;"";();mdl_name;spaths]];
  }
