# Skills-Tron Installer

This directory contains the installation script for deploying Skills-Tron skills to OpenClaw.

## 📦 Installation

### Install Skills

```bash
cd skills-tron/installer
./install-skills.sh
```

**What it does**:
- ✅ Copies skill files to `~/.openclaw/skills/`
- ✅ Currently installs: `sunswap`
- ✅ No dependencies required (just file copying)

---

## 📋 Requirements

- **For Skills**: None (just file copying)
- **For Execution**: [OpenClaw Extension](https://github.com/bankofai/openclaw-extension)

---

## 🚀 Usage

```bash
# Update skill files
./install-skills.sh
```

---

## 🧪 Testing

After installation:

```bash
# Check skills installed
ls -la ~/.openclaw/skills/sunswap/
```

### Quick Test in OpenClaw

```
"Read the sunswap skill and help me check USDT/TRX price"
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

- `install-skills.sh` - Skills installer script
- `README.md` - This file

---

## 🔗 Links

- **Main Repository**: https://github.com/bankofai/skills-tron
- **[OpenClaw Extension](https://github.com/bankofai/openclaw-extension)** - Required for TRON skills
- **[OpenClaw](https://github.com/openclaw)** - Main agent framework
