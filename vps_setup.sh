#!/usr/bin/env bash

# Exit on error
set -e

# 1. Update system packages
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Install ffmpeg
echo "Installing ffmpeg..."
sudo apt-get install -y ffmpeg wget clang build-essential libgtk-3-dev portaudio19-dev libglib2.0-dev \
libjpeg-dev libpng-dev libtiff-dev libnotify-dev libwebkit2gtk-4.0-dev \
libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
libnotify-dev libjpeg-dev libtiff-dev libwebp-dev python3-dev

# 5. Install chattts
echo "Installing chattts..."
if [ ! -d "chattts/ChatTTS" ]; then
  echo "ChatTTS directory not found, cloning repository..."
  rm -rf ChatTTS
  git clone https://github.com/2noise/ChatTTS
  mv ChatTTS chattts/
  (cd chattts/ChatTTS && pip install --upgrade -r requirements.txt && fastapi dev examples/api/main.py --host 0.0.0.0 --port 8000)
else
  echo "ChatTTS directory already exists, skipping clone and install."
fi

# 7. Download chattts models
echo "Downloading chattts models..."
wget -P chattts/ https://huggingface.co/2Noise/ChatTTS/resolve/main/asset/DVAE.pt
wget -P chattts/ https://huggingface.co/2Noise/ChatTTS/resolve/main/asset/DVAE_full.pt
wget -P chattts/ https://huggingface.co/2Noise/ChatTTS/resolve/main/asset/Decoder.pt
wget -P chattts/ https://huggingface.co/2Noise/ChatTTS/resolve/main/asset/GPT.pt
wget -P chattts/ https://huggingface.co/2Noise/ChatTTS/resolve/main/asset/Vocos.pt
wget -P chattts/ https://huggingface.co/2Noise/ChatTTS/resolve/main/asset/spk_stat.pt
wget -P chattts/ https://huggingface.co/2Noise/ChatTTS/resolve/main/asset/tokenizer.pt

# 6. Download faster-whisper model
echo "Downloading faster-whisper model..."
git clone https://huggingface.co/Systran/faster-whisper-tiny fasterwhisper/tiny


# 7. Install python requirements
echo "Setting up python environment..."
# Directory of the script
SCRIPT_DIR="$(cd -- $(dirname -- "$0") && pwd)"
DIR="$(pwd)"

# Function to install Python dependencies
install_python_dependencies() {
  local TEMP_REQUIREMENTS_FILE

  # Switch to local virtual env
  echo "Switching to virtual Python environment."
  echo "this will take some time,please wait....."
  if command -v python3.10 >/dev/null; then
    echo python3.10 -m venv "$DIR/venv"
    python3.10 -m venv "$DIR/venv"
  elif command -v python3 >/dev/null; then
    echo python3 -m venv "$DIR/venv"
    python3 -m venv "$DIR/venv"
  else
    echo "Valid python3 or python3.10 binary not found."
    echo "Cannot proceed with the python steps."
    return 1
  fi

  # Activate the virtual environment
  echo "Activate the virtual environment..."
  source "$DIR/venv/bin/activate"

  echo "setup python dependencies..."
  python -m pip install --require-virtualenv --no-input -q -q  setuptools
  python "$SCRIPT_DIR/setup/setup_linux.py" --platform-requirements-file=requirements.txt

  if [ -n "$VIRTUAL_ENV" ]; then
    if command -v deactivate >/dev/null; then
      echo "Exiting Python virtual environment."
      deactivate
    else
      echo "deactivate command not found. Could still be in the Python virtual environment."
    fi
  fi
}

install_python_dependencies

echo "Setup finished!"

