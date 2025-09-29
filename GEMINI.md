# GEMINI.md

## Project Overview

This project, "MoneyPrinterPlus," is a Python-based application designed for the automated creation and distribution of short-form videos. It leverages various AI and cloud services to generate video content, apply text-to-speech for narration, and publish the final videos to multiple social media platforms.

The application is built with a Streamlit-based graphical user interface (`gui.py`), which allows users to configure and control the video generation process. The core functionalities are organized into different pages, such as "Auto Video," "Merge Video," and "Auto Publish."

### Key Technologies

*   **Backend:** Python
*   **Frontend:** Streamlit
*   **Core Libraries:**
    *   `langchain`, `openai`: For interacting with Large Language Models (LLMs) to generate video scripts.
    *   `azure-cognitiveservices-speech`, `tencentcloud-sdk-python-tts`: For cloud-based text-to-speech services.
    *   `faster-whisper`, `chatTTS`: For local text-to-speech and speech recognition.
    *   `moviepy`: For video editing and composition.
    *   `selenium`: For automating the process of uploading videos to web platforms.
*   **Configuration:** The application uses a `config.yml` file for storing API keys and user preferences, which is managed by `config/config.py`.

### Architecture

The application follows a modular structure:

*   `gui.py`: The main entry point for the Streamlit UI.
*   `pages/`: Contains the different pages of the application, each with its own UI and logic.
*   `services/`: Encapsulates the logic for interacting with external services, such as LLMs, TTS, and video platforms.
*   `main.py`: Contains the main functions that orchestrate the video generation process.
*   `config/`: Manages the application's configuration.

## Building and Running

### Prerequisites

*   Python 3.10+
*   FFmpeg

### Installation

1.  **Automatic Installation:**
    *   On Windows, run `setup.bat`.
    *   On macOS or Linux, run `bash setup.sh`.

2.  **Manual Installation:**
    *   Install the required Python packages using pip:
        ```bash
        pip install -r requirements.txt
        ```

### Running the Application

1.  **Automatic Start:**
    *   On Windows, run `start.bat`.
    *   On macOS or Linux, run `bash start.sh`.

2.  **Manual Start:**
    *   Run the Streamlit application using the following command:
        ```bash
        streamlit run gui.py
        ```

## Development Conventions

*   **Configuration:** All configuration is managed through the `config/config.py` file and the `config.yml` file. When adding new configuration options, update these files accordingly.
*   **UI:** The user interface is built with Streamlit. New pages should be created in the `pages/` directory and follow the existing structure.
*   **Services:** External service integrations are encapsulated in the `services/` directory. Each service should have its own module that handles API requests and responses.
*   **Localization:** The application supports multiple languages. Text displayed in the UI should be wrapped in the `tr()` function from `tools/tr_utils.py` to enable translation. The translation files are located in the `locales/` directory. The supported languages are English (en-US) and Chinese (zh-CN).
*   **File Naming:** The project uses snake_case for Python files and directories.
*   **Code Style:** The code generally follows the PEP 8 style guide.
