echo "Running pre-start script..."

source /scripts/sync.sh

echo "Generating auth..."
python /scripts/generate_auth.py
