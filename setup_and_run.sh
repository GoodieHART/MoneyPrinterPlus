#!/usr/bin/env bash

# Exit on error
set -e

# Function to display help information
display_help() {
  cat <<EOF
MoneyPrinterPlus Automated Setup and Start Script.

This script sets up the environment, installs dependencies, and starts the application automatically.

Options:
  -h, --help    Show help information.
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

# Check if running in Docker
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

# Main script logic
main() {
  echo "Starting automated setup..."

  case "$OSTYPE" in
    "linux"*)
      install_system_dependencies
      ;;
    "darwin"*)
      echo "Detected macOS. Please ensure Homebrew is installed for dependency management."
      setup_python_environment
      ;;
    *)
      echo "Unsupported OS: $OSTYPE"
      exit 1
      ;;
  esac

  setup_python_environment
  download_models
  start_application
}

# Handle command-line flags
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help)
      display_help
      exit 0
      ;;
    *)
      echo "Invalid option: $1"
      display_help
      exit 1
      ;;
  esac
  shift
done

main