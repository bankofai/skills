# Changelog

## [1.0.0] - 2026-02-09

### Added
- **Initial release of the Skills Repository**
- **SunSwap Smart Router Skill** (Mainnet & Nile):
  - **Core Features**: Smart Router integration for optimal routing across V1/V2/V3/PSM pools with slippage protection.
  - **Workflow**: 5-step execution process (Token Lookup -> Price Quote -> Balance Check -> Approve -> Execute Swap).
  - **Safety**: `INTENT_LOCK.md` protocol to prevent TRX/WTRX mix-ups and ensure user intent is respected.
  - **Tools**: Helper scripts `lookup_token.js` for address finding and `format_swap_params.js` for parameter formatting.
  - **Documentation**: Comprehensive guides, troubleshooting, and complete swap examples.
- **Project Documentation**:
  - `AGENTS.md`: New developer guidelines for creating skills.
  - `PROJECT_STRUCTURE.md`: Detailed project organization and file structure.
- **Installation & Setup**:
  - `install-skills.sh`: Standalone script to verify and install skills to `~/.openclaw/skills/`.
  - `install-mcp-server.sh`: Interactive configuration tool for `mcp-server-tron` with security best practices.
  - **Security**: Added `SECURITY.md` detailing private key management (recommending environment variables).

### Fixed
- Standardized project structure and naming conventions
