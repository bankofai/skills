# Skills-Tron Installer

This directory contains installation scripts for deploying Skills-Tron to OpenClaw.

## 📦 Installation Scripts

### Quick Install (Recommended)

Install everything in one command:

```bash
cd skills-tron/installer
./install.sh
```

This runs both scripts below automatically.

---

### Individual Scripts

#### 1. Install Skills Only

```bash
./install-skills.sh
```

**What it does**:
- ✅ Copies skill files to `~/.openclaw/skills/`
- ✅ Currently installs: `sunswap`
- ✅ No dependencies required (just file copying)

**Use when**: You already have `mcp-server-tron` configured and just want to add/update skills.

---

#### 2. Configure MCP Server Only

```bash
./install-mcp-server.sh
```

**What it does**:
- ✅ Configures `mcp-server-tron` in `~/.mcporter/mcporter.json`
- ✅ Offers two security options:
  - Environment variables (recommended)
  - Config file storage
- ✅ Handles JSON merging (won't overwrite existing config)

**Use when**: You need to configure or reconfigure the MCP server.

---

## 🔐 Security

The MCP server installer offers two methods:

1. **Environment Variables** (Recommended) - Keys in `~/.zshrc` or `~/.bashrc`
2. **Config File** - Keys in `~/.mcporter/mcporter.json`

See [SECURITY.md](SECURITY.md) for detailed security guidance.

---

## 📋 Requirements

- **For Skills**: None (just file copying)
- **For MCP Server**:
  - Node.js (v18+)
  - Python 3
  - TRON private key (optional, can configure later)

---

## 🚀 Usage Examples

### First Time Setup

```bash
# Install everything
./install.sh
```

### Update Skills Only

```bash
# Just update skill files
./install-skills.sh
```

### Reconfigure MCP Server

```bash
# Change security method or update keys
./install-mcp-server.sh
```

---

## 🧪 Testing

After installation:

```bash
# Check skills installed
ls -la ~/.openclaw/skills/sunswap/

# Check MCP config
cat ~/.mcporter/mcporter.json | grep mcp-server-tron
```

**Important**: Restart OpenClaw to load new configuration!

See [VERIFICATION.md](VERIFICATION.md) for detailed verification steps.

### Quick Test in OpenClaw

After restarting OpenClaw:

```
1. "What MCP servers are available?"
   → Should list mcp-server-tron

2. "Get my TRON wallet address"
   → Should return your address

3. "Read the sunswap skill and help me check USDT/TRX price"
   → Should query SunSwap and return price
```

---

## 🛠 For Developers

If you're developing skills locally, you don't need these installers. Just work directly in the skill directories:

```bash
cd skills-tron/sunswap
# Edit SKILL.md, test with your AI agent
```

---

## 📝 Files

- `install.sh` - Complete installer (runs both scripts)
- `install-skills.sh` - Skills installer only
- `install-mcp-server.sh` - MCP server configurator only
- `install-for-openclaw.sh` - Legacy combined script (deprecated)
- `README.md` - This file
- `SECURITY.md` - Security best practices
- `VERIFICATION.md` - How to verify installation works
- `TESTING.md` - Testing guide

---

## 🔗 Links

- **Main Repository**: https://github.com/bankofai/skills-tron
- **MCP Server**: https://github.com/bankofai/mcp-server-tron
- **OpenClaw**: https://github.com/openclaw
