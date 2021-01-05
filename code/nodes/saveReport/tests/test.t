\l automl.q
.automl.loadfile`:init.q

\S 42

-1"\nCreating output directory";

savePath:.automl.utils.ssrWindows .automl.path,"/outputs/testing/report/";
system"mkdir",$[.z.o like "w*";" ";" -p "],savePath;

// Utilities

start:`startDate`startTime!(.z.D;.z.T)

genCfg:{[start;feat;ftype;ptype]
  out:"/outputs/testing/";
  cfg:start,(`featureExtractionType`problemType!(ftype;ptype)),
      .automl.paramDict[`general],.automl.paramDict[ftype],
      enlist[`savedModelName]!enlist`;
  cfg:.automl.dataCheck.updateConfig[feat;cfg];  
  cfg[`reportSavePath]:(.automl.path,out,"report/");
  cfg[`imagesSavePath]:(.automl.path,"/code/nodes/saveReport/tests/images/");
  cfg  
  }[start]
  
applyAndCheck:{[savePath;params;ftype;ptype]
  .automl.saveReport.node.function params;
  report:`$"Report_",string[ftype],@[string ptype;0;upper],".pdf";
  report in key hsym`$savePath
  }[savePath]

// Parameters required in saveReport

savedPlots:`conf`data`impact`target!
  ("Confusion_Matrix.png";"Data_Split.png";"Impact_Plot.png";"Target_Distribution.png")

modelMetaData:`xValTime`metric`modelScores`holdoutScore`holdoutTime!
  (first 1?0t;`.ml.mse;`a`b`c!3?1f;first 1?1f;first 1?0t)

params:`modelMetaData`savedPlots`creationTime`hyperParams`testScore`sigFeats!
  (modelMetaData;savedPlots;first 1?0t;`a`b`c!3?1f;first 1?1f;`x`x1`x2)

// Datasets and corresponding configs/param dictionaries

n:100

featFRESH:([]asc 1000?n;1000?1f;asc 1000?1f)
descFRESH:.automl.featureDescription.dataDescription featFRESH
targFRESHClass :asc n?0b
targFRESHReg   :asc n?1f
confFRESHClass :genCfg[featFRESH;`fresh;`class]
prmsFRESHClass :params,`modelName`config`dataDescription!(`freshClass;confFRESHClass;descFRESH)
confFRESHReg   :genCfg[featFRESH;`fresh;`reg]
prmsFRESHReg   :params,`modelName`config`dataDescription!(`freshReg;confFRESHReg;descFRESH)

featNormal:([]n?1f;n?1f;asc n?1f)
descNormal:.automl.featureDescription.dataDescription featNormal
targNormalClass:asc n?0b
targNormalReg  :asc n?5f
confNormalClass:genCfg[featNormal;`normal;`class]
prmsNormalClass:params,`modelName`config`dataDescription!(`normalClass;confNormalClass;descNormal)
confNormalReg  :genCfg[featNormal;`normal;`reg]
prmsNormalReg  :params,`modelName`config`dataDescription!(`normalReg;confNormalReg;descNormal)

featNLP:([]asc n?`a`b`c;asc n?("yes";"no";"maybe");n?1f;desc n?1f)
descNLP:.automl.featureDescription.dataDescription featNLP
targNLPClass   :asc n?0b
targNLPClass   :asc n?1f
confNLPClass   :genCfg[featNLP;`nlp;`class]
prmsNLPClass   :params,`modelName`config`dataDescription!(`nlpClass;confNLPClass;descNLP)
confNLPReg     :genCfg[featNLP;`nlp;`reg]
prmsNLPReg     :params,`modelName`config`dataDescription!(`nlpReg;confNLPReg;descNLP)

-1"\nRunning tests for saveReport";

applyAndCheck[prmsFRESHClass ;`fresh ;`class]
applyAndCheck[prmsFRESHReg   ;`fresh ;`reg  ]
applyAndCheck[prmsNormalClass;`normal;`class]
applyAndCheck[prmsNormalReg  ;`normal;`reg  ]
applyAndCheck[prmsNLPClass   ;`nlp   ;`class]
applyAndCheck[prmsNLPReg     ;`nlp   ;`reg  ]

-1"\nRemoving any directories created";

rmPath:.automl.utils.ssrWindows .automl.path,"/outputs/testing/";
if[.z.o like "w*";system"timeout 5"];
system"rm -r ",rmPath;
