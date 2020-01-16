# ARG usage in FROMs has to go up here in global

ARG embedpy_img=kxsys/embedpy:latest

####

FROM $embedpy_img AS embedpy

FROM embedpy AS nlp

COPY requirements.txt *.q README.md LICENSE /opt/kx/nlp/
COPY vader/ /opt/kx/nlp/vader/

ARG VCS_REF=dev
ARG BUILD_DATE=dev

LABEL	org.label-schema.schema-version="0.1" \
	org.label-schema.name=jupyterq \
	org.label-schema.description="NLP library for kdb+" \
	org.label-schema.vendor="Kx" \
	org.label-schema.license="Apache-2.0" \
	org.label-schema.url="https://code.kx.com/q/ml/nlp/" \
	org.label-schema.version="${VERSION:-dev}" \
	org.label-schema.vcs-url="https://github.com/KxSystems/nlp.git" \
	org.label-schema.vcs-ref="$VCS_REF" \
	org.label-schema.build-date="$BUILD_DATE" \
	org.label-schema.docker.cmd="docker run kxsys/nlp"

RUN chown -R kx:kx /opt/kx/nlp 
RUN mkdir /opt/kx/q/nlp
RUN find /opt/kx/nlp -maxdepth 1 -type f -name '*.q' | xargs ln -s -t /opt/kx/q/nlp \
	&& ln -s -t /opt/kx/q/nlp /opt/kx/nlp/vader 

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda activate kx \
	&& conda install -c conda-forge --file /opt/kx/nlp/requirements.txt \
	&& conda clean -y --all \
	&& python -m spacy download en

USER root

ENTRYPOINT ["/init"]
CMD ["q", "nlp/init.q"]
