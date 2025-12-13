# CROW-SQL: Local SQL Query Generation with LLMs

This project allows you to run SQL query generation and benchmarking using local LLMs instead of cloud services. The notebook has been modified to work entirely locally with Ollama models.

## Prerequisites

- Ubuntu 20.04 or later
- Python 3.8 or later
- At least 8GB of RAM (16GB+ recommended for larger models)
- At least 15GB of free disk space (depending on model sizes)

## Installation

### 1. Install Python Dependencies

```bash
# Create a virtual environment (recommended)
python3 -m venv .venv
source .venv/bin/activate

# Install required packages
pip install -r requirements.txt
```

### 2. Install Ollama

Choose one of these methods:

#### Method 1: Using the provided script
```bash
chmod +x ollama_setup.sh
./ollama_setup.sh
```

#### Method 2: Manual installation
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

### 3. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env to set your preferred model and other settings
# Example: nano .env
# Change OLLAMA_MODEL to your preferred model (llama3, mistral, phi3, etc.)
```

### 4. Start Ollama Service

```bash
# Option 1: Run directly (recommended for testing)
ollama serve
# Keep this terminal open, or run in background: nohup ollama serve &

# Option 2: Using systemd service (requires root access for system-wide installation)
# If the service doesn't exist, you may need to manually create it or use the direct method above
```

### 4. Pull Required Models

```bash
# Recommended models for SQL query generation
ollama pull llama3
# or
ollama pull mistral
# or
ollama pull phi3
# or (used here)
ollama pull gpt-oss:20b
# or (used here)
ollama pull qwen2.5-coder:32b
```

You can check available models at: https://ollama.ai/library

### 6. Prepare Datasets (Required for Benchmarking)

#### Option 1: Testing Dataset (Bird Mini - for testing only)
```bash
# Create directories for Bird mini dataset
mkdir -p data/bird_mini

# This is a small test dataset for initial testing only
# Clone the Bird Mini Dev dataset from Hugging Face
# Install git-lfs if not already installed (requires system access)
# On Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y git-lfs
# On other systems: Check https://git-lfs.github.com/ for installation instructions

# If git-lfs is already installed, proceed with:
git lfs install
git clone https://huggingface.co/datasets/birdsql/bird_mini_dev temp_bird_mini

# Move the database files to the correct location
mv temp_bird_mini/* data/bird_mini/ 2>/dev/null || echo "Check Hugging Face dataset structure"
rm -rf temp_bird_mini

# The Bird Mini dataset structure should look like:
# data/bird_mini/
# ├── calgary_schools/
# ├── yelp/
# └── ... (few sample databases for testing)

# Verify the download
ls -la data/bird_mini/
```

#### Option 2: Download Bird Dataset (Not provided in this repository)
```bash
# Bird dataset is not included in this repository and must be downloaded separately
# Create directories for Bird dataset
mkdir -p data/bird

# Option 2A: Use the full Hugging Face dataset
# Install git-lfs if not already installed (requires system access)
# On Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y git-lfs
# On other systems: Check https://git-lfs.github.com/ for installation instructions

# If git-lfs is already installed, proceed with:
git lfs install
git clone https://huggingface.co/datasets/birdsql/datasets temp_bird_hf

# Move the database files to the correct location
# Bird dataset from Hugging Face typically has dev_databases folder
mv temp_bird_hf/dev_databases/* data/bird/ 2>/dev/null || echo "Check Hugging Face dataset structure"
rm -rf temp_bird_hf

# The Bird dataset structure should look like:
# data/bird/
# ├── california_schools/
# ├── card_games/
# ├── codebase_community/
# ├── financial/
# └── ... (other Bird DBs)

# You'll also need the corresponding question files (dev.json, train.json, tables.json)
# These may also be available from the Hugging Face dataset or Bird website

# Option 2B: Alternative access via Bird-Bench website
# Visit: https://bird-bench.github.io/
# To access the Bird dataset:
# 1. Navigate to the Bird-Bench website (https://bird-bench.github.io/)
# 2. Look for download links or contact information
# 3. Bird dataset access may require academic registration or specific access permissions

# Verify the download
ls -la data/bird/
```

#### Option 3: Download Spider Dataset via Git
```bash
# Create directories for Spider dataset
mkdir -p data/spider

# Spider dataset source code (not the databases, which must be downloaded separately)
cd data/spider
git clone https://github.com/taoyds/spider.git temp_spider_source

# The actual databases are not in the GitHub repo but must be downloaded separately
# Go to https://yale-lily.github.io/spider and download the full dataset
# Extract the database files to data/spider/database/

# After downloading the full dataset, you should have:
# data/spider/database/
# ├── academic/
# ├── albums/
# ├── car_1/
# ├── imdb/
# └── ... (many other database directories with .sqlite files)

# Question files (dev.json, train.json) need to be downloaded separately or use the ones from GitHub repo:
# cp temp_spider_source/dev.json ../dev.json
# cp temp_spider_source/tables.json ../tables.json

# Clean up
rm -rf temp_spider_source
cd ../../

# For Spider dataset, also update question paths in the notebook:
# question_path = "data/dev.json" (or "data/spider/dev.json" if you move it)
# query_table_name = "query"  # Spider uses 'query' instead of 'SQL'

# Verify the download - you should see multiple database directories
ls -la data/spider/database/
```

#### Option 4: Alternative Spider Dataset Download with Git
```bash
# Clone the Spider repository
git clone https://github.com/taoyds/spider.git temp_spider

# The main repository contains code and question files (but not the actual database files)
# Copy question files to data directory
cp temp_spider/dev.json data/dev.json
cp temp_spider/tables.json data/tables.json
cp temp_spider/train_spider.json data/train.json

# For the actual databases, you still need to download them separately from:
# https://yale-lily.github.io/spider
# Then extract database files to data/spider/database/

# Clean up
rm -rf temp_spider

# Create the database directory
mkdir -p data/spider/database
```

#### Expected directory structure:
```
data/
├── bird_mini/ (if using for testing)
│   ├── calgary_schools/
│   ├── yelp/
│   └── ... (Mini test DBs)
├── bird/ (if downloaded)
│   ├── california_schools/
│   ├── card_games/
│   └── ... (Bird DBs)
├── spider/ (if downloaded)
│   └── database/
│       ├── academic/
│       ├── albums/
│       └── ... (Spider DBs)
├── dev.json (question file)
├── tables.json (table information)
└── train.json (training questions)
```

#### Update notebook configuration
In the notebook, change the data path based on which dataset you want to use:
- For Bird Mini (testing): `local_data_path = "data/bird_mini"`
- For Bird: `local_data_path = "data/bird"`
- For Spider: `local_data_path = "data/spider/database"`

## Running the Notebook

### 1. Start Jupyter
```bash
# In your activated virtual environment
jupyter notebook SQLAgentBenchmarking_local.ipynb
```

### 2. Adjust Model Settings (Optional)

In the notebook, you can change the Ollama model by setting the `OLLAMA_MODEL` environment variable:

```python
import os
os.environ["OLLAMA_MODEL"] = "llama3"  # or "mistral", "phi3", etc.
```

### 3. Configure Local Dataset Path

Update the `data_path` in the notebook to point to your local database files:

```python
# Change this in the notebook
local_data_path = "data/dev_databases"  # or your custom path
```

## Configuration Options

### Environment Variables

- `OLLAMA_MODEL`: Sets the model to use (default: llama3)
- `OPENAI_API_KEY`: Optional - if you want to use OpenAI models as well

### Model Selection Tips

For SQL query generation, these models work well:
- **llama3**: Good balance of performance and resource usage
- **mistral**: Efficient and fast
- **phi3**: Good for constrained environments
- **mixtral**: More powerful but resource-intensive

## Troubleshooting

### Ollama service is not found
- Many Ubuntu installations don't have the systemd user service by default
- Instead of using systemctl, run: `ollama serve` directly in a terminal
- For background execution: `nohup ollama serve &`

### Ollama is not responding
- Verify Ollama is running: `curl http://localhost:11434`
- Check the service status: `systemctl --user status ollama` (if using systemd)
- Make sure port 11434 is not blocked

### Model not found error
- Pull the model: `ollama pull llama3`
- Check available models: `ollama list`

### Out of memory errors
- Use a smaller model
- Reduce the context window if supported
- Close other memory-intensive applications

### Database connection issues
- Ensure your SQLite files are in the correct directory (don't forget `git lfs pull`)
- Check that the file paths are correct and accessible
- Verify the database files are not corrupted

## Local vs Cloud Version Differences

- **Cloud version**: Uses Google Vertex AI, Google Cloud Storage, requires API keys
- **Local version**: Uses Ollama, local files, no API keys needed
- **Performance**: Local may be slower depending on your hardware
- **Privacy**: Local keeps all data on your machine

## Data and Results Storage

- Inputs: `data/` directory (user-provided)
- Outputs: `results/benchmarks/` directory
- Configuration: Notebook variables and environment variables

## Updating the Environment

```bash
# Update Python packages
pip install -r requirements.txt --upgrade

# Update Ollama (requires reinstalling)
curl -fsSL https://ollama.ai/install.sh | sh

# Update models
ollama pull llama3  # pulls latest version
```

## Uninstalling

```bash
# Remove Python virtual environment
rm -rf .venv

# Remove Ollama service (Ubuntu)
systemctl --user stop ollama
systemctl --user disable ollama

# Remove Ollama (requires manual removal)
sudo rm /usr/bin/ollama
sudo rm -rf /usr/share/ollama
```

## Contributing

Feel free to submit issues or pull requests to improve the local execution capabilities.

## License

See the LICENSE file for license rights and limitations.