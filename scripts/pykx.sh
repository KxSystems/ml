cp -r /home/kx/.conda/envs/kx/q ~
rm ~/q/p.{q,k} # remove existing symlinks to embedpy
export QHOME=~/q
export QLIC=/home/kx
python -c "import pykx;pykx.install_into_QHOME()"