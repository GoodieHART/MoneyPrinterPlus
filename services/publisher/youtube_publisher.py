#  Copyright © [2024] 程序那些事
#
#  All rights reserved. This software and associated documentation files (the "Software") are provided for personal and educational use only. Commercial use of the Software is strictly prohibited unless explicit permission is obtained from the author.
#
#  Permission is hereby granted to any person to use, copy, and modify the Software for non-commercial purposes, provided that the following conditions are met:
#
#  1. The original copyright notice and this permission notice must be included in all copies or substantial portions of the Software.
#  2. Modifications, if any, must retain the original copyright information and must not imply that the modified version is an official version of the Software.
#  3. Any distribution of the Software or its modifications must retain the original copyright notice and include this permission notice.
#
#  For commercial use, including but not limited to selling, distributing, or using the Software as part of any commercial product or service, you must obtain explicit authorization from the author.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHOR OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#  Author: 程序那些事
#  email: flydean@163.com
#  Website: [www.flydean.com](http://www.flydean.com)
#  GitHub: [https://github.com/ddean2009/MoneyPrinterPlus](https://github.com/ddean2009/MoneyPrinterPlus)
#
#  All rights reserved.

import time
import os
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import streamlit as st
from tools.file_utils import read_head, read_file_start_with_secondline

YOUTUBE_UPLOAD_URL = "https://www.youtube.com/upload"

def youtube_publisher(driver: WebDriver, video_path: str, text_file: str):
    """
    Uploads a video to YouTube using Selenium.
    """
    print("--- Starting YouTube Upload ---")

    if not os.path.exists(video_path):
        st.error(f"Video file not found at: {video_path}")
        print(f"Error: Video file not found at {video_path}")
        return

    # Get title and description from text file
    title = read_head(text_file)
    description = read_file_start_with_secondline(text_file)

    # Get settings from session state
    use_common = st.session_state.get('video_publish_use_common_config')
    if use_common:
        tags = st.session_state.get('video_publish_tags', "").split()
        privacy_status = st.session_state.get('video_publish_youtube_privacy_status', 'PRIVATE')
    else:
        tags = st.session_state.get('video_publish_youtube_tags', "").split()
        privacy_status = st.session_state.get('video_publish_youtube_privacy_status', 'PRIVATE')


    try:
        # 1. Navigate to the YouTube upload page
        print(f"Navigating to {YOUTUBE_UPLOAD_URL}")
        driver.get(YOUTUBE_UPLOAD_URL)
        WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, "//input[@type='file']")))
        print("Successfully navigated to YouTube upload page.")

        # 2. Upload the video file
        print(f"Uploading video: {video_path}")
        file_input = driver.find_element(By.XPATH, "//input[@type='file']")
        file_input.send_keys(video_path)
        print("Video file selected.")

        # 3. Wait for the details page to load and fill in the details
        print("Waiting for video details page to load...")
        title_input_xpath = "//ytcp-social-suggestion-input[@label='Title']//div[@id='textbox']"
        WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, title_input_xpath)))
        print("Details page loaded. Filling in title and description.")

        # Title
        title_input = driver.find_element(By.XPATH, title_input_xpath)
        title_input.clear()
        title_input.send_keys(title)
        time.sleep(1)

        # Description
        description_input_xpath = "//ytcp-social-suggestion-input[@label='Description']//div[@id='textbox']"
        description_input = driver.find_element(By.XPATH, description_input_xpath)
        description_input.clear()
        description_input.send_keys(description)
        time.sleep(1)
        print(f"Title and Description set.")

        # 4. Set "Not for kids"
        print("Setting 'Not made for kids'.")
        not_for_kids_radio = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.NAME, "VIDEO_MADE_FOR_KIDS_NOT_MFK")))
        not_for_kids_radio.click()
        time.sleep(1)

        # 5. Click through the "Next" buttons
        for i in range(3):
            print(f"Clicking 'Next' button, attempt {i+1}/3")
            next_button = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.ID, "next-button")))
            next_button.click()
            time.sleep(2)

        # 6. Set privacy status
        print(f"Setting privacy status to: {privacy_status}")
        privacy_radio_xpath = f"//tp-yt-paper-radio-button[@name='{privacy_status}']"
        WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, privacy_radio_xpath))).click()
        time.sleep(1)

        # 7. Click the final "Publish" button
        print("Waiting for the 'Publish' button to be clickable...")
        done_button = WebDriverWait(driver, 300).until(EC.element_to_be_clickable((By.ID, "done-button")))
        
        auto_publish = st.session_state.get('video_publish_auto_publish', True)
        if auto_publish:
            print("Clicking 'Publish' button.")
            done_button.click()
            print("--- YouTube Upload Complete ---")
            st.success("YouTube video published successfully!")
        else:
            print("Auto-publish is disabled. Skipping final publish click.")
            st.info("Auto-publish is disabled. Please publish the video manually in the browser.")

    except Exception as e:
        st.error(f"An error occurred during YouTube upload: {e}")
        print(f"An error occurred during YouTube upload: {e}")
