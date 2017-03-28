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
- The `docker-compose.yml` file lists the various involved services or components.

## Makefile

There is a Makefile for managing this composition of component:

-   make ... use this for building the image from scratch and starting up the first time (it runs init once and creates db)
-   make clean ... use this for cleaning out and removing stuff completely
-   make stop ... use this to stop a running system
-   make up ... use this to start a stopped system
-   make data ... use this to load test data (Lepidoptera tab separated values by default)

## Loading content

## Questions / issues / discussions
