# ARG usage in FROMs has to go up here in global

ARG embedpy_img=kxsys/embedpy:latest

####

FROM $embedpy_img AS embedpy

FROM embedpy AS automl

COPY requirements.txt *.q README.md LICENSE /opt/kx/automl/
COPY code /opt/kx/automl/code

ARG VCS_REF=dev
ARG BUILD_DATE=dev

LABEL	org.label-schema.schema-version="0.1" \
	org.label-schema.name=jupyterq \
	org.label-schema.description="AUTOML library for kdb+" \
	org.label-schema.vendor="Kx" \
	org.label-schema.license="Apache-2.0" \
	org.label-schema.url="https://code.kx.com/q/ml/automl/" \
	org.label-schema.version="${VERSION:-dev}" \
	org.label-schema.vcs-url="https://github.com/cmccarthy/automl.git" \
	org.label-schema.vcs-ref="$VCS_REF" \
	org.label-schema.build-date="$BUILD_DATE" \
	org.label-schema.docker.cmd="docker run kxsys/automl"

RUN chown -R kx:kx /opt/kx/automl
RUN mkdir /opt/kx/q/automl
RUN find /opt/kx/automl -maxdepth 1 -type f -name '*.q' | xargs ln -s -t /opt/kx/q/automl \
	&& ln -s -t /opt/kx/q/automl /opt/kx/automl/code 

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda activate kx \
	&& conda install --file /opt/kx/automl/requirements.txt \
	&& conda clean -y --all 

USER root

ENTRYPOINT ["/init"]
CMD ["q", "auto/init.q"]
