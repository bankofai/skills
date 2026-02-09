# Security Guide for Private Key Management

## 🔐 Overview

The `mcp-server-tron` requires a TRON private key to sign transactions. This guide explains how to manage it securely.

---

## ⚠️ Security Risks

**Private keys give FULL CONTROL over your wallet**. If leaked:
- ❌ Anyone can steal all your funds
- ❌ Transactions cannot be reversed
- ❌ No recovery is possible

**Never**:
- Share your private key with anyone
- Commit it to git repositories
- Store it in unencrypted files that AI agents can read
- Use your main wallet for testing

---

## 🎯 Recommended Approach

### Method 1: Environment Variables (Most Secure) ✅

Store keys in your shell profile, not in config files.

#### Setup

1. **Edit your shell profile**:
   ```bash
   # For zsh (macOS default)
   nano ~/.zshrc
   
   # For bash
   nano ~/.bashrc
   ```

2. **Add these lines**:
   ```bash
   # TRON MCP Server Configuration
   export TRON_PRIVATE_KEY="your_private_key_here"
   export TRONGRID_API_KEY="your_api_key_here"
   ```

3. **Reload shell**:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

4. **Verify**:
   ```bash
   echo $TRON_PRIVATE_KEY | head -c 10
   # Should show first 10 characters
   ```

#### MCP Configuration

Your `~/.mcporter/mcporter.json` should look like:

```json
{
  "mcpServers": {
    "mcp-server-tron": {
      "command": "npx",
      "args": ["-y", "@bankofai/mcp-server-tron"]
    }
  }
}
```

**No `env` section needed** - the server will automatically read from environment variables.

#### Advantages
- ✅ Keys not visible in config files
- ✅ AI agents can't accidentally read them
- ✅ Easier to manage across multiple tools
- ✅ Can use different keys per shell session

#### Disadvantages
- ⚠️ Visible to all processes run by your user
- ⚠️ May be visible in process listings (`ps aux`)

---

### Method 2: Config File (Less Secure)

Store keys directly in the MCP config file.

#### MCP Configuration

```json
{
  "mcpServers": {
    "mcp-server-tron": {
      "command": "npx",
      "args": ["-y", "@bankofai/mcp-server-tron"],
      "env": {
        "TRON_PRIVATE_KEY": "your_private_key_here",
        "TRONGRID_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

#### Security Measures

1. **Restrict file permissions**:
   ```bash
   chmod 600 ~/.mcporter/mcporter.json
   ```

2. **Add to .gitignore** (if in a git repo):
   ```bash
   echo ".mcporter/" >> ~/.gitignore
   ```

3. **Never share or commit this file**

#### Advantages
- ✅ Simple setup
- ✅ Keys isolated to MCP server process

#### Disadvantages
- ❌ Keys stored in plaintext
- ❌ AI agents might read the file
- ❌ Easy to accidentally share/commit

---

### Method 3: Separate Test Wallet (Best Practice) 🌟

**Always use a dedicated wallet for AI agents**, not your main wallet.

#### Setup

1. **Create a new TRON wallet**:
   - Use TronLink or any wallet app
   - Export the private key

2. **Fund with small amounts**:
   ```
   Mainnet: 100-1000 TRX + some USDT
   Nile Testnet: Get free test TRX from faucet
   ```

3. **Use this wallet for MCP**:
   - Configure using Method 1 or 2
   - Monitor balance regularly
   - Refill as needed

#### Advantages
- ✅ Limited risk exposure
- ✅ Easy to monitor
- ✅ Can be replaced if compromised
- ✅ Separate from main funds

---

## 🧪 Testing on Testnet

**Always test on Nile testnet first!**

### Get Test TRX

1. **Nile Testnet Faucet**:
   - https://nileex.io/join/getJoinPage
   - Free test TRX every 24 hours

2. **Configure for Nile**:
   ```bash
   export TRON_NETWORK="nile"
   ```

3. **Test your setup**:
   - Check balance
   - Try a small transfer
   - Test contract interactions

### Switch to Mainnet

Only after successful testing:

```bash
export TRON_NETWORK="mainnet"
```

---

## 🔍 Security Checklist

Before using in production:

- [ ] Using a dedicated test wallet (not main wallet)
- [ ] Private key stored securely (environment variables preferred)
- [ ] Config file permissions set to 600
- [ ] Config file not in git repository
- [ ] Tested on Nile testnet first
- [ ] Wallet funded with minimal amounts
- [ ] Regular balance monitoring set up
- [ ] Backup of private key stored securely offline

---

## 🚨 If Your Key is Compromised

1. **Immediately transfer all funds** to a new wallet
2. **Generate a new private key**
3. **Update your configuration**
4. **Review recent transactions** for unauthorized activity
5. **Investigate how the leak occurred**

---

## 📚 Additional Resources

- **TRON Documentation**: https://developers.tron.network/
- **TronLink Wallet**: https://www.tronlink.org/
- **Nile Testnet Explorer**: https://nile.tronscan.org/
- **mcp-server-tron**: https://github.com/bankofai/mcp-server-tron

---

## 💡 Best Practices Summary

1. **Use environment variables** for key storage
2. **Use a dedicated test wallet** with limited funds
3. **Test on Nile** before using mainnet
4. **Monitor your wallet** regularly
5. **Never share** your private key
6. **Keep backups** secure and offline

---

**Remember**: The installer offers both methods. Choose Method 1 (environment variables) for better security! 🔐
