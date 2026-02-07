---
name: SunSwap DEX Trading
description: Execute token swaps on SunSwap DEX using TRON blockchain via mcp-server-tron
version: 1.0.0
dependencies:
  - mcp-server-tron
tags:
  - defi
  - dex
  - swap
  - tron
  - sunswap
  - trading
---

# SunSwap DEX Trading Skill

## Overview

This skill enables AI agents to execute token swaps on **SunSwap**, the leading decentralized exchange (DEX) on the TRON blockchain. It provides step-by-step instructions for:

- 💱 **Getting price quotes** from SunSwap liquidity pools
- 🔄 **Executing token swaps** with slippage protection
- ✅ **Approving tokens** for the SunSwap Router
- 📊 **Calculating price impact** and optimal routes

**How it works**: This skill uses `mcp-server-tron` tools (`read_contract`, `write_contract`) to interact with SunSwap smart contracts.

---

## Prerequisites

Before using this skill, ensure:

1. ✅ **mcp-server-tron is configured** in your MCP client (Claude Desktop, Cursor, or Antigravity)
2. ✅ **TRON wallet is set up** with `TRON_PRIVATE_KEY` environment variable
3. ✅ **Network access** to TRON mainnet or testnet
4. ✅ **Sufficient TRX** for gas fees (typically 10-50 TRX)
5. ✅ **Token balance** for the swap (e.g., USDT, USDD)

**Verify mcp-server-tron**:
```bash
# Check if mcp-server-tron is available
# In your AI agent, try: "Get my wallet address using mcp-server-tron"
```

---

## Core Concepts

### SunSwap Router

The **SunSwap Router** is the main contract for executing swaps:
- **Mainnet**: `TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax`
- **Nile Testnet**: Limited liquidity, use mainnet for production

### Key Functions

| Function | Purpose | Type |
|----------|---------|------|
| `getAmountsOut` | Get price quote | Read |
| `swapExactTokensForTokens` | Execute swap (exact input) | Write |
| `approve` (on token) | Approve Router to spend tokens | Write |

### Slippage Protection

**Slippage** = difference between expected and actual price

**Recommended slippage**:
- Stablecoins (USDT/USDD): 0.1% - 0.5%
- Major tokens (TRX/BTC): 0.5% - 1%
- Volatile tokens: 1% - 3%

---

## Usage Instructions

### Workflow 1: Get Price Quote

**Scenario**: User wants to know how much TRX they'll get for 100 USDT.

#### Step 1: Load Token Addresses

Refer to `resources/common_tokens.json` for addresses:
- **USDT**: `TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t`
- **WTRX**: `TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR`

#### Step 2: Call `getAmountsOut`

Use `read_contract` tool from mcp-server-tron:

```json
{
  "contractAddress": "TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax",
  "functionName": "getAmountsOut",
  "args": [
    "100000000",
    ["TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", "TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR"]
  ],
  "network": "mainnet"
}
```

**Parameters**:
- `args[0]`: Amount in (100 USDT = 100,000,000 in smallest unit, 6 decimals)
- `args[1]`: Path array [tokenIn, tokenOut]

#### Step 3: Parse Result

Expected output:
```json
{
  "result": ["100000000", "385000000"]
}
```

**Interpretation**:
- Input: 100 USDT
- Output: 385 TRX (385,000,000 / 1,000,000 = 385 TRX)
- Price: 1 USDT = 3.85 TRX

---

### Workflow 2: Execute Token Swap

**Scenario**: User wants to swap 100 USDT for TRX with 1% slippage.

#### Step 1: Get Price Quote

Follow **Workflow 1** to get expected output amount.

Example result: 385 TRX expected

#### Step 2: Calculate Minimum Output (Slippage Protection)

```python
# Python calculation
expected_output = 385_000_000  # 385 TRX in smallest unit
slippage = 0.01  # 1%
min_output = int(expected_output * (1 - slippage))
# Result: 381_150_000 (381.15 TRX minimum)
```

**Use the helper script**:
```bash
cd skills/sunswap
python scripts/validate_swap.py --amount 385 --slippage 0.01
# Output: min_amount=381150000
```

#### Step 3: Check Token Allowance

Before swapping, check if Router is approved to spend your USDT:

```json
{
  "contractAddress": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",
  "functionName": "allowance",
  "args": [
    "YOUR_WALLET_ADDRESS",
    "TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax"
  ],
  "network": "mainnet"
}
```

**If allowance < swap amount**, proceed to Step 4. Otherwise, skip to Step 5.

#### Step 4: Approve USDT (if needed)

Use `write_contract` to approve:

```json
{
  "contractAddress": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",
  "functionName": "approve",
  "args": [
    "TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax",
    "200000000"
  ],
  "network": "mainnet"
}
```

**Parameters**:
- `args[0]`: Spender (SunSwap Router)
- `args[1]`: Amount to approve (200 USDT = 2x swap amount for future use)

**Wait for confirmation** (check transaction with `get_transaction_info`).

#### Step 5: Execute Swap

Use `write_contract` to call `swapExactTokensForTokens`:

```json
{
  "contractAddress": "TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax",
  "functionName": "swapExactTokensForTokens",
  "args": [
    "100000000",
    "381150000",
    ["TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", "TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR"],
    "YOUR_WALLET_ADDRESS",
    "1739000000"
  ],
  "network": "mainnet"
}
```

**Parameters**:
- `args[0]`: Amount in (100 USDT)
- `args[1]`: Minimum amount out (381.15 TRX with 1% slippage)
- `args[2]`: Path [USDT, WTRX]
- `args[3]`: Recipient address (your wallet)
- `args[4]`: Deadline (Unix timestamp, e.g., 5 minutes from now)

**Generate deadline**:
```python
import time
deadline = int(time.time()) + 300  # 5 minutes from now
```

#### Step 6: Verify Transaction

After receiving `txHash`, check status:

```json
{
  "txHash": "0xabc123...",
  "network": "mainnet"
}
```

Use `get_transaction_info` tool to verify:
- Transaction succeeded
- Actual output amount
- Gas fees paid

---

## Examples

Detailed examples are available in the `examples/` directory:

- **[swap_usdt_to_trx.md](examples/swap_usdt_to_trx.md)** - Complete swap workflow
- **[get_price_quote.md](examples/get_price_quote.md)** - Price query only
- **[multi_hop_swap.md](examples/multi_hop_swap.md)** - Advanced: A→B→C swaps

---

## Error Handling

### Common Errors and Solutions

#### Error: "Insufficient allowance"

**Cause**: Token not approved for Router, or approval amount too low.

**Solution**:
1. Check allowance with `allowance` function
2. Call `approve` with sufficient amount
3. Wait for approval transaction to confirm
4. Retry swap

#### Error: "INSUFFICIENT_OUTPUT_AMOUNT"

**Cause**: Actual output is less than `amountOutMin` (slippage exceeded).

**Solution**:
1. Increase slippage tolerance (e.g., from 1% to 2%)
2. Recalculate `amountOutMin`
3. Retry swap
4. Or split into smaller swaps to reduce price impact

#### Error: "EXPIRED"

**Cause**: Transaction deadline passed.

**Solution**:
1. Generate new deadline (current time + 300 seconds)
2. Retry swap with new deadline

#### Error: "Insufficient TRX balance"

**Cause**: Not enough TRX for gas fees.

**Solution**:
1. Check TRX balance with `get_balance`
2. Transfer TRX to wallet
3. Retry swap

#### Error: "K"

**Cause**: Liquidity pool invariant violated (usually due to insufficient liquidity).

**Solution**:
1. Reduce swap amount
2. Check pool liquidity
3. Consider alternative DEX or route

---

## Security Considerations

> [!WARNING]
> **Slippage Protection**: Always set `amountOutMin` to prevent sandwich attacks. Never use 0 or extremely low values.

> [!CAUTION]
> **Approval Amounts**: Only approve what you need. Avoid unlimited approvals (`2^256-1`) unless you fully trust the contract.

> [!NOTE]
> **Testnet First**: Always test swaps on Nile testnet before executing on mainnet with real funds.

### Best Practices

1. **Start Small**: Test with small amounts first
2. **Check Prices**: Compare SunSwap price with other DEXs
3. **Monitor Gas**: Ensure sufficient TRX for fees (10-50 TRX recommended)
4. **Verify Addresses**: Double-check token and router addresses
5. **Use Deadlines**: Set reasonable deadlines (5-10 minutes)

---

## Advanced Usage

### Multi-Hop Swaps

For tokens without direct pairs, use multi-hop:

**Example**: USDT → USDD → BTT

```json
{
  "args": [
    "100000000",
    "min_amount_out",
    ["USDT_ADDRESS", "USDD_ADDRESS", "BTT_ADDRESS"],
    "recipient",
    "deadline"
  ]
}
```

SunSwap Router automatically finds the best route.

### Price Impact Calculation

```python
# Calculate price impact
initial_price = reserve_out / reserve_in
final_price = amount_out / amount_in
price_impact = abs((final_price - initial_price) / initial_price)

# Warn if > 5%
if price_impact > 0.05:
    print("WARNING: High price impact!")
```

---

## Resources

- **[sunswap_contracts.json](resources/sunswap_contracts.json)** - Contract addresses
- **[common_tokens.json](resources/common_tokens.json)** - Token addresses
- **[validate_swap.py](scripts/validate_swap.py)** - Helper script

---

## Troubleshooting

### Skill Not Working?

1. **Check mcp-server-tron**: Verify it's configured and running
2. **Check wallet**: Ensure `TRON_PRIVATE_KEY` is set
3. **Check network**: Confirm you're on the right network (mainnet/nile)
4. **Check balances**: Verify sufficient token and TRX balances

### Need Help?

- Review examples in `examples/` directory
- Check mcp-server-tron documentation
- Test with small amounts on testnet first

---

**Version**: 1.0.0  
**Last Updated**: 2026-02-07  
**Maintainer**: TRC-8004 Team
