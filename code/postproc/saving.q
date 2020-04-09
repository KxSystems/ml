\d .automl

// Save a auto generated report to file
/* params = parameters used in report generation 
/* spaths = save paths for the reports
/* ptype  = problem type (`normal/`fresh)
/* dtdict = date-time dictionary
/. r      > returns save path to console, save to file
post.save_report:{[params;spaths;ptype;dtdict]
  -1 i.runout[`save],i.ssrsv[spaths[1]`report];
  post.report[params;dtdict;spaths[0]`report;ptype];
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
