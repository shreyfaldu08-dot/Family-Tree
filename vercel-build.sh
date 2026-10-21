#!/bin/bash
set -e

echo "=== Preparing Flutter SDK on Vercel ==="
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter stable channel..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "=== Flutter Environment ==="
flutter --version

echo "=== Installing Dependencies ==="
flutter pub get

echo "=== Compiling Flutter Web Application ==="
flutter build web --release

echo "=== Build Complete! Web bundle ready at build/web ==="
