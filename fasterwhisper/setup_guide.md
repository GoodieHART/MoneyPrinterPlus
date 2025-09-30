# How to Use Local fasterWhisper with MoneyPrinterPlus

This guide explains how to set up and use the local `fasterWhisper` speech recognition model with MoneyPrinterPlus.

`fasterWhisper` is integrated directly into the application, so unlike `chatTTS`, you **do not** need to run a separate server. The primary setup step is to download the pre-trained models for the application to use.

---

### Part 1: Download the `fasterWhisper` Models

1.  **Choose a Model to Download:**
    First, decide which model you want to use. You can find the available models on the official Hugging Face repository: [https://huggingface.co/Systran](https://huggingface.co/Systran).

    Smaller models like `tiny` or `base` are faster and use less resources, but are less accurate. Larger models like `medium` or `large-v3` are more accurate but require more computational power.

2.  **Navigate to the Project Directory:**
    Open your terminal and navigate to the `fasterwhisper` directory located inside your MoneyPrinterPlus project folder.
    ```bash
    cd /path/to/MoneyPrinterPlus/fasterwhisper
    ```

3.  **Download the Model using Git:**
    Use the `git clone` command to download the model files. It is crucial that you rename the model's folder to one of the simple names recognized by MoneyPrinterPlus during the cloning process.

    **Supported Names:** `large-v3`, `large-v2`, `large-v1`, `distil-large-v3`, `distil-large-v2`, `medium`, `base`, `small`, `tiny`.

    **Example Command (downloading the 'tiny' model):**
    ```bash
    git clone https://huggingface.co/Systran/faster-whisper-tiny tiny
    ```
    This command downloads the model from the specified repository and places it in a new folder named `tiny` inside the `fasterwhisper` directory.

---

### Part 2: Configure MoneyPrinterPlus

1.  **Start the MoneyPrinterPlus** application.
2.  From the sidebar, navigate to the **Basic Configuration** page.
3.  Scroll down to the **Local speech recognition** section.
4.  Configure the settings for `fasterWhisper`:
    *   **Model name:** Enter the name of the folder you downloaded in the previous step (e.g., `tiny`, `base`, `small`).
    *   **Device type:** Select `cuda` if you have a compatible NVIDIA GPU (this is highly recommended for performance). Otherwise, select `cpu` or `auto`.
    *   **Compute type:** This setting allows for model quantization to reduce memory usage and increase speed. `float16` is a standard choice, while `int8` can provide a significant speed-up at a potential minor cost to accuracy.

5.  **Enable Local Speech Recognition in Video Settings:**
    Navigate to the **Auto Video** or **Merge Video** page. In the section for **Speech Recognition**, select the **Local Model** option.

MoneyPrinterPlus is now configured to use your local `fasterWhisper` model for all speech-to-text and subtitle generation tasks.
