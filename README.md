GxIT
=======

This tool is a very simple GxIT, with code based on:
 - https://github.com/rstudio/shiny-examples/blob/master/001-hello/app.R
 - https://github.com/rstudio/shiny-examples/blob/master/009-upload/app.R
 - https://github.com/rstudio/shiny-examples/blob/master/010-download/app.R

Requirement
-----------

 - [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
 - [docker](https://docs.docker.com/engine/install/)


Deploy
------

 - `git clone https://github.com/Lain-inrae/geoc-gxit.git`
 - `cd geoc-gxit`
 - `make docker`


Test
----
 - `make it`
 - `## Then go to 127.0.0.1:8765`


Update
-------------

 - `git pull --rebase`
 - `make docker`


Run
---

 - `make it ## run docker in interactive mode `
 - `make d ## run docker in detached mode `
 - `make sh ## to connect to the docker while it's running `
 - `make log ## to show Xseeker's logs while it's running `


Metadata
--------

 - **@name**: geoc-gxit
 - **@version**: 1.0.0
 - **@authors**: Lain Pavot · lain.pavot@inrae.fr · https://github.com/Lain-inrae
 - **@date creation**: 21/06/2021
