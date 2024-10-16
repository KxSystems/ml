# ARG usage in FROMs has to go up here in global

FROM registry.gitlab.com/kxdev/kxinsights/data-science/ml-tools/automl:embedpy-gcc-deb12

# Java and jq packages required for registry tests
RUN apt-get update && apt-get install -y openjdk-17-jdk && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/

COPY requirements_pinned.txt /opt/kx/automl/

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
    && conda activate kx \
    && pip install --upgrade pip \
    && conda install -y python=3.11 \
    && conda install -yc conda-forge openblas \
    && printf "[blas]\nldflags = -L/home/kx/.conda/envs/kx/lib -lopenblas\n" > ~/.theanorc \
    && pip install -r /opt/kx/automl/requirements_pinned.txt \
    && pip list \
    && python -m spacy download en_core_web_sm

USER root
