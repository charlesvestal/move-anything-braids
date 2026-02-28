#!/usr/bin/env bash
# Build Braids module for Move Anything (ARM64)
#
# Automatically uses Docker for cross-compilation if needed.
# Set CROSS_PREFIX to skip Docker (e.g., for native ARM builds).
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGE_NAME="move-anything-builder"

# Check if we need Docker
if [ -z "$CROSS_PREFIX" ] && [ ! -f "/.dockerenv" ]; then
    echo "=== Braids Module Build (via Docker) ==="
    echo ""

    # Build Docker image if needed
    if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
        echo "Building Docker image (first time only)..."
        docker build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile" "$REPO_ROOT"
        echo ""
    fi

    # Run build inside container
    echo "Running build..."
    docker run --rm \
        -v "$REPO_ROOT:/build" \
        -u "$(id -u):$(id -g)" \
        -w /build \
        "$IMAGE_NAME" \
        ./scripts/build.sh

    echo ""
    echo "=== Done ==="
    exit 0
fi

# === Actual build (runs in Docker or with cross-compiler) ===
CROSS_PREFIX="${CROSS_PREFIX:-aarch64-linux-gnu-}"

cd "$REPO_ROOT"

echo "=== Building Braids Module ==="
echo "Cross prefix: $CROSS_PREFIX"

# Create build directories
mkdir -p build
mkdir -p dist/braids

# Compile Braids source files
echo "Compiling Braids DSP engine..."
BRAIDS_SRCS="
    src/dsp/braids/macro_oscillator.cc
    src/dsp/braids/analog_oscillator.cc
    src/dsp/braids/digital_oscillator.cc
    src/dsp/braids/resources.cc
    src/dsp/braids/quantizer.cc
    src/dsp/stmlib/utils/random.cc
"

for src in $BRAIDS_SRCS; do
    obj="build/$(basename "$src" .cc).o"
    echo "  $src -> $obj"
    ${CROSS_PREFIX}g++ -g -O3 -fPIC -std=c++14 \
        -DTEST \
        -Isrc/dsp \
        -c "$src" \
        -o "$obj"
done

# Compile plugin wrapper
echo "Compiling plugin wrapper..."
${CROSS_PREFIX}g++ -g -O3 -fPIC -std=c++14 \
    -DTEST \
    -Isrc/dsp \
    -c src/dsp/braids_plugin.cpp \
    -o build/braids_plugin.o

# Link shared library
echo "Linking dsp.so..."
${CROSS_PREFIX}g++ -shared \
    build/braids_plugin.o \
    build/macro_oscillator.o \
    build/analog_oscillator.o \
    build/digital_oscillator.o \
    build/resources.o \
    build/quantizer.o \
    build/random.o \
    -o build/dsp.so \
    -lm

# Copy files to dist (use cat to avoid ExtFS deallocation issues with Docker)
echo "Packaging..."
cat src/module.json > dist/braids/module.json
[ -f src/help.json ] && cat src/help.json > dist/braids/help.json
cat build/dsp.so > dist/braids/dsp.so
chmod +x dist/braids/dsp.so

# Include chain patches in dist
if [ -d "src/chain_patches" ]; then
    mkdir -p dist/braids/chain_patches
    for f in src/chain_patches/*.json; do
        [ -f "$f" ] && cat "$f" > "dist/braids/chain_patches/$(basename "$f")"
    done
fi

# Include presets in dist
if [ -d "src/presets" ]; then
    mkdir -p dist/braids/presets
    for f in src/presets/*.braids; do
        [ -f "$f" ] && cat "$f" > "dist/braids/presets/$(basename "$f")"
    done
fi

# Create tarball for release
cd dist
tar -czvf braids-module.tar.gz braids/
cd ..

echo ""
echo "=== Build Complete ==="
echo "Output: dist/braids/"
echo "Tarball: dist/braids-module.tar.gz"
echo ""
echo "To install on Move:"
echo "  ./scripts/install.sh"
