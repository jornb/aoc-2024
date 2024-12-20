FROM node:23

WORKDIR /work
RUN npm i @types/node typescript tsx --save
RUN echo '#!/bin/bash'>run
RUN echo 'npm -i @types/node typescript tsx'>>run
RUN echo 'npx tsx "$1"'>>run
RUN chmod +x run
