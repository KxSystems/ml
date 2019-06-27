\d .ml

pickledump:.p.import[`pickle;`:dumps;<]
pickleload:.p.import[`pickle;`:loads]
picklewrap:{[b;x]$[b;{.ml.pickleload y}[;pickledump x];{y}[;x]]}
