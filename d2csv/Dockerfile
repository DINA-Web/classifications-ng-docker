FROM rocker/hadleyverse

USER root

RUN apt-get update && apt-get update && \
	apt-get install -y python-suds python-pip

RUN pip install suds
RUN install2.r --error data.tree

USER rstudio
