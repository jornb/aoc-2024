FROM gcc:14

WORKDIR /work
RUN echo '#!/bin/bash'>run
RUN echo 'g++ -std=c++20 -O3 -o app "$1"'>>run
RUN echo './app'>>run
RUN chmod +x run
