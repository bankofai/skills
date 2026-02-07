# SunSwap Skill

A comprehensive skill for executing token swaps on SunSwap DEX via TRON blockchain.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE)
[![TRON](https://img.shields.io/badge/Blockchain-TRON-red)](https://tron.network/)

## Quick Start

1. **Prerequisites**: Ensure `mcp-server-tron` is configured in your MCP client
2. **Read**: [SKILL.md](SKILL.md) for complete instructions
3. **Try**: Examples in [examples/](examples/) directory

## Files

- **[SKILL.md](SKILL.md)** - Main skill definition with step-by-step instructions
- **[examples/swap_usdt_to_trx.md](examples/swap_usdt_to_trx.md)** - Complete swap workflow
- **[examples/get_price_quote.md](examples/get_price_quote.md)** - Price query example
- **[resources/sunswap_contracts.json](resources/sunswap_contracts.json)** - Contract addresses
- **[resources/common_tokens.json](resources/common_tokens.json)** - Token addresses
- **[scripts/validate_swap.py](scripts/validate_swap.py)** - Parameter validation helper

## Usage

### For AI Agents

Read `SKILL.md` and follow the instructions for:
- Getting price quotes
- Executing swaps with slippage protection
- Handling errors

### For Developers

Test the validation script:
```bash
cd skills/sunswap
python scripts/validate_swap.py --amount 385 --slippage 0.01
```

## Dependencies

- `mcp-server-tron` - TRON blockchain MCP server

## Features

- ✅ Real-time price quotes from SunSwap liquidity pools
- ✅ Token swap execution with slippage protection
- ✅ Automatic token approval handling
- ✅ Transaction verification
- ✅ Error handling and recovery

## Supported Networks

- **Mainnet**: Production TRON network
- **Nile Testnet**: Limited liquidity (use for testing)

## Version

1.0.0 (2026-02-07)

## License

MIT - see [LICENSE](../LICENSE) for details
