# ARG usage in FROMs has to go up here in global

ARG embedpy_img=kxsys/embedpy:latest

####

FROM $embedpy_img AS embedpy

FROM embedpy AS ml

COPY requirements.txt *.q  README.md LICENSE /opt/kx/ml/
COPY fresh /opt/kx/ml/fresh
COPY util /opt/kx/ml/util
COPY xval /opt/kx/ml/xval
COPY clust /opt/kx/ml/clust
COPY graph /opt/kx/ml/graph
COPY timeseries /opt/kx/ml/timeseries
COPY optimize /opt/kx/ml/optimize
COPY stats /opt/kx/ml/stats

ARG VCS_REF=dev
ARG BUILD_DATE=dev

LABEL	org.label-schema.schema-version="0.1" \
	org.label-schema.name=jupyterq \
	org.label-schema.description="ML toolkit library for kdb+" \
	org.label-schema.vendor="Kx" \
	org.label-schema.license="Apache-2.0" \
	org.label-schema.url="https://code.kx.com/q/ml/toolkit/" \
	org.label-schema.version="${VERSION:-dev}" \
	org.label-schema.vcs-url="https://github.com/KxSystems/ml.git" \
	org.label-schema.vcs-ref="$VCS_REF" \
	org.label-schema.build-date="$BUILD_DATE" \
	org.label-schema.docker.cmd="docker run kxsys/ml"

RUN chown -R kx:kx /opt/kx/ml 
RUN mkdir /opt/kx/q/ml
RUN find /opt/kx/ml -maxdepth 1 -type f -name '*.q' | xargs ln -s -t /opt/kx/q/ml \
        && ln -s -t /opt/kx/q/ml /opt/kx/ml/fresh /opt/kx/ml/utils /opt/kx/ml/xval /opt/kx/ml/clust \
        /opt/kx/ml/graph /opt/kx/ml/timeseries /opt/kx/ml/optimize opt/kx/ml/stats

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
        && conda activate kx \
	&& conda install python=3.8 \
        && pip install pip==21.0.1 \
        && pip install -r /opt/kx/ml/requirements.txt \
        && conda clean -y --all 

USER root

ENTRYPOINT ["/init"]
CMD ["q", "ml/ml.q"]
