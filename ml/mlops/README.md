# MLOps Tools

The purpose of this repository is to act as a central location for common utilities used across the MLOps functionality - Model Training, Monitoring and Packaging.

## Contents

- [Requirements](#requirements)
- [Quick start](#quick-start)
- [File structure](#file-structure)
- [Code Owners](#code-owners)
- [Examples](#examples)
- [Status](#status)


## Requirements

- kdb+ > 3.5
- embedPy

## Quick Start

This quick start guide is intended to show how the functionality can be initialized and run.

### Initialize the code base

From the root of this repository only run the following to initialize the code base

```bash
$ q init.q
```

## File structure

The application consists of an _init.q_ as the entrypoint script.

```bash
$ tree -a
.
├── build
│   ├── mkdocs-py.requirements
│   ├── performance_example.sh
│   ├── postDoc.sh
│   ├── preTest.sh
│   └── test_example.sh
├── ci.json
├── CODEOWNERS
├── CONTRIBUTING.md
├── deps
│   ├── clean.sh
│   ├── install.sh
│   └── qpdeps.json
├── docs
│   ├── api
│   │   ├── doc-layout
│   │   └── index.md
│   ├── css
│   │   └── kx.css
│   ├── doc-layout
│   ├── examples
│   │   ├── doc-layout
│   │   └── index.md
│   ├── images
│   │   ├── favicon.ico
│   │   └── kx.png
│   ├── index.md
│   ├── js
│   │   └── kx.js
│   └── qdoc
│       └── HelloWorld.md
├── docs-template.yml
├── init.q
├── qp.json
├── README.md
├── requirements.txt
├── src
│   ├── lint.config
│   └── q
│       ├── check.q
│       ├── create.q
│       ├── init.q
│       ├── misc.q
│       ├── paths.q
│       └── search.q
│       └── update.q
└── tests
    ├── main.q
    ├── performance
    │   ├── benchmark1
    │   │   └── performance.q
    │   └── load.q
    └── template.quke
```

## Code Owners

A sample `CODEOWNERS` file is included. This provides the ability
to specify certain users as owners and/or approvers of certain parts of the repo.
See [here](https://docs.gitlab.com/ee/user/project/code_owners.html) for more info.


## Example

```q
$ q init.q 
          | ::
init      | ()!()
path      | "/home/deanna/2021projects/mlops-tools"
loadfile  | {
  filePath:_[":"=x 0]x:$[10=type x;;string]x;
  @[system"l ",;
..
check     | ``registry`folderPath`config!(::;{[folderPath;config]
  folderPat..
create    | ``binExpected`splitData`percSplit!(::;{[expected;nGroups]
  expec..
percentile| {[array;perc]
  array:array where not null array;
  percent:perc*..
util      | ``ap!(::;{[func;data]
  $[0=type data;
      func each data;
    ..
infReplace| {[func;data]
  $[0=type data;
      func each data;
    98=type d..
paths     | ``modelFolder!(::;{[registryPath;config;folderType]
  folder:$[fo..
search    | ``model!(::;{[experimentName;modelName;version;config]
  infoKeys..
update    | ``latency`nulls`infinity`csi!(::;{[config;model;data]
  func:{{sy..
```

## Status

This repository is still in active development and is provided here as an alpha version, all code is subject to change.
