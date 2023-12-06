# Set image to build upon
FROM rocker/shiny

# set author
MAINTAINER Lain Pavot <lain.pavot@inra.fr>

## we copy the installer and run it before copying the entire project to prevent
## reinstalling everything each time the project has changed

COPY ./gxit/install.R /tmp/

RUN \
        apt-get update                                \
    &&  apt-get install -y --no-install-recommends    \
        fonts-texgyre                                 \
    &&  Rscript /tmp/install.R                        \
    &&  apt-get clean autoclean                       \
    &&  apt-get autoremove --yes                      \
    &&  rm -rf /var/lib/{apt,dpkg,cache,log}/         \
    &&  rm -rf /tmp/*                                 ;


# ------------------------------------------------------------------------------

# These default values can be overridden when we run the container:
#     docker run -p 8080:8080 -e PORT=8080 -e LOG_PATH=/tmp/shiny/gxit.log <container_name>

# We can also bind the container $LOG_PATH to a local directory in order to
# follow the log file from the host machine as the container runs. This command
# will create the log/ directory in our current working directory at runtime -
# inside we will find our Shiny app log file:
#     docker run -p 8888:8888 -e LOG_PATH=/tmp/shiny/gxit.log -v $PWD/log:/tmp/shiny <container_name>

ARG PORT=3838
ARG LOG_PATH=/tmp/gxit/gxit.log

ENV LOG_PATH=$LOG_PATH
ENV PORT=$PORT

# ------------------------------------------------------------------------------

RUN mkdir -p $(dirname "${LOG_PATH}")
EXPOSE $PORT
COPY ./gxit/app.R /srv/shiny-server/

CMD ["exec", "shiny-server", "2>&1", ">", "${LOG_PATH}"]
