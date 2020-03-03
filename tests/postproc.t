\l automl.q
\d .automl

loadfile`:init.q

// Input Matrix
mattrn:flip (til 5;01010b;asc til 5;7.6 1.2 9.5 8.3 2.4;11001b)
mattst:flip (3 2 1 9 0;10101b;9 8 2 3 4;8.4 3.2 7.9 0.1 2.2;10110b)
data:(mattrn;10101b;mattst;11001b)

// Sklearn model
clf:.p.import[`sklearn.ensemble][`:RandomForestClassifier][`random_state pykw 0]
mdl:clf[`:fit][data 0;data 1]

// Dictionary of impact by column
post.i.impact[0.1 0.5 0.2 0.6 0;`x`x1`x2`x3`x4;desc]~`x3`x1`x2`x`x4!0.4 0.5 0.8 0.9 1f
post.i.impact[0.5 0.4 0.2 0.8 0.7;`x`x1`x2`x3`x4;asc]~`x2`x1`x`x4`x3!0.25 0.5 0.625 0.875 1

// Gain and percentile for gain curve
post.cgcurve[data 3;mdl[`:predict_proba][data 2]`]~([]pc:01b;gain:flip(0 0f;0 1%3;0 1%3;0.5,1%3;0.5,2%3;1 1f);pcnt:(0 0.2 0.4 0.6 0.8 1;0 0.2 0.4 0.6 0.8 1))
