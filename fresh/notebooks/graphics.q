\l p.q

\d .ml
plt:.p.import`matplotlib.pyplot
np:.p.import`numpy

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

plotprxpred:{
    plt[`:close][]`;
    plt[`:figure][`figsize pykw (15 7.5)]`;
    plt[`:title][`$"Next day close price prediction"];
    plt[`:plot][x;"r";`label pykw `$"real value"]`;
    plt[`:plot][y;"k--";`label pykw `$"predicted value"]`;
    plt[`:legend][]`;
    plt[`:xlim][200;300]`;
    plt[`:xlabel]["Random predicted date"];
    plt[`:ylabel]["Close Price"];
    plt[`:show][]`;
 }