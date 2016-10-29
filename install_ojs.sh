#!/bin/bash

RUN ln -sf /dev/stderr /srv/app/logs/prod.log
RUN ln -sf /dev/stderr /srv/app/logs/dev.log