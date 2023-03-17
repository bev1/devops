#!/bin/bash

npm install

export ENV_CONFIGURATION=production

npm run build -- --configuration=$ENV_CONFIGURATION

if [ ! -d dist ]; then
  mkdir dist
fi

if [ -f dist/client-app.zip ]; then
    rm dist/client-app.zip
fi

zip -r dist/client-app.zip dist/*

echo Bild completed