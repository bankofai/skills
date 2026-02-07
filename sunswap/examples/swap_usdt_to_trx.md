# Complete Swap Example: USDT → TRX

This example demonstrates a complete token swap workflow using the SunSwap skill.

## Scenario

User wants to swap **100 USDT** for **TRX** on TRON mainnet with **1% slippage tolerance**.

---

## Prerequisites

- ✅ mcp-server-tron configured
- ✅ Wallet with USDT balance ≥ 100
- ✅ Wallet with TRX balance ≥ 20 (for gas fees)

---

## Step-by-Step Execution

### Step 1: Check Wallet Balance

First, verify you have sufficient USDT:

**Tool**: `get_token_balance`

```json
{
  "address": "YOUR_WALLET_ADDRESS",
  "tokenAddress": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",
  "network": "mainnet"
}
```

**Expected Output**:
```json
{
  "balance": {
    "raw": "150000000",
    "formatted": "150.0",
    "symbol": "USDT"
  }
}
```

✅ **Confirmed**: Wallet has 150 USDT (sufficient for 100 USDT swap)

---

### Step 2: Get Price Quote

Query SunSwap Router for expected output:

**Tool**: `read_contract`

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

**Parameters Explained**:
- `100000000` = 100 USDT (6 decimals: 100 × 10^6)
- Path: [USDT address, WTRX address]

**Expected Output**:
```json
{
  "result": ["100000000", "385000000"]
}
```

**Interpretation**:
- Input: 100 USDT
- Expected output: 385 TRX (385,000,000 / 10^6)
- **Price**: 1 USDT = 3.85 TRX

---

### Step 3: Calculate Minimum Output (Slippage Protection)

With 1% slippage tolerance:

```
Expected output: 385 TRX
Slippage: 1% = 0.01
Minimum output: 385 × (1 - 0.01) = 381.15 TRX
In smallest unit: 381,150,000
```

**Use helper script**:
```bash
cd skills/sunswap
python scripts/validate_swap.py --amount 385 --slippage 0.01
```

**Output**:
```
Minimum amount: 381150000
Deadline: 1739000400
```

---

### Step 4: Check Token Allowance

Check if SunSwap Router is approved to spend your USDT:

**Tool**: `read_contract`

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

**Expected Output** (if never approved):
```json
{
  "result": "0"
}
```

❌ **Allowance is 0** → Need to approve (proceed to Step 5)

**If allowance ≥ 100000000**, skip to Step 6.

---

### Step 5: Approve USDT

Approve SunSwap Router to spend 200 USDT (2x swap amount for future use):

**Tool**: `write_contract`

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

**Expected Output**:
```json
{
  "txHash": "0xabc123...",
  "message": "Transaction sent. Use get_transaction_info to check confirmation."
}
```

**Wait for confirmation** (typically 3-6 seconds on TRON):

**Tool**: `get_transaction_info`

```json
{
  "txHash": "0xabc123...",
  "network": "mainnet"
}
```

**Verify**:
```json
{
  "ret": [{"contractRet": "SUCCESS"}]
}
```

✅ **Approval confirmed**

---

### Step 6: Execute Swap

Now execute the swap with all parameters:

**Tool**: `write_contract`

```json
{
  "contractAddress": "TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax",
  "functionName": "swapExactTokensForTokens",
  "args": [
    "100000000",
    "381150000",
    ["TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", "TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR"],
    "YOUR_WALLET_ADDRESS",
    "1739000400"
  ],
  "network": "mainnet"
}
```

**Parameters**:
1. `100000000` - Amount in (100 USDT)
2. `381150000` - Minimum amount out (381.15 TRX, 1% slippage)
3. `[USDT, WTRX]` - Swap path
4. `YOUR_WALLET_ADDRESS` - Recipient
5. `1739000400` - Deadline (Unix timestamp)

**Expected Output**:
```json
{
  "txHash": "0xdef456...",
  "message": "Transaction sent. Use get_transaction_info to check confirmation."
}
```

---

### Step 7: Verify Swap Result

Check transaction details:

**Tool**: `get_transaction_info`

```json
{
  "txHash": "0xdef456...",
  "network": "mainnet"
}
```

**Expected Output**:
```json
{
  "ret": [{"contractRet": "SUCCESS"}],
  "log": [
    {
      "topics": ["Transfer", "..."],
      "data": "..."
    }
  ],
  "fee": 15000000
}
```

**Verify**:
- ✅ `contractRet`: "SUCCESS"
- ✅ Fee paid: ~15 TRX
- ✅ Logs show token transfers

---

### Step 8: Check Final Balance

Verify TRX received:

**Tool**: `get_balance`

```json
{
  "address": "YOUR_WALLET_ADDRESS",
  "network": "mainnet"
}
```

**Expected Output**:
```json
{
  "balance": {
    "trx": "1385.5"
  }
}
```

**Calculation**:
- Previous balance: ~1000 TRX
- Received from swap: ~385 TRX
- Gas fees paid: ~15 TRX
- **Final balance**: 1000 + 385 - 15 = 1370 TRX ✅

---

## Summary

**Swap Completed Successfully!**

- ✅ Swapped: 100 USDT
- ✅ Received: ~385 TRX
- ✅ Slippage: < 1% (within tolerance)
- ✅ Gas fees: ~15 TRX
- ✅ Total time: ~30 seconds

---

## Troubleshooting

### If swap fails with "INSUFFICIENT_OUTPUT_AMOUNT"

**Cause**: Price moved, actual output < minimum

**Solution**:
1. Get fresh price quote (Step 2)
2. Increase slippage to 2%
3. Retry swap

### If approval fails

**Cause**: Insufficient TRX for gas

**Solution**:
1. Check TRX balance
2. Ensure ≥ 20 TRX available
3. Retry approval

---

**Example completed**: 2026-02-07
