#!/bin/sh

REBUILD=true

# TODO refactor argument parsing

BUILD_TYPE=Release
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT="${SCRIPT_DIR}/../.."

cd $PROJECT_ROOT

# force env to generate if running locally
CI=true

# Build the target
if [ $REBUILD = true ]
  then
    echo "Rebuilding..."
    mkdir -p build
    cmake -B ./build -G Ninja -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
    source .env
    cmake --build ./build --target "${PROJECT_NAME}_All" --config "${BUILD_TYPE}" --parallel 4
fi

# move build artefacts to /bin to make things easier for packaging
rm -rf "bin/"
mkdir -p "bin/"
rm -rf "build/${PROJECT_NAME}_artefacts/${BUILD_TYPE}/JuceLibraryCode"
cp -r "build/${PROJECT_NAME}_artefacts/${BUILD_TYPE}/" "bin"
