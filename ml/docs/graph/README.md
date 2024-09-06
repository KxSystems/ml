# ML Graph and Pipeline

The ML Graph and Pipeline library is a structural framework for developing q/kdb+ solutions, based on a mathematical directed graph. In mathematics, and more specifically in graph theory, a directed graph is a set of vertices/nodes/points connected by edges, where the edges have an associated direction as shown in the below example:

![Directed graph](imgs/directed_graph.png) 

By defining code using this core idea a user can develop independent sections of code defined by the nodes and connect them together logically to form a full data analysis pipeline. 

Writing code this way means that:

-   Maintenance of a code base is easier due to the individual elements being independent of each other prior to the connection and validation of the graph. 
-   Once a ‘wire’ version of the graph has been defined by a team, individual nodes can be developed completely independently. This reduces the chance of parallel lines of development causing issues when merging independent sections of code within a large team.
-   Testing of the code can be structured on a per-node basis or by connecting chains of nodes together. This allows for complex code bases to be tested at a more granular level than may otherwise be feasible.
-   Producing fundamental changes to the code base is less cumbersome than in a less modular framework. Adding a new piece of functionality requires only the addition of a new node, and the removal and reattaching of associated edges.

This extension to the Machine Learning Toolkit consists of:

-   [Graphing](graph.md): Create, modify and remove nodes or edges to a graph
-   [Pipelining](pipeline.md): Convert a valid graph into an optimized framework, and execute it to evaluate the logic

Find examples in [../../../examples/](../../../examples/).



## Loading

The graph library can be loaded independently of the other sections of the ML Toolkit:

```q
q)\l ml/ml.q
q).ml.loadfile`:graph/init.q
```
