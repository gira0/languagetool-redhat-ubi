#!/bin/bash

DIR="/languagetool"
if [ -d "$DIR" ]; then
  echo "${DIR} found! running with ngram data"
  java -cp /opt/languagetool/languagetool-server.jar org.languagetool.server.HTTPServer --languageModel /languagetool --port 8080 --allow-origin '*' --public

else
  echo "${DIR} not found, running without ngram data"
  java -cp /opt/languagetool/languagetool-server.jar org.languagetool.server.HTTPServer --port 8080 --allow-origin '*' --public

fi


