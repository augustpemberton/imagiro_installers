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

if [ "$skip_build" != true ]; then
  echo "building UI..."
  cd ../src/ui/src/
  yarn build || exit 1
  echo "UI built"
fi

cd ../../../installers

printf "\n\nBUILD STARTED ===================================================\n\n" >> build.log

# build
if [ "$skip_build" != true ]; then
  echo "building..."
  bash $os_dir/build.sh $output_redirect
else
  echo "skipping build"
fi

cd "$SCRIPT_DIR/../"

# package
mkdir -p output

printf "\n\nPACKAGING STARTED ===================================================\n\n" >> package.log

if [ "$build_aax" = true ] ; then
  bash installers/$os_dir/package.sh --aax "./output"
else
  bash installers/$os_dir/package.sh "./output"
fi

source ".env"

echo "uploading to DO Spaces..."

output_file="output/$PROJECT_NAME-win-$VERSION.exe"
if [[ $OSTYPE == 'darwin'* ]]; then
  output_file="output/$PROJECT_NAME-macOS-$VERSION.dmg"
fi

aws s3 cp "$output_file" s3://imagiro/ \
    --endpoint=https://imagiro.nyc3.digitaloceanspaces.com \
    --profile spaces \
    --acl public-read

echo "notifying server..."

curl -s -o /dev/null -d "key=$IMAGIRO_CI_KEY&version=$VERSION&slug=$PROJECT_NAME" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -X POST https://imagi.ro/api/versions/new

echo "finished!"