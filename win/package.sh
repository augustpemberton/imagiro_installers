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

# generate EULA
installers/process-template.sh "$PROJECT_NAME" "installers/License_template.txt" "installers/License.txt"

# sign AAX
if [ "$build_aax" = true ] ; then
  aax_binary="build/${PROJECT_NAME}_artefacts/Release/AAX/${PLUGIN_NAME}.aaxplugin"

  echo "Signing AAX with WRAPTOOL: $aax_binary"
  wraptool sign --verbose \
      --account $WRAPTOOL_ACC \
      --password $WRAPTOOL_PW \
      --wcguid D469BB60-B2F7-11EF-8D8C-00505692C25A \
      --keyfile "C:\Users\August\imagiroAAX.pfx" \
      --keypassword "Dd7f715fd1" \
      --extrasigningoptions "digest_sha256" \
      --in "$aax_binary" \
      --out "$aax_binary"
fi

# create installer
iscc installers/win/installer.iss \
  //O"$output_dir" \
  //DProjectName="$PROJECT_NAME" \
  /DPluginName="$PLUGIN_NAME" \
  //DVersion="$VERSION" \
  //DPublisher="$COMPANY_NAME" \
  //DBuildType=Release \
  //DResourceName="$RESOURCE_NAME" \
  //Dinclude_aax="$aax"
