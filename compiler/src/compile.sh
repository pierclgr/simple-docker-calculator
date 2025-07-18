#!/bin/bash

set -e

# Absolute path to repo root
REPO_ROOT=$(git rev-parse --show-toplevel)

VENV_DIR=$(dirname "$0")/../venv
if [ ! -d "$VENV_DIR" ] || [ ! -f "$VENV_DIR/bin/activate" ]; then
    echo "❌ Virtual environment not found in '$VENV_DIR'. Please create it first with:"
    echo "   python3 -m venv $VENV_DIR"
    exit 1
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

while [[ $# -gt 0 ]]; do
  case $1 in
    --src)
      SRC_DIR="$2"
      shift 2
      ;;
    --dst)
      OUT_DIR="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --all)
      COMPILE_ALL="--all"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Set defaults if not set
BRANCH=${BRANCH:-main}

if ! git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    echo "❌ Git branch '$BRANCH' does not exist."
    exit 1
fi

REL_SRC_DIR="${SRC_DIR#$REPO_ROOT/}"

if [ -z "$SRC_DIR" ] || [ -z "$OUT_DIR" ]; then
    echo "Usage: $0 [--all] --src <source_directory> --dst <output_directory> [--branch branch]"
    exit 1
fi

if ! command -v cython >/dev/null || ! command -v python3 >/dev/null; then
    echo "❌ Cython or Python3 not found in the virtual environment."
    echo "   Please install them using: pip install cython setuptools"
    exit 1
fi

mkdir -p "$OUT_DIR"

# Function to check if a .so file exists for a given .py file
check_so_exists() {
    local py_file="$1"
    local rel_path="${py_file#$SRC_DIR/}"
    local base_name="${rel_path%.py}"

    # Check if any .so file exists that matches the base name (with potential suffixes)
    find "$OUT_DIR" -path "*/${base_name}*.so" | head -1 | grep -q .
}

# Determine files to compile or delete
TO_COMPILE=()
TO_DELETE=()

# Compile everything if --all is passed or it's the first commit
if [ "$COMPILE_ALL" == "--all" ] || ! git rev-parse "${BRANCH}~1" >/dev/null 2>&1; then
    echo "🚀 Compiling all .py files in $SRC_DIR..."

    # since we're compiling everything, we can delete everything in the build folder
    rm -rf "$OUT_DIR"/*

    while IFS= read -r line; do
        TO_COMPILE+=("$line")
    done < <(find "$SRC_DIR" -type f -name "*.py" ! -name "__init__.py")

else
    echo "🔍 Detecting changes between last two commits on $BRANCH branch..."

    CHANGES=()
    while IFS= read -r line; do
        CHANGES+=("$line")
    done < <(git diff --name-status --no-renames "${BRANCH}~1" "${BRANCH}" | grep -i '\.py$')

    if [ ${#CHANGES[@]} -gt 0 ]; then
        echo "📦 Found ${#CHANGES[@]} change(s):"
        for f in "${CHANGES[@]}"; do
            status=$(echo "$f" | cut -f1)
            file=$(echo "$f" | cut -f2)
            echo "- $status: $file"
        done

        # Process git changes first
        for change in "${CHANGES[@]}"; do
            status=$(echo "$change" | cut -f1)
            file=$(echo "$change" | cut -f2)

            if [[ "$file" != "$REL_SRC_DIR/"* ]]; then
                continue
            fi

            base_rel="${file#$REL_SRC_DIR/}"
            so_file="$OUT_DIR/${base_rel%.py}.so"

            case "$status" in
                A|M)
                    if [[ "$(basename "$file")" != "__init__.py" ]]; then
                        TO_COMPILE+=("$file")
                    fi
                    ;;
                D)
                    if [[ "$(basename "$file")" != "__init__.so" ]]; then
                        TO_DELETE+=("$so_file")
                    fi
                    ;;
            esac
        done
    else
        echo "➖ No changes detected."
    fi

    # Check for missing .so files
    echo "🔍 Checking for missing .so files..."
    MISSING_FILES=()

    while IFS= read -r py_file; do
        if [[ "$(basename "$py_file")" != "__init__.py" ]]; then
            if ! check_so_exists "$py_file"; then
                py_file="${py_file#$REPO_ROOT/}"
                MISSING_FILES+=("$py_file")
            fi
        fi
    done < <(find "$SRC_DIR" -type f -name "*.py")

    if [ ${#MISSING_FILES[@]} -gt 0 ]; then
        echo "📦 Found ${#MISSING_FILES[@]} file(s) missing .so equivalents:"
        for f in "${MISSING_FILES[@]}"; do
            echo " - $f"
        done

        # Add missing files to compilation list (avoid duplicates)
        for missing_file in "${MISSING_FILES[@]}"; do
            if [[ ! " ${TO_COMPILE[*]} " =~ " ${missing_file} " ]]; then
                TO_COMPILE+=("$missing_file")
            fi
        done
    else
        echo "➖ No missing .so files found."
    fi

    # Remove deleted files
    for sof in "${TO_DELETE[@]}"; do
        # Use glob to delete all matching variant .so files
        echo "🗑️ Removing $sof"
        rm -rf "$OUT_DIR/$sof"
    done

    if [ ${#TO_COMPILE[@]} -eq 0 ]; then
        echo "➖ No new, modified, or missing files to compile."
        exit 0
    fi
fi

echo "📦 Compiling ${#TO_COMPILE[@]} file(s)..."
for f in "${TO_COMPILE[@]}"; do
    echo " - $f"
done

TMP_BUILD_DIR=$(mktemp -d)
SETUP_PY="$TMP_BUILD_DIR/setup.py"

# Generate setup.py dynamically
{
    echo "from setuptools import setup"
    echo "from Cython.Build import cythonize"
    echo "from setuptools import Extension"
    echo ""
    echo "extensions = ["
    for f in "${TO_COMPILE[@]}"; do
        rel_path="${f#$SRC_DIR/}"
        mod_name="${rel_path%.py}"
        mod_name="${mod_name#$REL_SRC_DIR/}"
        mod_name="${mod_name//\//.}"

        if [[ "$f" == "$REPO_ROOT/"* ]]; then
            abs_path="$f"
        else
            abs_path="$REPO_ROOT/$f"
        fi
        echo "    Extension('$mod_name', ['$abs_path']),"
    done
    echo "]"
    echo ""
    echo "setup("
    echo "    name='compiled_package',"
    echo "    ext_modules=cythonize(extensions, compiler_directives={'language_level': '3'}),"
    echo "    script_args=['build_ext', '--build-lib', '$OUT_DIR', '--build-temp', '$TMP_BUILD_DIR/build'],"
    echo "    zip_safe=False"
    echo ")"
} > "$SETUP_PY"

# Compile
python3 "$SETUP_PY"

# Clean up
rm -rf "$TMP_BUILD_DIR"

# Remove generated .c files
find "$SRC_DIR" -type f -name '*.c' -delete

echo "✅ Done. Output available in: $OUT_DIR"