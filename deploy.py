"""
MoneyPrinterTurbo Modal Deployment

Deploy MoneyPrinterTurbo on Modal Labs as a Sandbox with:
- Streamlit WebUI (port 8501)
- FastAPI API (port 8080)
- Optional T4 GPU for Whisper subtitles
- Persistent Volume for config, videos, and resources
"""

import modal

app = modal.App("moneyprinter-turbo")

# Build image from MoneyPrinterTurbo's Dockerfile
# We clone the repo and build from source
image = (
    modal.Image.from_registry("python:3.11-slim-bullseye")
    .apt_install("git", "imagemagick", "ffmpeg")
    .run_commands(
        "git clone https://github.com/harry0703/MoneyPrinterTurbo.git /MoneyPrinterTurbo",
        "cd /MoneyPrinterTurbo && pip install --no-cache-dir -r requirements.txt && pip install pydub google-generativeai==0.8.6",
    )
    .workdir("/MoneyPrinterTurbo")
)

# Persistent storage for config, videos, and resources
volume = modal.Volume.from_name("moneyprinter-storage", create_if_missing=True)


@app.local_entrypoint()
def main(
    gpu: bool = True,
    timeout: int = 3600,
    idle_timeout: int = 600,
) -> None:
    """
    Deploy MoneyPrinterTurbo on Modal.
    
    Args:
        gpu: Enable T4 GPU for Whisper subtitles (default: True)
        timeout: Maximum sandbox lifetime in seconds (default: 3600)
        idle_timeout: Idle shutdown in seconds (default: 600)
    """
    # Build sandbox config
    sandbox_config = {
        "image": image,
        "volumes": {"/data": volume},
        "encrypted_ports": [8501, 8080],
        "timeout": timeout,
        "idle_timeout": idle_timeout,
    }
    
    # Add GPU if requested
    if gpu:
        sandbox_config["gpu"] = "T4"
    
    # Get or create the app for sandbox
    try:
        app_ref = modal.App.lookup("moneyprinter-turbo", create_if_missing=True)
    except Exception as e:
        print(f"Error getting app: {type(e).__name__}")
        print("Please check your Modal credentials and try again.")
        return
    
    # Start both services
    try:
        sandbox = modal.Sandbox.create(
            "bash", "-c",
            "cp /data/config.toml /MoneyPrinterTurbo/config.toml 2>/dev/null || true && "
            "mkdir -p /data/storage && ln -sf /data/storage /MoneyPrinterTurbo/storage 2>/dev/null || true && "
            "streamlit run ./webui/Main.py --server.port 8501 & python main.py",
            app=app_ref,
            **sandbox_config,
        )
    except Exception as e:
        print(f"Error creating sandbox: {type(e).__name__}")
        print("Please check your Modal credentials and try again.")
        return
    
    # Get tunnel URLs
    try:
        tunnels = sandbox.tunnels()
    except Exception as e:
        print(f"Error getting tunnel URLs: {type(e).__name__}")
        print(f"Sandbox ID: {sandbox.object_id}")
        print("Check sandbox logs: modal sandbox logs", sandbox.object_id)
        return
    
    print("=" * 60)
    print("MoneyPrinterTurbo deployed successfully!")
    print("=" * 60)
    print(f"WebUI:      {tunnels[8501].url}")
    print(f"API:        {tunnels[8080].url}")
    print(f"API Docs:   {tunnels[8080].url}/docs")
    print("=" * 60)
    print(f"Sandbox ID: {sandbox.object_id}")
    print(f"GPU:        {'T4' if gpu else 'None'}")
    print(f"Timeout:    {timeout}s / Idle: {idle_timeout}s")
    print("=" * 60)
    print("\nTo check logs: modal sandbox logs", sandbox.object_id)
    print("To stop: modal sandbox stop", sandbox.object_id)
