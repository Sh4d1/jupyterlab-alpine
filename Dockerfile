FROM python:alpine

USER root

RUN apk add --update --virtual=.build-dependencies alpine-sdk nodejs ca-certificates musl-dev gcc python-dev make cmake g++ gfortran libpng-dev freetype-dev libxml2-dev libxslt-dev --no-cache && apk add --update git tini --no-cache



RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-i18n-2.23-r3.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-bin-2.23-r3.apk && \
    apk add --no-cache glibc-2.23-r3.apk glibc-bin-2.23-r3.apk glibc-i18n-2.23-r3.apk && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h

ENV LANG=C.UTF-8 \
    SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    HOME=/home/jovyan

ADD fix-permissions /usr/bin/fix-permissions
RUN apk add --no-cache bash
RUN adduser -D -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd /etc/group && \
    fix-permissions $HOME

RUN pip install notebook && pip install ipywidgets && pip install jupyterlab
COPY requirements.txt requirements.txt
#RUN pip install -r requirements.txt

EXPOSE 8888

#ENTRYPOINT ["tini", "--"]
CMD ["start.sh"]
COPY start.sh /usr/local/bin/
COPY jupyter_notebook_config.py $HOME/.jupyter/
RUN chown -R jovyan:jovyan $HOME/.jupyter
RUN chmod -R 755 $HOME/.jupyter
USER $NB_UID
RUN fix-permissions /home/$NB_USER
WORKDIR $HOME
#CMD jupyter lab --ip=* --port=8888 --no-browser --notebook-dir=/opt/app/data
