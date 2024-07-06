#!/bin/sh

source .env
BUNDLE_ID="com.${COMPANY_NAME}.${PROJECT_NAME}"

OUTPUT_BASE_FILENAME="${PROJECT_NAME}-macOS-${VERSION}"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT="${SCRIPT_DIR}/../.."

# TODO refactor arguments
NOTARIZE=true

TARGET_DIR=$1

if [ -z "$TARGET_DIR" ]; then
  TARGET_DIR="$PROJECT_ROOT/bin"
  echo "no target dir specified - using ${TARGET_DIR}"
else
  TARGET_DIR=$1
  shift
fi

if [ "$1" = "-nn" ]; then
  echo "---- not notarizing"
  NOTARIZE=false
  shift
fi

TMPDIR="./installer-tmp"
mkdir -p $TMPDIR

build_type()
{
    type=$1
    binary=$2
    ident=$3
    loc=$4
    extraSigningArgs=$5

    workdir=$TMPDIR/$type
    mkdir -p $workdir

    if [[ -d "$binary/Contents" ]]; then
      codesign --force -s "$APPLE_APP_CERT" -o runtime --deep --timestamp --digest-algorithm=sha1,sha256 "$binary"
    else
      echo "no contents - not signing binary"
      echo "$binary/Contents"
    fi

    cp -r "$binary" "$workdir"
    ls -l $workdir

    pkgbuild --sign "$APPLE_INSTALL_CERT" --root $workdir --identifier $ident --version ${VERSION} \
              --install-location "$loc" "$TMPDIR/${PROJECT_NAME}_${type}.pkg" || exit 1
    pkgutil --check-signature "$TMPDIR/${PROJECT_NAME}_${type}.pkg"

    codesign --force -s "$APPLE_APP_CERT" -o runtime ${extraSigningArgs} --deep --timestamp \
              --digest-algorithm=sha1,sha256 "$TMPDIR/${PROJECT_NAME}_${type}.pkg"

    rm -rf $workdir
}

mkdir -p "./temp/"

build_type "VST3" ${PROJECT_ROOT}/bin/VST3/*.vst3 "${BUNDLE_ID}.VST3.pkg" "/Library/Audio/Plug-Ins/VST3"
build_type "AU" ${PROJECT_ROOT}/bin/AU/*.component "${BUNDLE_ID}.AU.pkg" "/Library/Audio/Plug-Ins/Components"
build_type "Standalone" ${PROJECT_ROOT}/bin/Standalone/*.app "${BUNDLE_ID}.Standalone.pkg" "/tmp/${COMPANY_NAME}/${RESOURCE_NAME}" \
"--entitlements ${PROJECT_ROOT}/installers/mac/Resources/entitlements.plist"

RESOURCES_DIR="${PROJECT_ROOT}/resources"

# we need to create a file for the resources package to install if there isn't one
# the resources package contains the necessary postinstall script
# productbuild won't add the package if is empty or only contains subdirectories
HAS_RESOURCES=false
if [ -e "$RESOURCES_DIR" ] && find "$RESOURCES_DIR" -type f | read; then
  HAS_RESOURCES=true
fi

# if we don't have resources, we need to create a dummy resources package
# because we're attaching the postinstall script to the resources package, as its the only
# required install target
if [ "$HAS_RESOURCES" = false ]; then
  echo "Creating empty resources for postinstall script"
  mkdir "$RESOURCES_DIR"
  mkdir "$RESOURCES_DIR/user"
  date > "$RESOURCES_DIR/user/timestamp"
  HAS_RESOURCES=true
fi

pkgbuild --sign "$APPLE_INSTALL_CERT" --root "$RESOURCES_DIR" \
--identifier "${BUNDLE_ID}.resources.pkg" --version ${VERSION} \
--scripts "${PROJECT_ROOT}/installers/mac/Resources/postinstall" \
--install-location "/tmp/${COMPANY_NAME}/${RESOURCE_NAME}/resources" "${TMPDIR}/${PROJECT_NAME}_Resources.pkg"

codesign --force -s "$APPLE_APP_CERT" -o runtime --deep --timestamp \
  --digest-algorithm=sha1,sha256 "${TMPDIR}/${PROJECT_NAME}_Resources.pkg"

echo --- Sub Packages Created ---

PKG_REFS=""
for type in VST3 AU Standalone; do
  PKG_REFS="$PKG_REFS
   <pkg-ref id=\"$BUNDLE_ID.$type.pkg\"/>"
done

if [ "$HAS_RESOURCES" = true ]; then
  PKG_REFS="$PKG_REFS
   <pkg-ref id=\"$BUNDLE_ID.resources.pkg\"/>"
fi

PKG_LINE_CHOICES=""
for type in VST3 AU Standalone; do
  PKG_LINE_CHOICES="$PKG_LINE_CHOICES
   <line choice=\"$BUNDLE_ID.$type.pkg\"/>"
done

if [ "$HAS_RESOURCES" = true ]; then
  PKG_LINE_CHOICES="$PKG_LINE_CHOICES
   <line choice=\"$BUNDLE_ID.resources.pkg\"/>"
fi

PKG_CHOICES=""
for type in VST3 AU Standalone; do
  PKG_CHOICES="$PKG_CHOICES
  <choice id=\"$BUNDLE_ID.$type.pkg\"
    visible=\"true\" start_selected=\"true\" title=\"${PLUGIN_NAME} - $type\">\
    <pkg-ref id=\"$BUNDLE_ID.$type.pkg\"/>\
  </choice>\
  <pkg-ref id=\"$BUNDLE_ID.$type.pkg\" version=\"${VERSION}\" \
  onConclusion=\"none\">${PROJECT_NAME}_$type.pkg</pkg-ref>"
done

if [ "$HAS_RESOURCES" = true ]; then
  PKG_CHOICES="$PKG_CHOICES
    <choice id=\"${BUNDLE_ID}.resources.pkg\"
      visible=\"true\" enabled=\"false\" selected=\"true\" title=\"Resources\">
        <pkg-ref id=\"${BUNDLE_ID}.resources.pkg\"/>
    </choice>
    <pkg-ref id=\"${BUNDLE_ID}.resources.pkg\" version=\"${VERSION}\" \
      onConclusion=\"none\">${PROJECT_NAME}_Resources.pkg</pkg-ref>"
fi

cat > $TMPDIR/distribution.xml << XMLEND
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
    <title>${PLUGIN_NAME} v${VERSION}</title>
    <license file="License.txt" />
    <readme file="Readme.rtf" />

    ${PKG_REFS}

    <options require-scripts="false" customize="always" hostArchitectures="x86_64,arm64" rootVolumeOnly="true"/>
    <domains enable_anywhere="false" enable_currentUserHome="false" enable_localSystem="true"/>

    <choices-outline>
      ${PKG_LINE_CHOICES}
    </choices-outline>

    ${PKG_CHOICES}

</installer-gui-script>
XMLEND

pushd ${TMPDIR}
productbuild --sign "$APPLE_INSTALL_CERT" --distribution "distribution.xml" \
            --package-path "." --resources ${PROJECT_ROOT}/installers "$OUTPUT_BASE_FILENAME.pkg"

codesign --force -s "$APPLE_APP_CERT" -o runtime --deep --timestamp \
  --digest-algorithm=sha1,sha256 "$OUTPUT_BASE_FILENAME.pkg"
popd

echo "---- Product archive built ----"

mkdir "${TMPDIR}/${PROJECT_NAME}"
mv "${TMPDIR}/${OUTPUT_BASE_FILENAME}.pkg" "${TMPDIR}/${PROJECT_NAME}"

rm "${TARGET_DIR}/$OUTPUT_BASE_FILENAME.dmg"

hdiutil create "${TARGET_DIR}/${OUTPUT_BASE_FILENAME}.dmg" -ov \
              -fs JHFS+ \
              -volname "${PLUGIN_NAME} Installer" \
              -srcfolder "${TMPDIR}/${PROJECT_NAME}/"

codesign --force -s "$APPLE_APP_CERT" -o runtime --deep --timestamp \
  --digest-algorithm=sha1,sha256 "${TARGET_DIR}/$OUTPUT_BASE_FILENAME.dmg"

codesign --verify --deep --verbose "${TARGET_DIR}/$OUTPUT_BASE_FILENAME.dmg"

echo "---- DMG Built ----"

if [ $NOTARIZE = true ]; then
  echo "Notarizing..."
  xcrun notarytool submit "${TARGET_DIR}/$OUTPUT_BASE_FILENAME.dmg" --apple-id ${APPLE_SIGN_EMAIL} \
                --team-id ${APPLE_TEAM_ID} --password ${APPLE_SIGN_PW} --wait
  xcrun stapler staple "${TARGET_DIR}/${OUTPUT_BASE_FILENAME}.dmg"
fi

echo "Outputted installer to ${TARGET_DIR}/${OUTPUT_BASE_FILENAME}.dmg"

echo "Cleaning up..."
rm -rf ${TMPDIR}
