#!/bin/bash
set -e

# define env variables
export BASE_DIR=~/repos/kilimanjaro-processMessage

# start from scratch
rm -r $BASE_DIR/python
rm -r $BASE_DIR/venv
rm $BASE_DIR/common-lambda-layer.zip

# create venv
python -m venv venv

# activate already created venv
source venv/bin/activate

# create fresh directory
mkdir $BASE_DIR/python
cd $BASE_DIR/python

# install previouse dependencies
pip install -r $BASE_DIR/requirements.txt -t .

# install new dependency
pip install $1 -t .

# create requirements file for next time
pip freeze > $BASE_DIR/requirements.txt

# remove unnecessary files
rm -rf *dist-info

# zip the python directory
cd $BASE_DIR
zip -r common-lambda-layer.zip python

# create aws lambda layer
aws lambda publish-layer-version --layer-name kilimanjaroVR_common \
    --description "Layer with common libraries (requests, regex, ...)" \
    --zip-file fileb://common-lambda-layer.zip \
    --compatible-runtimes python3.7 python3.8 \
    --compatible-architectures "arm64" "x86_64" \
    --profile artur-private