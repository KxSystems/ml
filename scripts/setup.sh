echo $QLIC_K4 | base64 -d > /home/kx/k4.lic
cp /home/kx/.theanorc ~
. /opt/conda/etc/profile.d/conda.sh
conda activate /home/kx/.conda/envs/kx

export QHOME=/home/kx/.conda/envs/kx/q
export QLIC=/home/kx