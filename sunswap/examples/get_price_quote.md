# Price Quote Example

This example shows how to get a price quote from SunSwap without executing a swap.

## Scenario

User wants to check the current price for swapping **50 USDT** to **TRX**.

---

## Step 1: Prepare Token Addresses

From `resources/common_tokens.json`:
- **USDT**: `TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t`
- **WTRX**: `TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR`

---

## Step 2: Call getAmountsOut

**Tool**: `read_contract`

```json
{
  "contractAddress": "TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax",
  "functionName": "getAmountsOut",
  "args": [
    "50000000",
    ["TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", "TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR"]
  ],
  "network": "mainnet"
}
```

**Parameters**:
- `50000000` = 50 USDT (6 decimals)
- Path: [USDT, WTRX]

---

## Step 3: Parse Result

**Expected Output**:
```json
{
  "result": ["50000000", "192500000"]
}
```

**Interpretation**:
- Input: 50 USDT
- Output: 192.5 TRX (192,500,000 / 10^6)
- **Unit price**: 1 USDT = 3.85 TRX
- **Total value**: 50 × 3.85 = 192.5 TRX

---

## Step 4: Calculate Price Impact (Optional)

For larger swaps, calculate price impact:

```python
# Assume pool reserves (example values)
reserve_usdt = 1_000_000  # 1M USDT
reserve_trx = 3_850_000   # 3.85M TRX

# Initial price
initial_price = reserve_trx / reserve_usdt  # 3.85 TRX/USDT

# Your swap
amount_in = 50
amount_out = 192.5
actual_price = amount_out / amount_in  # 3.85 TRX/USDT

# Price impact
price_impact = abs((actual_price - initial_price) / initial_price) * 100
# Result: ~0% (negligible for small swap)
```

**Price Impact Guidelines**:
- < 1%: ✅ Excellent
- 1-3%: ⚠️ Acceptable
- 3-5%: ⚠️ High (consider splitting)
- \> 5%: ❌ Very high (not recommended)

---

## Multiple Price Quotes

Query multiple pairs at once:

### USDT → TRX
```json
{
  "contractAddress": "TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax",
  "functionName": "getAmountsOut",
  "args": ["50000000", ["TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", "TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR"]],
  "network": "mainnet"
}
```

### USDT → USDD
```json
{
  "contractAddress": "TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax",
  "functionName": "getAmountsOut",
  "args": ["50000000", ["TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", "TPYmHEhy5n8TCEfYGqW2rPxsghSfzghPDn"]],
  "network": "mainnet"
}
```

**Compare prices** to find the best rate.

---

## Summary

**Price quote retrieved successfully!**

- Input: 50 USDT
- Output: 192.5 TRX
- Price: 1 USDT = 3.85 TRX
- No transaction executed (read-only)

---

**Example completed**: 2026-02-07
