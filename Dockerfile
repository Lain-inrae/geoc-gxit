# call parent container
#FROM r4.0.0
FROM debian:testing

# set author
MAINTAINER Lain Pavot <lain.pavot@inra.fr>


# set encoding
ENV LANG en_US.UTF-8

## we copy the installer and run it before copying the entier project to prevent
## reinstalling everything each time the project has changed

COPY ./gxit/install.R /tmp/

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV R_BASE_VERSION 4.0.3

RUN \
        apt-get update                                                                                         \
    &&  apt-get install -y --no-install-recommends                                                             \
         ed                                                                                                    \
         procps                                                                                                \
         less                                                                                                  \
         locales                                                                                               \
         file                                                                                                  \
         vim-tiny                                                                                              \
         wget                                                                                                  \
         ca-certificates                                                                                       \
         fonts-texgyre                                                                                         \
    &&  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen                                                            \
    &&  locale-gen en_US.utf8                                                                                  \
    &&  /usr/sbin/update-locale LANG=en_US.UTF-8                                                               \
    &&  echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list       \
    &&  echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default                                   \
    &&  echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/90local-no-recommends                    \
    &&  chmod o+r /etc/resolv.conf                                                                             \
    &&  apt-get update                                                                                         \
    &&  apt-get install -y --no-install-recommends                                                             \
         gcc-9-base                                                                                            \
         r-cran-littler                                                                                        \
         r-base                                                                                                \
         r-base-dev                                                                                            \
         r-recommended                                                                                         \
    &&  Rscript /tmp/install.R                                                                                 \
    &&  apt-get clean autoclean                                                                                \
    &&  apt-get autoremove --yes                                                                               \
    &&  rm -rf /var/lib/{apt,dpkg,cache,log}/                                                                  \
    &&  rm -rf /tmp/*                                                                                          ;


ARG LOG_PATH
ENV LOG_PATH=$LOG_PATH
ARG PORT
ENV PORT=$PORT

ENV PS1="$ "

RUN mkdir -p $(dirname "${LOG_PATH}")
EXPOSE $PORT
COPY ./gxit /gxit
CMD R -e "shiny::runApp('/gxit', host='0.0.0.0', port=${PORT})" 2>&1 > "${LOG_PATH}"
