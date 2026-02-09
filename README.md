# Skills Repository

AI Agent Skills Library - Reusable capability modules for AI agents

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub](https://img.shields.io/badge/GitHub-bankofai%2Fskills--tron-blue)](https://github.com/bankofai/skills-tron)

## What is a Skill?

A **Skill** is a document containing detailed instructions that teaches AI agents how to accomplish specific tasks.

**Analogy**: Like providing an "operation manual" to AI, telling it how to use tools to get work done.

```
User: "Help me swap USDT for TRX"
  ↓
AI Agent reads SunSwap Skill
  ↓
AI Agent follows SKILL.md instructions
  ↓
Calls mcp-server-tron tools
  ↓
Completes DEX trade
```

---

## Quick Start

### For OpenClaw Users (Recommended)

**Complete installation** (skills + MCP server):
```bash
git clone https://github.com/bankofai/skills-tron.git
cd skills-tron/installer
./install-skills.sh
```



This will install skills to `~/.openclaw/skills/`.

**Note**: You also need the [OpenClaw Extension](https://github.com/bankofai/openclaw-extension) for these skills to work.

### For Developers / Manual Installation

#### 1. Clone Repository

```bash
git clone https://github.com/bankofai/skills-tron.git
cd skills-tron
```

#### 2. Browse Available Skills

```bash
ls -la
```

Currently available:
- **sunswap/** - SunSwap DEX Trading (TRON token swaps)

#### 3. Use a Skill

Tell your AI Agent:
```
Please read skills/sunswap/SKILL.md and help me check how much TRX I can get for 100 USDT
```

The AI Agent will:
1. Read SKILL.md
2. Call appropriate tools following instructions
3. Return results

---

## Repository Structure

```
skills-tron/
├── README.md              # This file - Overview
├── LICENSE                # MIT License
├── CONTRIBUTING.md        # Contribution guidelines
├── AGENTS.md              # Developer guide (how to create new skills)
└── sunswap/               # SunSwap DEX Trading skill
    ├── README.md          # Skill description
    ├── SKILL.md           # Main instruction file (AI Agent reads this)
    ├── examples/          # Usage examples
    ├── resources/         # Configuration files (contract addresses, token lists, etc.)
    └── scripts/           # Helper scripts
```

---

## Available Skills

### 🔄 SunSwap DEX Trading

**Function**: Execute token swaps on TRON blockchain

**Dependencies**: `mcp-server-tron`

**Features**:
- Query DEX prices
- Execute token swaps
- Slippage protection

**Quick Start**: See [sunswap/README.md](sunswap/README.md)

---

## How to Use Skills

### Prerequisites

1. ✅ Installed AI Agent (OpenClaw)
2. ✅ Installed **OpenClaw Extension** (for TRON capabilities)
   - Download: [bankofai/openclaw-extension](https://github.com/bankofai/openclaw-extension)
   - Follow instructions in that repository to set up the MCP server.

---

## For Developers

### Creating a New Skill

See [AGENTS.md](AGENTS.md) for how to create new skills.

**Quick Template**:
```bash
# 1. Create directory
mkdir -p my-skill/{examples,resources,scripts}

# 2. Create SKILL.md
cat > my-skill/SKILL.md << 'EOF'
---
name: My Skill
description: What this skill does
version: 1.0.0
dependencies:
  - required-tool
tags:
  - category
---

# My Skill

## Overview
[Description]

## Usage Instructions
1. Step 1
2. Step 2
EOF
```

### Skill Specification

Each skill must include:
- ✅ **SKILL.md** - Main instruction file (with YAML frontmatter)
- ✅ **README.md** - Quick description
- ⚠️ **examples/** - Usage examples (recommended)
- ⚠️ **resources/** - Configuration files (optional)
- ⚠️ **scripts/** - Helper scripts (optional)

See [AGENTS.md](AGENTS.md) for details.

---

## FAQ

### Q: Do skills need separate installation?

**A**: ❌ No. Skills are just documents that AI agents read directly.

### Q: What's the difference between Skills and MCP Servers?

**A**: 
- **Skill** = Instruction document (teaches AI how to do something)
- **MCP Server** = Tool service (provides actual capabilities)

Skills tell AI how to use MCP Server tools.

### Q: How do I know what dependencies a skill needs?

**A**: Check the YAML frontmatter in SKILL.md:
```yaml
dependencies:
  - mcp-server-tron
```

### Q: What if AI Agent can't find the skill?

**A**: Tell it explicitly:
```
Please read skills/sunswap/SKILL.md
```

### Q: Can I modify skills?

**A**: ✅ Yes! Edit SKILL.md directly, AI Agent will read the latest version.

---

## Contributing

Contributions of new skills are welcome!

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Related Resources

- **[AGENTS.md](AGENTS.md)** - Skill development guide
- **[OpenClaw Extension](https://github.com/bankofai/openclaw-extension)** - TRON MCP Server & Tools
---

## License

MIT License - see [LICENSE](LICENSE) file for details

---

**Repository**: [bankofai/skills-tron](https://github.com/bankofai/skills-tron)  
**Last Updated**: 2026-02-09  
**Maintainer**: Bank of AI Team
