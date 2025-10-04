#!/usr/bin/env bash

# Exit on error
set -e

# 1. Update system packages
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Install ffmpeg
echo "Installing ffmpeg..."
sudo apt-get install -y ffmpeg build-essential

# 3. Install nodejs 20
echo "Installing nodejs 20..."
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install nodejs -y

# 4. Install gemini cli
echo "Installing gemini cli..."
sudo npm install -g @google/gemini-cli

# 5. Install chattts
echo "Installing chattts..."
git clone https://github.com/2noise/ChatTTS
mv ChatTTS chattts/
(cd chattts/ChatTTS && pip install --upgrade -r requirements.txt)

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

