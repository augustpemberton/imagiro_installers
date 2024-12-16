#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

build_aax=''
skip_build=''
verbose=''

while [[ $# -gt 0 ]]; do
    case "$1" in
        --aax)
            build_aax='true'
            shift
            ;;
        -v|--verbose)
            verbose='true'
            shift
            ;;
        -sb|--skip-build)
            skip_build='true'
            shift
            ;;
        *)
            shift
            ;;
    esac
done

os_dir=$([[ "$OSTYPE" == "darwin"* ]] && echo "mac" || echo "win")
output_redirect=$([[ "$verbose" = "true" ]] && echo "" || echo ">/dev/null 2>&1")

# load in creds for signing and notarization
if [[ $OSTYPE == 'darwin'* ]]; then
  source ~/apple_creds.sh
else
  source ~/sign-creds
fi


# build
if [ "$skip_build" != true ]; then
  echo "building..."
  bash $os_dir/build.sh $output_redirect
else
  echo "skipping build"
fi

# package
mkdir -p output

if [ "$build_aax" = true ] ; then
  bash $os_dir/package.sh --aax ./output
else
  bash $os_dir/package.sh ./output
fi

source "$SCRIPT_DIR/../.env"

echo "uploading to DO Spaces..."

aws s3 cp ./output/ s3://imagiro/ \
    --recursive \
    --endpoint=https://imagiro.nyc3.digitaloceanspaces.com \
    --profile spaces

echo "notifying server..."

curl -s -o /dev/null -d "key=$IMAGIRO_CI_KEY&version=$VERSION&slug=$PROJECT_NAME" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -X POST https://imagi.ro/api/versions/new

echo "finished!"