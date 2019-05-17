\l init.q

\d .ml

plt:  .p.import`matplotlib.pyplot;
dtc:  .p.import[`sklearn.tree]`:DecisionTreeRegressor;
curve:.p.import[`sklearn.model_selection]`:learning_curve;
shuff:.p.import[`sklearn.model_selection]`:ShuffleSplit;
f1   :{2*l*k%((l:precision[x;y;z])+k:sensitivity[x;y;z])};
np:.p.import`numpy;
itertools:.p.import`itertools;
rocCurve:roc;
display:{x y;}.p.import[`kxpy.kx_backend_inline;`:display];



//Inputs a dict of ml algos to apply to the dataset with the names of the algos as keys and the function itself and parameters as the corresonding values.
//The split value is the amount of increasing data that you want to examine
//The output shows the accuracy,fscore and time of each ml algo for each set size
comparevis:{[features;target;dict;split]

 names:key dict;
 fnc:value dict;
  
 ranges:`int$(count target)*{x<1}{x+y}[split]\split;
 

 results:{[f1;yt;xt;fnc;m]
  yt@:til m;
  xt@:til m;
  datadict:.ml.util.traintestsplit[yt;xt;.5];
  {
  [f1;datadict;x]
  t1:.z.t;
  c:x[`:fit]. datadict`xtrain`ytrain;
  pred:c[`:predict;datadict`xtest]`;
  acc:.ml.accuracy[pred;datadict`ytest];
  fs:f1[pred;datadict`ytest;0b];
  t:.z.t-t1;
  (acc;fs;t)
  }[f1;datadict]each fnc
  }[f1;features;target;fnc;]each ranges;


 acc:{x[;0]}each results;
 f1s:{x[;1]}each results;
 tms:{x[;2]}each results;

 subplots:plt[`:subplots][1;3];

 fig:subplots[@;0];
 axarr:subplots[@;1];
 fig[`:set_size_inches;20;8];
 index: til count ranges;
 box:{x[`:__getitem__][y]}[axarr] each til 3;

 {[names;index;ranges;x;y;z]
  
  {[names;index;x;y;z] y[`:bar][index+z*0.2;x[;z];0.2;`alpha pykw 0.8;`label pykw names[z]]}[names;index;x;y]each til count names;
 
  y[`:set_ylabel]z;
  y[`:set_xlabel]"Training set size";
  y[`:set_title](string z) ," on Testing Subset";
  y[`:legend][`loc pykw "best"];

  y[`:set_xticks][index+0.3];
  y[`:set_xticklabels]ranges;
    }[names;index;ranges]'[((enlist acc),(enlist f1s),(enlist tms));box;`Accuracy`f_score`time_ms];

 plt[`:show][];

 }

//Learning curve for decision tree classifier at multiple depths and training set sizes.
//Train/test score shown, with shaded uncertainty region.
//Inputs:
//- features
//- targets
//- depth of tree
//- no of tree splits

treeDepth:{[feat;targ;depth;split]
 
 tree:{dtc[`max_depth pykw x]}each depth;
 cv:shuff[`n_splits pykw 10;`test_size pykw .2;`random_state pykw 0];
 sizes:{x<1}{x+y}[split]\split;

 scores:{[feat;targ;cv;sz;t] 
  curve[t;feat;targ;`train_sizes pykw sz;`cv pykw cv;`scoring pykw"r2"]`
  }[feat;targ;cv;sizes;]each tree;


 szs:scores[;0];
 trn:scores[;1];
 tst:scores[;2];
 avgtrn:{avg each x}each trn;
 avgtst:{avg each x}each tst;
 devtrn:{dev each x}each trn;
 devtst:{dev each x}each tst;
 len:`int$(cd:count depth)%2;
 mat:neg[cd mod 2]_cross[til len;til 2];
 
 subplots:plt[`:subplots][];
 fig:subplots[@;0];
 fig[`:set_figheight]25;
 fig[`:set_figwidth]15;
 
 {[ax;avgtrn;avgtst;devtrn;devtst;szs;depth;n]
  plt[`:subplot2grid][ax,2;n];
  plt[`:plot][szs;avgtrn;"o-";`label pykw"Training Score"];
  plt[`:plot][szs;avgtst;"o-";`label pykw"Testing Score"];
  plt[`:fill_between][szs;avgtrn-devtrn;avgtrn+devtrn;`alpha pykw .15];
  plt[`:fill_between][szs;avgtst-devtst;avgtst+devtst;`alpha pykw .15];
  plt[`:title]"Max Depth ",string depth;
  plt[`:xlabel]"Number of training points";
  plt[`:ylabel]"Score";
  plt[`:xticks]szs;
  plt[`:legend][`loc pykw"best"];
  }[len]'[avgtrn;avgtst;devtrn;devtst;szs;depth;mat];
 plt[`:show][];
 }


//Creates image showing frequency of words in a text
wordcloud:{[text]
 wordcloud:.p.import[`wordcloud]`:WordCloud;
 wc:wordcloud[][`:generate][text]`;
 plt[`:imshow][wc;`interpolation pykw "bilinear"];
 plt[`:show][];
 }



// PLots the accuracy and loss of a neural net as the epochs increases
plotAccMSE:{[accuracy;valAccuracy;loss;valLoss]
    
    subplots:plt[`:subplots][1;2];
    fig:subplots[`:__getitem__]0;
    axarr:subplots[`:__getitem__]1;
    box0:axarr[`:__getitem__]0;
    box1:axarr[`:__getitem__]1;

    fig[`:set_figheight;8];
    fig[`:set_figwidth;15];

    box0[`:plot][accuracy;"r--"];
    box0[`:plot][valAccuracy;"b"];
    box0[`:set_title]`Accuracy;
    box0[`:set_ylabel]"Accuracy %";
    box0[`:set_xlabel]`Epoch;

    box1[`:plot][loss;"r--"];
    box1[`:plot][valLoss;"b"];
    box1[`:set_title]["Mean-Squared Error"];
    box1[`:set_ylabel]["MSE"];
    box1[`:set_xlabel]["Epoch"];
        
    plt[`:legend][`train`test;`loc pykw "right"];
    plt[`:show][];
 }

/Displays a ROC curve
displayROCcurve:{[y;yPredProb]

    // calculating the roc curve and appending it to a dictionary
    rocdict:`frp`tpr`x!rocCurve[y;yPredProb];
    // calculating the auc value
    rocAuc:auc[rocdict`frp; rocdict`tpr];


    lw:2;
    plt[`:plot][rocdict`frp;rocdict`tpr;`color pykw "darkorange";`lw pykw lw;`label pykw "ROC curve (Area = ",string[rocAuc]," )"];
    plt[`:plot][0 1;0 1;`color pykw "navy";`lw pykw lw;`linestyle pykw "--"];

    // customising the plot
    plt[`:xlim][0 1];
    plt[`:ylim][0 1.05];
    plt[`:xlabel]["False Positive Rate"];
    plt[`:ylabel]["True Positive Rate"];
    plt[`:title]["Reciever operating characteristic example"];
    plt[`:legend][`loc pykw "upper left"];
    plt[`:show][];
 }

//Displays a confusion matrix of the classification
displayCM:{[cm;classes;title;cmap]
    
    if[cmap~();cmap:plt`:cm.Blues];
    subplots:plt[`:subplots][`figsize pykw 10 10];
    fig:subplots[`:__getitem__][0];
    ax:subplots[`:__getitem__][1];

    ax[`:imshow][cm;`interpolation pykw `nearest;`cmap pykw cmap];
    ax[`:set_title][`label pykw title];
    tickMarks:til count classes;
    ax[`:xaxis.set_ticks][tickMarks];
    ax[`:set_xticklabels][classes];
    ax[`:yaxis.set_ticks][tickMarks];
    ax[`:set_yticklabels][classes];

    thresh:(max raze cm)%2;
    shp:shape cm;
    {[cm;thresh;i;j] plt[`:text][j;i;(string cm[i;j]);`horizontalalignment pykw `center;`color pykw $[thresh<cm[i;j];`white;`black]]}[cm;thresh;;]. 'cross[til shp[0];til shp[1]];
    plt[`:xlabel]["Predicted Label";`fontsize pykw 12];
    plt[`:ylabel]["Actual label";`fontsize pykw 12];
    fig[`:tight_layout][];
    plt[`:show][];

 }


//
plotGridSequences:{[sequences;labels;text;title]
        
    subplots:plt[`:subplots][4;4];
    fig:subplots[`:__getitem__][0];
    axarr::subplots[`:__getitem__][1];
    fig[`:set_figheight;12];
    fig[`:set_figwidth;15];
    shp:shape sequences;
    
    {[sequences;labels;shp;text;x;y]
      rdlabel:rand shp[0];  
      box:axarr[`:__getitem__].p.eval","sv string x,y;
      box[`:plot][sequences[rdlabel]];
      box[`:set_title]$[text~();[string labels[rdlabel]];text[labels[rdlabel]]];
     }[sequences;labels;shp;text;;]. 'cross[til 4;til 4];

    fig[`:suptitle;title;`fontsize pykw 16];
    plt[`:tight_layout][];
    fig[`:subplots_adjust][`top pykw 0.92];
    plt[`:show][];

 }

//
plotAccXent:{[metrics]
    
    subplots:plt[`:subplots][1;2];
    fig:subplots[`:__getitem__][0];
    axarr:subplots[`:__getitem__][1];
    box0:axarr[`:__getitem__][0];
    box1:axarr[`:__getitem__][1];

    fig[`:set_figheight;8];
    fig[`:set_figwidth;15];

    box0[`:plot][metrics[`:get;<;`acc];"r--"];
    box0[`:plot][metrics[`:get;<;`val_acc];"b"];
    box0[`:set_title]["Accuracy"];
    box0[`:set_ylabel]["Accuracy %"];
    box0[`:set_ylabel]["Epoch"];

    box1[`:plot][metrics[`:get;`loss];"r--"];
    box1[`:plot][metrics[`:get;`val_loss];"b"];
    box1[`:set_title]["Cross Entropy"];
    box1[`:set_ylabel]["Cross Entropy"];
    box1[`:set_ylabel]["Epoch"];
        
    plt[`:legend][`train`test;`loc pykw "right"];
    plt[`:show][];
 }
