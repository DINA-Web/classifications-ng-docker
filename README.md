``` console
┏━╸╻  ┏━┓┏━┓┏━┓╻┏━╸╻┏━╸┏━┓╺┳╸╻┏━┓┏┓╻┏━┓   ┏┓╻┏━╸   ╺┳┓┏━┓┏━╸╻┏ ┏━╸┏━┓
┃  ┃  ┣━┫┗━┓┗━┓┃┣╸ ┃┃  ┣━┫ ┃ ┃┃ ┃┃┗┫┗━┓╺━╸┃┗┫┃╺┓╺━╸ ┃┃┃ ┃┃  ┣┻┓┣╸ ┣┳┛
┗━╸┗━╸╹ ╹┗━┛┗━┛╹╹  ╹┗━╸╹ ╹ ╹ ╹┗━┛╹ ╹┗━┛   ╹ ╹┗━┛   ╺┻┛┗━┛┗━╸╹ ╹┗━╸╹┗╸
```

# Introduction

This is a integration project that packages the Classifications module as a set of docker component.

# Usage

A number of files are involved in using this module. 

- The Makefile lists VERBS that start, stop, build services etc. 
- The `docker-compose.yml` file lists the NOUNS ie various involved services or components.

Required system dependencies include `make`, `docker` and `docker-compose`.

## Makefile

There is a Makefile for managing this composition of component:

-   make ... use this for building the image from scratch and starting up the first time (it runs init once and creates db)
-   make clean ... use this for cleaning out and removing stuff completely
-   make stop ... use this to stop a running system
-   make up ... use this to start a stopped system

## Loading content

Content is provided as `nameindex/dwca-dyntaxa.zip` with Dyntaxa data from 2012 in DarwinCore Archive format.

Use `make build` to generate the image, and push to Docker Hub with `make release`.

Use `make dyntaxa-dl` to pull up-to-date Dyntaxa data

## TODO / Questions / issues / discussions

- Refactor the dyntaxa conversion to dwca

