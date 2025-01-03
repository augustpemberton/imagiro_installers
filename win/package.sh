#!/usr/bin/env bash

build_aax=''
output_dir=''

while [[ $# -gt 0 ]]; do
    case "$1" in
        --aax)
            build_aax='true'
            shift
            ;;
        *)
            output_dir="$1"
            shift
            ;;
    esac
done


source ~/sign-creds

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT="${SCRIPT_DIR}/../.."

cd $PROJECT_ROOT
source .env

# generate EULA
echo "processing license template"
installers/process-template.sh "$PROJECT_NAME" "installers/License_template.txt" "installers/License.txt">>package.log

# sign AAX
if [ "$build_aax" = true ] ; then
  aax_binary="build/${PROJECT_NAME}_artefacts/Release/AAX/${PLUGIN_NAME}.aaxplugin"

  echo "signing AAX with wraptool"
  wraptool sign --verbose \
      --account $WRAPTOOL_ACC \
      --password $WRAPTOOL_PW \
      --wcguid D469BB60-B2F7-11EF-8D8C-00505692C25A \
      --keyfile "$KEYFILE" \
      --keypassword "$KEYPASS" \
      --extrasigningoptions "digest_sha256" \
      --in "$aax_binary" \
      --out "$aax_binary">>package.log
fi

export MSYS_NO_PATHCONV=1

echo "creating innosetup installer..."
# create installer
iscc installers/win/installer.iss \
  /O"$output_dir" \
  /DProjectName="$PROJECT_NAME" \
  /DProductSlug="$PRODUCT_SLUG" \
  /DPluginName="$PLUGIN_NAME" \
  /DVersion="$VERSION" \
  /DPublisher="$COMPANY_NAME" \
  /DBuildType=Release \
  /DResourceName="$RESOURCE_NAME" \
  /DIncludeAAX="$build_aax">>package.log
