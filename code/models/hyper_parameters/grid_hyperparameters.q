/* Hyperparameter file for grid hyperparameter searching method.
/  User will pass in hp_typ parameter initially (grid/random)
/  Models have been added in `upsert` format so that users can easily modify/add to models.
/*

\d .automl

// Create empty table
hyperparams:([model_name:`$()]hyperparams:();values:())

// Regression hyperparameters
`hyperparams upsert(`AdaBoostRegressor;`n_estimators`learning_rate;(10 20 50 100 250;.1 .25 .5 .75 .9 1.));
`hyperparams upsert(`RandomForestRegressor;`n_estimators`criterion`min_samples_leaf;(10 20 50 100 250;`mse`mae;1 2 3 4));
`hyperparams upsert(`GradientBoostingRegressor;`loss`learning_rate`criterion;(`ls`lad`huber;.1 .25 .5 .75 .9 1.;`friedman_mse`mse`mae));
`hyperparams upsert(`KNeighborsRegressor;`n_neighbors`weights;(2 5 10 15 20;`uniform`distance));
`hyperparams upsert(`Lasso;`alpha`normalize`max_iter`tol;(.1 .25 .5 .75 1.;01b;100 200 500 1000;.0001 .0005 .001 .005 .01 .1));
`hyperparams upsert(`MLPRegressor;`activation`solver`alpha`learning_rate_init;(`relu`tanh`logistic;`adam`sgd;.0001 .001 .01;.001 .005 .01));

// Classification hyperparameters
`hyperparams upsert(`AdaBoostClassifier;`n_estimators`learning_rate;(10 20 50 100 200 500;.1 .2 .5 1.));
`hyperparams upsert(`RandomForestClassifier;`criterion`min_samples_split`min_samples_leaf;(`gini`entropy;2 5 10;1 2 5));
`hyperparams upsert(`GradientBoostingClassifier;`learning_rate`n_estimators`criterion;(.05 .1 .25 .5;10 50 100 200 500;`friedman_mse`mse));
`hyperparams upsert(`LogisticRegression;`tol`C;(.0001 .0005 .001 .005;.1 .2 .5 1.));
`hyperparams upsert(`KNeighborsClassifier;`n_neighbors`leaf_size`metric;(2 5 10;10 20 50;`minkowski));
`hyperparams upsert(`MLPClassifier;`activation`solver`alpha`learning_rate_init;(`relu`tanh`logistic;`adam`sgd;.0001 .001 .01;.001 .005 .01));
`hyperparams upsert(`SVC;`C`degree`tol;(.1 .2 .5 1.;2 3 4;.001 .005 .01));
`hyperparams upsert(`LinearSVC;`C`tol;(.1 .2 .5 1.;.001 .005 .01));

