#!/bin/bash

# Check if Secrets.xcconfig exists already
if [ -f "Secrets.xcconfig" ]; then
  echo "Secrets.xcconfig already exists. Skipping setup."
  exit 0
fi

# Check if sample exists
if [ ! -f "Secrets.sample.xcconfig" ]; then
  echo "Secrets.sample.xcconfig not found! Please create it first."
  exit 1
fi

# Copy sample to real config
cp Secrets.sample.xcconfig Secrets.xcconfig

# Prompt for API key
read -p "Enter your API key: " api_key

# Replace placeholder in Secrets.xcconfig
sed -i.bak "s/YOUR_API_KEY_HERE/$api_key/" Secrets.xcconfig

# Remove backup file sed created (macOS compatibility)
rm Secrets.xcconfig.bak

echo "Setup complete! You can now build the app."

