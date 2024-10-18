# MLOps Tools

The purpose of this repository is to act as a central location for common utilities used across the MLOps functionality - Model Training, Monitoring and Packaging.

## Contents

- [Requirements](#requirements)
- [Quick start](#quick-start)
- [File structure](#file-structure)
- [Examples](#examples)


## Requirements

- kdb+ > 3.5
- embedPy
- pykx

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
├── init.q
├── README.md
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
