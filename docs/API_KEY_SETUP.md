# API Key Setup

To fetch data from The Graph, you need an API key.

## Get Your API Key

1. Go to [The Graph Studio](https://thegraph.com/studio/)
2. Sign in or create an account
3. Navigate to your dashboard
4. Create or select a subgraph project
5. Copy your API key from the "API Keys" section

## Set Environment Variable

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```bash
# The Graph API Key for UMA Oracle Analysis
export THE_GRAPH_API_KEY='your_api_key_here'
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

## Verify

```bash
echo $THE_GRAPH_API_KEY
```

You should see your API key printed.

## Security Notes

- ✅ **DO:** Use environment variables
- ✅ **DO:** Add `.env` to `.gitignore`
- ❌ **DON'T:** Hardcode API keys in scripts
- ❌ **DON'T:** Commit API keys to git
- ❌ **DON'T:** Share API keys publicly

## Rotating Keys

If your key is exposed:
1. Go to The Graph Studio
2. Revoke the old key
3. Generate a new key
4. Update your environment variable
5. Reload your shell


