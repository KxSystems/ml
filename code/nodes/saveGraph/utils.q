\d .automl

// Utility functions for saveGraph

// @kind function
// @category saveGraphUtility
// @fileoverview Create regression target distribution plot and save down locally
// @param params    {dict} All data generated during the process
// @param savePath  {str} Path to where plots are to be saved
// @return {null} Target distribution plot saved to appropriate location
saveGraph.i.regTargetPlot:{[params;savePath]
  target:raze params[`ttsObject;`ytrain`ytest];
  utils.plt[`:figure][];
  utils.plt[`:hist][target;`bins pykw 10;`ec pykw"black"];
  saveGraph.i.targetPlot[utils.plt;savePath]
  }


// @kind function
// @category saveGraphUtility
// @fileoverview Create binary target distribution plot and save down locally
// @param params    {dict} All data generated during the process
// @param savePath  {str} Path to where plots are to be saved
// @return {null} Target distribution plot saved to appropriate location
saveGraph.i.classTargetPlot:{[params;savePath]
  target:raze params[`ttsObject;`ytrain`ytest];
  symMap:params[`symMap];
  countGroup:count each group "i"$target;
  reorderGroup:countGroup til count countGroup;
  tgtName:$[count symMap;key[symMap];]til count countGroup;
  utils.plt[`:figure][];
  utils.plt[`:bar][string tgtName;reorderGroup];
  saveGraph.i.targetPlot[utils.plt;savePath]
  }


// @kind function
// @category saveGraphUtility
// @fileoverview Save target plot locally
// @param pltObj    {<} EmbedPy matplotlib object
// @param savePath  {str} Path to where plots are to be saved
// @return {null} Target distribution plot saved to appropriate location
saveGraph.i.targetPlot:{[pltObj;savePath]
  pltObj[`:title]["Target Distribution";`fontsize pykw 12];
  pltObj[`:xlabel]["Target";`fontsize pykw 12];
  pltObj[`:ylabel]["Count";`fontsize pykw 12];
  filePath:savePath,"Target_Distribution.png";
  pltObj[`:savefig][filePath;`bbox_inches pykw"tight"];
  pltObj[`:close][];
  }


// @kind function
// @category saveGraphUtility
// @fileoverview Save confusion matrix
// @param confMatrix {int[]} Confusion matrix
// @param classes    {str} Classes of possible predictions
// @param modelName  {str} Name of best model
// @param savePath   {str} Path to where images are to be saved
// @return {null} Saves confusion matrix to appropriate location
saveGraph.i.displayConfMatrix:{[confMatrix;classes;modelName;savePath]
  colorMap:utils.plt`:cm.Blues;
  subPlots:utils.plt[`:subplots][`figsize pykw 5 5];
  fig:subPlots[`:__getitem__][0];
  ax:subPlots[`:__getitem__][1];
  ax[`:imshow][confMatrix;`interpolation pykw`nearest;`cmap pykw colorMap];
  ax[`:set_title][`label pykw "Confusion Matrix";`fontsize pykw 12];
  tickMarks:til count classes;
  ax[`:xaxis.set_ticks]tickMarks;
  ax[`:set_xticklabels]classes;
  ax[`:yaxis.set_ticks]tickMarks;
  ax[`:set_yticklabels]classes;
  thresh:max[raze confMatrix]%2;
  shape:.ml.shape confMatrix;
  saveGraph.i.addText[confMatrix;thresh;;]. 'cross[til shape 0;til shape 1];
  utils.plt[`:xlabel]["Predicted Label";`fontsize pykw 12];
  utils.plt[`:ylabel]["Actual label";`fontsize pykw 12];
  filePath:savePath,sv["_";string(`Confusion_Matrix;modelName)],".png";
  utils.plt[`:savefig][filePath;`bbox_inches pykw"tight"];
  utils.plt[`:close][];
  } 


// @kind function
// @category saveGraphUtility
// @fileoverview Add text to confusion matrix
// @param confMatrix {int[]} Confusion matrix
// @param thresh     {int} Threshold value
// @param i          {int} Row in the confusion matrix
// @param j          {int} column in the confusion matrix
// @return {null} Adds text to plot
saveGraph.i.addText:{[confMatrix;thresh;i;j]
  color:$[thresh<confMatrix[i;j];`white;`black];
  valueStr:string confMatrix[i;j];
  utils.plt[`:text][j;i;valueStr;`horizontalalignment pykw`center;`color pykw color]
  }


// @kind function
// @category saveGraphUtility
// @fileoverview Create impact plot and save down locally
// @param impact    {float[]} The impact value of each feature
// @param modelName {modelName} Name of best model
// @param savePath  {str} Path to where plots are to be saved
// @return {null} Impact plot saved to appropriate location
saveGraph.i.plotImpact:{[impact;modelName;savePath]
  utils.plt[`:figure][`figsize pykw 20 1.5];
  subPlots:utils.plt[`:subplots][];
  fig:subPlots[@;0];
  ax:subPlots[@;1];
  num:20&count value impact;
  nCount:til num;
  valImpact:num#value impact;
  keyImpact:num#key impact;
  ax[`:barh][nCount;valImpact;`align pykw`center];
  ax[`:set_yticks]nCount;
  ax[`:set_yticklabels]keyImpact;
  ax[`:set_title]["Feature Impact: ",string modelName;`fontsize pykw 12];
  ax[`:set_ylabel]["Columns";`fontsize pykw 12];
  ax[`:set_xlabel]["Relative feature impact";`fontsize pykw 12];
  filePath:savePath,sv["_";string(`Impact_Plot;modelName)],".png";
  utils.plt[`:savefig][filePath;`bbox_inches pykw"tight"];
  utils.plt[`:close][];
  }


// @kind function
// @category saveGraphUtility
// @fileoverview Create residual plot and save down locally
// @param residDict {dict} The resid and true values
// @param modelName {modelName} Name of best model
// @param savePath  {str} Path to where plots are to be saved
// @return {null} Residual plot saved to appropriate location
saveGraph.i.plotResiduals:{[residDict;tts;modelName;savePath]
  resids:residDict[`residuals];
  preds :residDict[`preds];
  true  :tts`ytest;
  subplots:utils.plt[`:subplots][2];
  fig:subplots[@;0];
  ax :subplots[@;1];
  // Padding here ensures that plots don't "step over" each other
  fig[`:tight_layout][`pad pykw 4.0];
  // Actual vs predicted plotting logic
  actual:ax[@;0];
  actual[`:scatter][true;preds;`s pykw 20;`marker pykw "."];
  actual[`:set_title]["Plot of actual vs predicted values";`fontsize pykw 12];
  actual[`:set_xlabel]["Actual values";`fontsize pykw 12];
  actual[`:set_ylabel]["Predicted values";`fontsize pykw 12];
  // Residuals plotting logic
  resid:ax[@;1];
  resid[`:scatter][true;resids;`color pykw "r";`marker pykw "."];
  resid[`:set_title]["Plot of residuals";`fontsize pykw 12];
  resid[`:set_xlabel]["Actual values";`fontsize pykw 12];
  resid[`:set_ylabel]["Residuals";`fontsize pykw 12];
  spacing:.ml.linspace[min true;max true;count true];
  resid[`:plot][spacing;count[true]#0f;"k--"];
  filePath:savePath,sv["_";string(`Regression_Analysis;modelName)],".png";
  utils.plt[`:savefig][filePath;`bbox_inches pykw "tight"];
  utils.plt[`:close][];
  }

// @kind function
// @category saveGraphUtility
// @fileoverview Create data split plot
// @param cfg      {dict} configuration information related to the current run
// @param fileName {str}  Filename to save plot under
// @return {null} Data split plot saved to appropriate location
saveGraph.i.dataSplit:{[config;fileName]
  trn:(trnHld:1.-config`testingSize)*1-config`testingSize;
  sz:1.;
  white :3#255;
  blue  :153 204 255;
  kxBlue:3 112 205;
  utils.plt[`:figure][`figsize pykw 20 3];
  {x[`:barh][.4;y;`color pykw z%255;`edgecolor pykw`black;`linewidth pykw 3];
    }[utils.plt]'[(sz;trnHld;trn);(white;blue;kxBlue)];
  utils.plt[`:title]["Data split";`fontsize pykw 20];
  utils.plt[`:text][trnHld+config[`testingSize]%3;.4;"Test";`fontsize pykw 25];
  utils.plt[`:text][trn+(trnHld-trn)%4;.4;"Holdout";`fontsize pykw 25];
  utils.plt[`:text][trn%3;.4;"Train";`fontsize pykw 25];
  utils.plt[`:xticks][`fontsize pykw 20];
  utils.plt[`:xlim][0.1;1.0];
  utils.plt[`:ylim][0.;0.8];
  utils.plt[`:xlabel][`Percentage;`fontsize pykw 20];
  utils.plt[`:yticks]();
  utils.plt[`:savefig][fileName;`bbox_inches pykw"tight"];
  utils.plt[`:close][];
  }
