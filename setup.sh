#!/usr/bin/env bash

# Consolidated MoneyPrinterPlus Setup Script
# Supports modes: --full (default), --vps, --python-only, --help

# Function to display help information
display_help() {
  cat <<EOF
MoneyPrinterPlus Consolidated Setup Script.

This script sets up the environment with different modes.

Modes:
  --full        (default) Install system dependencies, set up Python environment, download models, and start the application.
  --vps         Install system dependencies, set up Python environment, and download models (no app start, for servers).
  --python-only Install only Python environment and dependencies.
  --help        Show this help information.

Examples:
  ./setup.sh              # Full setup
  ./setup.sh --vps        # VPS setup
  ./setup.sh --python-only # Python only
EOF
}

# Detect if running in Docker or other containers
isContainerOrPod() {
  local cgroup=/proc/1/cgroup
  test -f $cgroup && (grep -qE ':cpuset:/(docker|kubepods)' $cgroup || grep -q ':/docker/' $cgroup)
}

isDockerBuildkit() {
  local cgroup=/proc/1/cgroup
  test -f $cgroup && grep -q ':cpuset:/docker/buildkit' $cgroup
}

isDockerContainer() {
  [ -e /.dockerenv ]
}

inDocker() {
  if isContainerOrPod || isDockerBuildkit || isDockerContainer; then
    return 0
  else
    return 1
  fi
}

# Install system dependencies (for Linux)
install_system_dependencies() {
  echo "Installing system dependencies..."
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install -y ffmpeg wget clang build-essential libgtk-3-dev portaudio19-dev libglib2.0-dev \
    libjpeg-dev libpng-dev libtiff-dev libnotify-dev libwebkit2gtk-4.0-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev python3-dev
}

# Set up Python environment
setup_python_environment() {
  local DIR="$(pwd)"
  echo "Setting up Python environment..."

  if ! inDocker; then
    if command -v python3.10 >/dev/null; then
      echo "Using python3.10 to create virtual environment."
      python3.10 -m venv "$DIR/venv"
    elif command -v python3 >/dev/null; then
      echo "Using default python3 to create virtual environment."
      python3 -m venv "$DIR/venv"
    else
      echo "Valid python3 binary not found. Exiting."
      exit 1
    fi
    source "$DIR/venv/bin/activate"
  else
    echo "Running inside container. Skipping virtual environment setup."
  fi

  echo "Installing Python dependencies..."
  python -m pip install --require-virtualenv --no-input -q -q setuptools
  python ./setup/setup_linux.py --platform-requirements-file=requirements.txt
}

# Download models if missing
download_models() {
  echo "Downloading necessary models..."
  if [ ! -d "fasterwhisper/tiny" ]; then
    git clone https://huggingface.co/Systran/faster-whisper-tiny fasterwhisper/tiny
  else
    echo "Model already downloaded. Skipping."
  fi
}

# Start the Streamlit application
start_application() {
  echo "Starting the application..."
  local SCRIPT_DIR="$(cd -- $(dirname -- "$0") && pwd)"

  if [ -d "$SCRIPT_DIR/venv" ]; then
    source "$SCRIPT_DIR/venv/bin/activate"
  else
    echo "venv folder does not exist. Skipping virtual environment activation."
  fi

  streamlit run gui.py
}

# Main logic based on mode
main() {
  local MODE="full"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --full)
        MODE="full"
        shift
        ;;
      --vps)
        MODE="vps"
        shift
        ;;
      --python-only)
        MODE="python-only"
        shift
        ;;
      --help)
        display_help
        exit 0
        ;;
      *)
        echo "Invalid option: $1"
        display_help
        exit 1
        ;;
    esac
  done

  echo "Starting setup in mode: $MODE"

  case "$OSTYPE" in
    "linux"*)
      if [[ "$MODE" == "full" || "$MODE" == "vps" ]]; then
        install_system_dependencies
      fi
      setup_python_environment
      if [[ "$MODE" == "full" || "$MODE" == "vps" ]]; then
        download_models
      fi
      if [[ "$MODE" == "full" ]]; then
        start_application
      fi
      ;;
    "darwin"*)
      echo "Detected macOS. Please ensure Homebrew is installed for dependency management."
      setup_python_environment
      if [[ "$MODE" == "full" || "$MODE" == "vps" ]]; then
        download_models
      fi
      if [[ "$MODE" == "full" ]]; then
        start_application
      fi
      ;;
    *)
      echo "Unsupported OS: $OSTYPE"
      exit 1
      ;;
  esac

  if [[ "$MODE" != "full" ]]; then
    echo "Setup completed in $MODE mode."
  fi
}

# Run main function with all arguments
main "$@"
