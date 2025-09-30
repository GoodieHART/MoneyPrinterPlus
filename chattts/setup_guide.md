# How to Use Local chatTTS with MoneyPrinterPlus

This guide explains how to set up and use the local `chatTTS` model with MoneyPrinterPlus, providing a free alternative to paid cloud-based TTS services.

---

### Part 1: Install and Run the `chatTTS` Server

First, you need to set up `chatTTS` to run as a separate local server.

1.  **Download `chatTTS`:**
    Open your terminal, navigate to a directory where you want to store the `chatTTS` project, and run the following command to clone its repository:
    ```bash
    git clone https://github.com/2noise/ChatTTS
    ```

2.  **Install Dependencies:**
    Navigate into the newly created `ChatTTS` directory and install the required Python packages:
    ```bash
    cd ChatTTS
    pip install --upgrade -r requirements.txt
    ```

3.  **Start the API Server:**
    This is the server that MoneyPrinterPlus will connect to. From inside the `ChatTTS` directory, run the following command:
    ```bash
    fastapi dev examples/api/main.py --host 0.0.0.0 --port 8000
    ```
    **Important:** MoneyPrinterPlus connects to this API server on port `8000`. You must keep this terminal window open and the server running in the background while you use MoneyPrinterPlus.

4.  **(Optional) Test with the Web UI:**
    To verify that your `chatTTS` installation is working correctly, you can start its local web interface. Open a *new* terminal window, navigate to the `ChatTTS` directory, and run:
    ```bash
    python examples/web/webui.py
    ```
    Now, open `http://localhost:8080/` in your web browser. If you can generate audio from this page, your `chatTTS` installation is successful. This web UI is also useful for creating custom voice files (see Part 3).

---

### Part 2: Configure MoneyPrinterPlus

Next, configure MoneyPrinterPlus to use your local `chatTTS` server.

1.  **Start MoneyPrinterPlus** and navigate to the **Basic Configuration** page from the sidebar.
2.  Locate the **Local Voice TTS** option.
3.  Select `chatTTS` from the provider dropdown menu.
4.  In the server address field, enter the address of your running API server: `http://127.0.0.1:8000/`.
5.  Navigate to the **Auto Video** or **Merge Video** page. In the **Voiceover** section, select **Local Model** as the audio source.
6.  The interface will now display options specific to `chatTTS` (e.g., Audio Temperature, top_P, etc.).

---

### Part 3: Managing Voices (Speakers)

You can add new voices for `chatTTS` to use. Voice files should be placed in the `MoneyPrinterPlus/chattts/` directory.

*   **Using `.pt` files (Pre-made Voices):**
    1.  Go to the `chatTTS` Speaker Studio on ModelScope: `https://modelscope.cn/studios/ttwwwaa/ChatTTS_Speaker`.
    2.  Listen to the voice samples and download the `.pt` file for any voice you like.
    3.  Place the downloaded `.pt` file directly into the `MoneyPrinterPlus/chattts/` folder.

*   **Using `.txt` files (Custom Speaker Embeddings):**
    1.  Open the `chatTTS` web UI that you launched in Part 1 (`http://localhost:8080/`).
    2.  The "Speaker Embedding" text box contains the configuration for the currently active voice.
    3.  Click the copy button next to this text box.
    4.  Create a new text file (`.txt`) inside the `MoneyPrinterPlus/chattts/` directory.
    5.  Paste the copied text into this new file and save it.

After adding new voice files, they will appear in the voice selection dropdown in MoneyPrinterPlus. You can test them using the **"Audition"** button to ensure everything is configured correctly.
