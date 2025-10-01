# Plan: MoneyPrinterPlus Jupyter Notebook Integration

**Objective:** Create a step-by-step notebook workflow to generate a video from a text topic, using the existing services of the application.

## 1. Setup: Configuration and Initialization

*   **Goal:** Load necessary modules and configuration.
*   **Action:** In the first cells, import all required services and load the application's configuration from `config/config.py`. This will control which services (e.g., OpenAI for LLM, Azure for TTS) are used in subsequent steps.

## 2. Step 1: Generate Script and Keywords

*   **Goal:** Use the configured LLM service to generate a video script and a list of search keywords.
*   **Action:**
    *   Instantiate the LLM service using `get_llm_provider`.
    *   Call the `generate_content` method with your chosen topic to create the video script.
    *   Call `generate_content` again, this time using the generated script as input, to extract keywords for video searches.

## 3. Step 2: Generate Audio from Script

*   **Goal:** Convert the generated script into a spoken audio file.
*   **Action:**
    *   Instantiate the appropriate audio service (e.g., `AzureAudioService`, `ChatTTSAudioService`) based on your `config.yml`.
    *   Use the service's `save_with_ssml` (for cloud) or `chat_with_content` (for local) method to create the `.wav` file.
    *   Store the path to the output audio file.

## 4. Step 3: Generate Subtitles

*   **Goal:** Create a subtitle file (`.srt`) from the generated audio.
*   **Action:**
    *   Call the `generate_caption` function from the captioning service. This typically uses a speech-to-text model on the audio file from the previous step.
    *   Store the path to the output `.srt` file.

## 5. Step 4: Download Source Videos

*   **Goal:** Use the keywords from Step 1 to find and download relevant stock video clips.
*   **Action:**
    *   Instantiate the resource provider (e.g., `PexelsService`, `PixabayService`).
    *   Get the duration of the audio file from Step 2.
    *   Call the `handle_video_resource` method with the keywords and audio duration to get a list of video file paths that match the audio length.

## 6. Step 5: Assemble the Final Video

*   **Goal:** Combine the downloaded video clips, the main audio, and the subtitles into a single MP4 file.
*   **Action:**
    *   Instantiate the `VideoService` with the list of video clips and the path to the main audio file.
    *   Call `video_service.normalize_video()` to ensure all clips have a consistent format.
    *   Call `video_service.generate_video_with_audio()` to create the video without subtitles.
    *   Finally, call `add_subtitles()` with the generated video path and the `.srt` file path to burn the subtitles into the final video.
