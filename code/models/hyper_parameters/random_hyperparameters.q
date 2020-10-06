/* Hyperparameter file for random/sobol hyperparameter searching methods.
/  User will pass in hp_typ parameter initially (grid/random) and the type of random search (random/sobol) 
/   must be specified for each model below.
/  Models have been added in `upsert` format so that users can easily modify/add to models.
/*

\d .automl

// Create empty table
hyperparams:([model_name:`$()]hyperparams:();values:())

// Regression hyperparameters
`hyperparams upsert(`AdaBoostRegressor;`n_estimators`learning_rate;((`uniform;10;250;"j");(`uniform;.1;1.;"f")));
`hyperparams upsert(`RandomForestRegressor;`n_estimators`criterion`min_samples_leaf;((`uniform;10;250;"j");(`symbol;`mse`mae);(`uniform;1;10;"j")));
`hyperparams upsert(`GradientBoostingRegressor;`loss`learning_rate`criterion;((`symbol;`ls`lad`huber);(`uniform;.1;1.;"f");(`symbol;`friedman_mse`mse`mae)));
`hyperparams upsert(`KNeighborsRegressor;`n_neighbors`weights;((`uniform;2;100;"j");(`symbol;`uniform`distance)));
`hyperparams upsert(`Lasso;`alpha`normalize`max_iter`tol;((`uniform;.1;1.;"f");`boolean;(`uniform;100;1000;"j");(`uniform;.0001;.1;"f")));
`hyperparams upsert(`MLPRegressor;`activation`solver`alpha`learning_rate_init;((`symbol;`relu`tanh`logistic);(`symbol;`adam`sgd);(`uniform;.0001;1.;"f");(`uniform;.001;1.;"f")));

// Classification hyperparameters
`hyperparams upsert(`AdaBoostClassifier;`n_estimators`learning_rate;((`uniform;10;500;"j");(`uniform;.1;1.;"f")));
`hyperparams upsert(`RandomForestClassifier;`criterion`min_samples_split`min_samples_leaf;((`symbol;`gini`entropy);(`uniform;2;20;"j");(`uniform;1;20;"j")));
`hyperparams upsert(`GradientBoostingClassifier;`learning_rate`n_estimators`criterion;((`uniform;.01;1.;"f");(`uniform;10;500;"j");(`symbol;`friedman_mse`mse)));
`hyperparams upsert(`LogisticRegression;`tol`C;((`uniform;.0001;1.;"f");(`uniform;.1;1.;"f")));
`hyperparams upsert(`KNeighborsClassifier;`n_neighbors`leaf_size`metric;((`uniform;2;20;"j");(`uniform;10;50;"j");(`symbol;enlist`minkowski)));
`hyperparams upsert(`MLPClassifier;`activation`solver`alpha`learning_rate_init;((`symbol;`relu`tanh`logistic);(`symbol;`adam`sgd);(`uniform;.0001;1.;"f");(`uniform;.001;1.;"f")));
`hyperparams upsert(`SVC;`C`degree`tol;((`uniform;.1;1.;"f");(`uniform;2;10;"j");(`uniform;.001;1.;"f")));
`hyperparams upsert(`LinearSVC;`C`tol;((`uniform;.1;1.;"f");(`uniform;.001;1.;"f")));

