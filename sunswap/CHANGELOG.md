# SunSwap Skill Changelog

## Version 1.0.0 (2026-02-09)

### 🎉 Initial Release

First stable release of the SunSwap DEX Trading Skill for TRON blockchain.

---

## Features

### Core Workflow

**5-Step Swap Process:**
1. **Step 0**: Token Address Lookup (optional)
2. **Step 1**: Price Quote - Query SunSwap Smart Router API
3. **Step 2**: Balance & Allowance Check - Verify wallet balance and token approval
4. **Step 3**: Approve Token (conditional) - Authorize router if needed
5. **Step 4**: Execute Swap - Perform the token swap

### Documentation

**Main Files:**
- `SKILL.md` - Complete skill documentation with quick reference card
- `README.md` - Quick start guide
- `INTENT_LOCK.md` - Critical rules for TRX vs WTRX handling

**Workflow Files:**
- `workflow/00_token_lookup.md` - Token address lookup
- `workflow/01_price_quote.md` - Get swap quote from API
- `workflow/02_balance_check.md` - Verify balance and allowance
- `workflow/03_approve.md` - Approve token spending
- `workflow/04_execute_swap.md` - Execute the swap

**Examples:**
- `examples/complete_swap_example.md` - Full TRX → USDJ swap walkthrough
- `examples/swap_with_approve.md` - Full USDT → TRX swap with approval
- `examples/README.md` - Examples overview

### Tools & Resources

**Helper Scripts:**
- `scripts/lookup_token.js` - Quick token address finder
- `scripts/format_swap_params.js` - Convert API quote to transaction parameters

**Resource Files:**
- `resources/common_tokens.json` - Token registry (USDT, WTRX, TRX, USDC, etc.)
- `resources/sunswap_contracts.json` - Contract addresses and ABIs

### Key Features

✅ **Smart Router Integration** - Optimal routing across V1/V2/V3/PSM/Curve pools
✅ **Multi-Network Support** - Mainnet and Nile testnet
✅ **TRX vs WTRX Handling** - Clear distinction and warnings
✅ **Gas Fee Estimates** - Detailed gas requirements for each operation
✅ **Complete Examples** - Real-world swap walkthroughs with actual outputs
✅ **Interactive Checklists** - Step-by-step verification at each stage
✅ **Error Handling** - Common errors and solutions documented
✅ **Decoupled Design** - Not tied to specific MCP implementation

---

## Network Support

| Network | Smart Router | API Endpoint |
|---------|-------------|--------------|
| **Mainnet** | `TMEkn7zwGJvJsRoEkiTKfGRGZS2yMdVmu3` | `https://rot.endjgfsv.link/swap/router` |
| **Nile** | `TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax` | `https://tnrouter.endjgfsv.link/swap/router` |

---

## Dependencies

- **mcp-server-tron** - TRON blockchain MCP server for transaction execution

---

## Usage

### Quick Start

```bash
# 1. Find token addresses
node scripts/lookup_token.js USDT nile

# 2. Get price quote
curl 'https://tnrouter.endjgfsv.link/swap/router?fromToken=<FROM>&toToken=<TO>&amountIn=<AMOUNT>&typeList=PSM,CURVE,CURVE_COMBINATION,WTRX,SUNSWAP_V1,SUNSWAP_V2,SUNSWAP_V3'

# 3. Convert parameters
node scripts/format_swap_params.js '<quote_json>' '<recipient>' '<network>' [slippage]

# 4. Execute swap
# Use the output from step 3 with your TRON transaction tool
```

### For AI Agents

Tell your AI agent:
```
Please read skills/sunswap/SKILL.md and help me swap 10 USDT to TRX on Nile testnet
```

---

## Documentation Structure

```
sunswap/
├── SKILL.md                    # Main documentation (AI agents read this)
├── README.md                   # Quick start guide
├── CHANGELOG.md                # This file
├── INTENT_LOCK.md              # TRX vs WTRX rules
├── workflow/                   # Step-by-step guides
│   ├── 00_token_lookup.md
│   ├── 01_price_quote.md
│   ├── 02_balance_check.md
│   ├── 03_approve.md
│   └── 04_execute_swap.md
├── examples/                   # Complete examples
│   ├── README.md
│   ├── complete_swap_example.md
│   └── swap_with_approve.md
├── resources/                  # Configuration files
│   ├── common_tokens.json
│   └── sunswap_contracts.json
└── scripts/                    # Helper tools
    ├── lookup_token.js
    └── format_swap_params.js
```

---

## Critical Rules

1. **Respect User's Token Choice** - Never substitute TRX for WTRX or vice versa
2. **Check Balance First** - Always verify sufficient balance before attempting swap
3. **Approve When Needed** - TRC20 tokens require approval, native TRX does not
4. **Use Helper Scripts** - Don't manually construct parameters
5. **Verify Gas Fees** - Ensure at least 100 TRX for gas

---

## Known Limitations

- Nile testnet requires explicit ABI parameters for contract calls
- Price quotes are time-sensitive and should be refreshed before execution
- Slippage tolerance should be higher on testnet (10%) vs mainnet (0.5-2%)

---

## Future Improvements

Potential enhancements for future versions:
- [ ] Add more token swap examples
- [ ] Create interactive validation script
- [ ] Add price impact calculator
- [ ] Create swap simulator for testing
- [ ] Add transaction monitoring tool
- [ ] Support for limit orders
- [ ] Multi-hop swap optimization guide

---

## License

MIT License - See [LICENSE](../../LICENSE) for details

---

**Version**: 1.0.0  
**Date**: 2026-02-09  
**Author**: bankofai  
**Repository**: [bankofai/skills-tron](https://github.com/bankofai/skills-tron)
