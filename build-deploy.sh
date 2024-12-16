#!/usr/bin/env bash

export MSYS_NO_PATHCONV=1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

build_aax='true'
skip_build=''
verbose=''

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-aax)
            build_aax=''
            shift
            ;;
        -v|--verbose)
            verbose='true'
            shift
            ;;
        --skip-build)
            skip_build='true'
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$build_aax" != 'true' ]; then
  echo "skipping aax"
fi

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

cd "$SCRIPT_DIR/../"
source ".env"

echo "uploading to DO Spaces..."


aws s3 cp "output/$PROJECT_NAME-win-$VERSION.exe" s3://imagiro/ \
    --endpoint=https://imagiro.nyc3.digitaloceanspaces.com \
    --profile spaces

echo "notifying server..."

curl -s -o /dev/null -d "key=$IMAGIRO_CI_KEY&version=$VERSION&slug=$PROJECT_NAME" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -X POST https://imagi.ro/api/versions/new

echo "finished!"