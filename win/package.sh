#!/usr/bin/env bash

export MSYS_NO_PATHCONV=1

build_aax=''
output_dir=''
build_type="RelWithDebInfo"

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


# sign standalone
echo "signing standalone with signtool"
echo "=============SIGNING Standalone">>package.log
standalone_binary="build/${PROJECT_NAME}_artefacts/$build_type/Standalone/${PLUGIN_NAME}.exe"
"$SIGNTOOL_PATH" sign \
  /v /debug /fd SHA256 \
  /tr "http://timestamp.acs.microsoft.com" /td SHA256 \
  /dlib "$ACS_DLIB" /dmdf "$ACS_JSON" \
  "$standalone_binary">>package.log

# sign VST3
echo "signing VST3 with signtool"
echo "=============SIGNING VST3">>package.log
vst3_binary="build/${PROJECT_NAME}_artefacts/$build_type/VST3/${PLUGIN_NAME}.vst3/Contents/x86_64-win/${PLUGIN_NAME}.vst3"
"$SIGNTOOL_PATH" sign \
  /v /debug /fd SHA256 \
  /tr "http://timestamp.acs.microsoft.com" /td SHA256 \
  /dlib "$ACS_DLIB" /dmdf "$ACS_JSON" \
  "$vst3_binary">>package.log


# sign AAX
if [ "$build_aax" = true ] ; then
  aax_binary="build/${PROJECT_NAME}_artefacts/$build_type/AAX/${PLUGIN_NAME}.aaxplugin/Contents/x64/${PLUGIN_NAME}.aaxplugin"

  echo "signing AAX with wraptool"
  echo "=============SIGNING AAX">>package.log
  wraptool sign --verbose \
      --signtool "installers/win/build-scripts/aax-signtool.bat" \
      --signid 1 \
      --account $WRAPTOOL_ACC \
      --password $WRAPTOOL_PW \
      --wcguid $WRAPTOOL_ID \
      --in "$aax_binary" \
      --out "$aax_binary"
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
  /DBuildType="$build_type"\
  /DResourceName="$RESOURCE_NAME" \
  /DIncludeAAX="$build_aax">>package.log

# sign installer
echo "signing installer with signtool"
installer_binary="$output_dir/$PRODUCT_SLUG-win-$VERSION.exe"
"$SIGNTOOL_PATH" sign \
  /v /debug /fd SHA256 \
  /tr "http://timestamp.acs.microsoft.com" /td SHA256 \
  /dlib "$ACS_DLIB" /dmdf "$ACS_JSON" \
  "$installer_binary">>package.log
