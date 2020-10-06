\d .automl

// Save a auto generated report to file
/* params = parameters used in report generation 
/* spaths = save paths for the reports
/* ptype  = problem type (`normal/`fresh)
/* dtdict = date-time dictionary
/. r      > returns save path to console, save to file
post.save_report:{[params;spaths;ptype;dtdict]
  -1 i.runout[`save],i.ssrsv[spaths[1]`report];
  // Retrieve the current directory
  cmd:$[.z.o like "w*";"cd";"pwd"];
  initial_dir:system cmd;
  $[0~checkimport[2];
    @[{latexgen . x};
      (params;dtdict;spaths[0]`report;ptype);
      {[params;err] -1"The following error occurred when attempting to run latex report generation";-1 err,"\n";
       post.report . params;}[(params;dtdict;spaths[0]`report;ptype)]];
    post.report[params;dtdict;spaths[0]`report;ptype]];
  // Move to the original directory location if a failure of tex report generation 
  // has caused the current directory to change without rectification. 
  report_dir:system cmd;
  if[not initial_dir~report_dir;system raze "cd ",initial_dir];
  }

// Save models and model information to file
/* mdls     = table holding the model information
/* dict     = dictionary of hyperparameters
/* mdl_name = model name
/* best_mdl = embedPy model to be saved to disk
/* spaths   = save paths for models/metadata
/* dtdict   = date-time dictionary
/. r        > returns save paths to console and saves models/metadata
post.save_info:{[mdls;dict;mdl_name;best_mdl;spaths;dtdict]
  pylib:?[mdls;enlist(=;`model;enlist mdl_name);();`lib]0;
  mtyp :?[mdls;enlist(=;`model;enlist mdl_name);();`typ]0;
  exmeta:`pylib`mtyp!(pylib;mtyp);
  i.savemdl[mdl_name;best_mdl;mdls;spaths];
  i.savemeta[dict,exmeta;dtdict;spaths];
  }
