// fresh/init.q - Load fresh library
// Copyright (c) 2021 Kx Systems Inc
// 
// FeatuRe Extraction and Scalable Hypothesis testing (FRESH)
// FRESH algorithm implementation (https://arxiv.org/pdf/1610.07717v3.pdf)

.ml.loadfile`:fresh/utils.q
.ml.loadfile`:fresh/feat.q
.ml.loadfile`:fresh/extract.q
.ml.loadfile`:fresh/select.q
.ml.loadfile`:util/utils.q
.ml.loadfile`:util/utilities.q

.ml.i.deprecWarning[`fresh]
