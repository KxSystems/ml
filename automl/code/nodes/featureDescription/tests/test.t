\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

-1"\nTesting functionality for generation of symbol encoding schema";

\S 42

// Tables for the testing of covering all encoding combinations
noEncodeTab          :([]10?1f;10?1f;10?5)
oheEncodeTab         :([]10?1f;10?`a`b`c;10?1f)
freqEncodeTab        :([]100?`4;100?1f;100?1f)
oheFreqEncodeTab     :([]100?1f;100?`4;100?`a`b`c;100?1f)
freshNoEncodeTab     :([idx:10?`4]10?1f;10?1f;10?1f)
freshOheEncodeTab    :([idx:10?`4]10?1f;10?`a`b`c;10?1f)
freshFreqEncodeTab   :([idx:100?`4]100?`4;100?1f;100?1f)
freshOheFreqEncodeTab:([idx:100?`4]100?1f;100?`4;100?`a`b`c;100?1f)

// Expected returns for the above tables
noEncodeReturn     :`freq`ohe!``
oheEncodeReturn    :`freq`ohe!(`$();enlist `x1)
freqEncodeReturn   :`freq`ohe!(enlist `x;`$())
oheFreqEncodeReturn:`freq`ohe!(enlist `x1;enlist`x2)

// Any configuration information required to run the function
nonFreshConfig:enlist[`featureExtractionType]!enlist`normal
freshConfig   :enlist[`featureExtractionType]!enlist`fresh

// Generate data lists for testing
nonFreshTabList:(noEncodeTab;oheEncodeTab;freqEncodeTab;oheFreqEncodeTab)
nonFreshData   :{(x;y;z)}[;10;nonFreshConfig]each nonFreshTabList
freshTabList   :(freshNoEncodeTab;freshOheEncodeTab;freshFreqEncodeTab;freshOheFreqEncodeTab)
freshData      :{(x;y;z)}[;10;nonFreshConfig]each nonFreshTabList
targetData     :(noEncodeReturn;oheEncodeReturn;freqEncodeReturn;oheFreqEncodeReturn)

all passingTest[.automl.featureDescription.symEncodeSchema;;0b;]'[nonFreshData;targetData]
all passingTest[.automl.featureDescription.symEncodeSchema;;0b;]'[freshData   ;targetData]


-1"\nTesting for application of function for summarizing feature data";

// Generate test table containing one of each category
testTab:([]a:1 2 1 2;b:`a`b`c`d;c:1 2 1 2f;d:4?0t;e:("abc";"def";"abc";"deg");f:4?0b)

// Generate the summary table to be returned
keyVals :`a`c`b`d`f`e
headers :`count`unique`mean`std`min`max`type
counts  :6#4
unique  :2 2 4 4 2 3
means   :(2#1.5),4#(::)
stdev   :(2#sdev 1 1 2 2),4#(::)
minvals :(1;1f),4#(::)
maxvals :(2;2f),4#(::)
typevals:`numeric`numeric`categorical`time`boolean`text
returnTab:keyVals!flip headers!(counts;unique;means;stdev;minvals;maxvals;typevals)

passingTest[.automl.featureDescription.dataDescription;testTab;1b;returnTab]
