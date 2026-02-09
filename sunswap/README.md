# SunSwap Skill

Execute token swaps on SunSwap DEX using Smart Router for optimal routing across V1/V2/V3/PSM pools.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE)
[![TRON](https://img.shields.io/badge/Blockchain-TRON-red)](https://tron.network/)

## Quick Start

**Instructions**: Read [SKILL.md](SKILL.md) for complete usage instructions.

## Files

- **[SKILL.md](SKILL.md)** - Complete skill documentation
- **[examples/swap_usdt_to_trx.md](examples/swap_usdt_to_trx.md)** - Full swap example
- **[resources/sunswap_contracts.json](resources/sunswap_contracts.json)** - Contract addresses, API endpoints, ABIs
- **[resources/common_tokens.json](resources/common_tokens.json)** - Token addresses and decimals

## Networks

| Network | Smart Router | API Endpoint |
|---------|-------------|--------------|
| **Mainnet** | `TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax` | `https://rot.endjgfsv.link/swap/router` |
| **Nile** | `TMEkn7zwGJvJsRoEkiTKfGRGZS2yMdVmu3` | `https://tnrouter.endjgfsv.link/swap/router` |

## Critical Notes

> [!WARNING]
> **Version Merging**: Merge consecutive identical pool versions (e.g., `["v2", "v2"]` -> `["v2"]`).
> **Token Count**: `versionLen` must sum to `path.length` (token count).
> **Fee Length**: `fees` length must strictly equal `path.length` (do not truncate!).

```javascript
// ✅ Correct Logic:
const poolVersion = mergeConsecutive(response.poolVersions);
const versionLen = calculateTokenCounts(response.poolVersions);
const fees = response.poolFees.map(f => parseInt(f)); // Full length
```

> [!NOTE]
> **Nile Testnet**: Always provide `abi` parameter when calling contracts on Nile.

## Dependencies

- [OpenClaw Extension](https://github.com/bankofai/openclaw-extension)

## Version

1.0.0 (2026-02-09)

## License

MIT - see [LICENSE](../LICENSE) for details
