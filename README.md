# MoneyPrinterTurbo on Modal

Deploy [MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo) on Modal Labs — AI-powered short video generation.

## Quick Start

### 1. Prerequisites

- [Modal account](https://modal.com/) with CLI installed
- Python 3.11+
- API keys for:
  - LLM provider (OpenAI, DeepSeek, etc.)
  - Stock video (Pexels or Pixabay)

### 2. Setup

```bash
# Install Modal CLI
pip install modal

# Authenticate
modal setup

# Clone this repo (if not already)
git clone <repo-url>
cd modal-playground/moneyprinter
```

### 3. Configure

Edit `config.toml` with your API keys:

```toml
[app]
llm_provider = "openai"
openai_api_key = "sk-your-key"
pexels_api_keys = ["your-pexels-key"]
```

### 4. Upload Config to Volume

```bash
modal volume put --force moneyprinter-storage config.toml /config.toml
```

### 5. Deploy

```bash
# With GPU (for Whisper subtitles)
modal run deploy.py

# Without GPU (Edge TTS only)
modal run deploy.py --no-gpu

# Custom timeouts
modal run deploy.py --timeout 7200 --idle-timeout 300
```

### 6. Access

After deployment, you'll get:
- **WebUI**: Visual interface for video generation
- **API**: Programmatic access at `/docs`

## Usage

### Generate Video via WebUI

1. Open WebUI URL
2. Enter video topic/keyword
3. Configure settings (ratio, duration, voice)
4. Click Generate

### Generate Video via API

```bash
curl -X POST "https://<sandbox-id>-8080.modal.run/generate" \
  -H "Content-Type: application/json" \
  -d '{"video_subject": "Your topic here"}'
```

## Management

```bash
# Check logs
modal sandbox logs <sandbox-id>

# Stop sandbox
modal sandbox stop <sandbox-id>

# List volumes
modal volume ls moneyprinter-storage
```

## Costs

| Resource | Rate | 1 hr/day |
|----------|------|----------|
| T4 GPU | $0.000164/s | ~$0.60/mo |
| CPU (4 cores) | $0.00004/s | ~$0.50/mo |
| **Total** | | **~$1.20/mo** |

*Idle time is not billed.*

## Storage

- Config uploaded to Volume at `/config.toml`
- Generated videos stored persistently at `/data/storage/` (symlinked from `/MoneyPrinterTurbo/storage`)

## Troubleshooting

### WebUI not loading
- Check sandbox logs: `modal sandbox logs <id>`
- Verify port 8501 is exposed

### API errors
- Check API docs at `/docs` endpoint
- Verify config.toml has valid API keys

### Video generation fails
- Ensure Pexels/Pixabay API key is valid
- Check storage permissions in Volume
