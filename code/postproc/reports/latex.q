// For simplicity of implementation this code is written largely in python
// this is necessary as a result of the excessive use of structures such as with clauses
// which are more difficult to handle via embedPy

\d .automl

// Get python code used in report generation
reportgen:.p.get[`python_latex]

// Latex report generation functionality
/* dict  = dictionary of relevant information for report generation
/* dt    = dictionary containing the start date and time of a run
/* fname = path to which the report is saved
/* ptype = problem type being handled (`class/`reg)
/. r     > this function does not return anything to the q session
/.         a report will be saved to the file fname on successful execution
latexgen:{[dict;dt;fname;ptype]
  // Create appropriately named file
  fname,:"q_automl_report_",ssr[sv["_";string(first[key[dict`model_scores]];dt`sttime)];":";"."];
  // convert the description table description to a pandas df
  descrip:(flip enlist[`column]!enlist key[k]),'value k:dict`describe;
  descrip:.ml.tab2df[descrip][`:round][3];
  // convert achieved scores to a pandas df
  score:flip `model`score!flip key[d],'value d:dict`model_scores;
  score:.ml.tab2df[score][`:round][3];
  // convert grid search parameters to pandas df if appropriate
  if[99h=type dict`hyper_params;
    grid:flip `param`val!flip key[vals],'value vals:dict`hyper_params;
    grid:.ml.tab2df[grid][`:round][3];];
  dict:string each dict;
  dt:string each dt;
  reportgen[dict;dt;`fpath`path!(fname;.automl.path);ptype;descrip;score;grid;i.excludelist];
  }
