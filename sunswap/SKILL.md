---
name: SunSwap DEX Trading
description: Execute token swaps on SunSwap DEX for TRON blockchain.
version: 2.4.0
dependencies:
  - mcp-server-tron
tags:
  - defi
  - dex
  - swap
  - tron
  - sunswap
---

# SunSwap DEX Trading Skill

## 🚨 STOP! READ THIS FIRST - DO NOT SKIP!

**Before attempting any swap, read the Quick Reference Card below.**

**The ONLY correct workflow is documented below. Follow it exactly.**

---

## 🔴 CRITICAL: RESPECT USER'S EXACT TOKEN CHOICE - NEVER SUBSTITUTE!

**🚨 ABSOLUTE RULE: User says what token, you use EXACTLY that token for price quote and swap!**

**User says "TRX"** → Use `T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb` (native TRX, same on all networks)

**User says "WTRX"** → Use network-specific address:
- **Mainnet**: `TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR`
- **Nile**: `TYsbWxNnyTgsZaTFaue9hqpxkU3Fkco94a`

**NEVER EVER:**
- ❌ Assume user meant WTRX when they said TRX
- ❌ Assume user meant TRX when they said WTRX
- ❌ Substitute one for the other "for convenience"
- ❌ Change the token without explicit user confirmation

**ALWAYS:**
- ✅ Use the EXACT token symbol user specified
- ✅ Get price quote with the EXACT token user requested
- ✅ Execute swap with the EXACT token user requested
- ✅ If unclear, ASK the user to clarify

See [INTENT_LOCK.md](INTENT_LOCK.md) for detailed explanation.

---

## 🚀 Quick Reference Card

### ⚠️ CRITICAL STEPS CHECKLIST - DO NOT SKIP!

**Before executing ANY swap, verify these steps:**

| Step | Action | Required? | Skip Condition |
|------|--------|-----------|----------------|
| 1️⃣ | **Get Price Quote** | ✅ ALWAYS | Never skip |
| 2️⃣ | **Check Balance** | ✅ ALWAYS | Never skip |
| 3️⃣ | **Check Allowance** | ✅ ALWAYS (for TRC20) | Skip if input is native TRX |
| 4️⃣ | **Approve Token** | ⚠️ CONDITIONAL | Skip if: (1) input is TRX OR (2) allowance >= amountIn |
| 5️⃣ | **Execute Swap** | ✅ ALWAYS | Never skip |

**🔴 MOST COMMON MISTAKE: Forgetting Step 4 (Approve)**

**When you MUST approve:**
- ✅ Input token is TRC20 (USDT, WTRX, USDC, etc.)
- ✅ Allowance < swap amount
- ✅ First time swapping this token

**When you can SKIP approve:**
- ❌ Input token is native TRX (sent via `value` parameter)
- ❌ Already approved with sufficient allowance

---

### API Price Quote - Exact Format

**🚨 CRITICAL: Use EXACTLY the token addresses that match user's specified tokens!**

**Copy this template and replace the placeholders:**

```bash
curl 'https://tnrouter.endjgfsv.link/swap/router?fromToken=<FROM_ADDRESS>&toToken=<TO_ADDRESS>&amountIn=<RAW_AMOUNT>&typeList=PSM,CURVE,CURVE_COMBINATION,WTRX,SUNSWAP_V1,SUNSWAP_V2,SUNSWAP_V3'
```

**Parameter requirements:**
- `fromToken`: Input token address **EXACTLY as user specified** (e.g., if user says "TRX", use `T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb`)
- `toToken`: Output token address **EXACTLY as user specified** (e.g., if user says "USDT", use USDT address)
- `amountIn`: Raw integer amount (e.g., `1000000` for 1 TRX with 6 decimals)
- `typeList`: Always use the full list shown above

**⚠️ DO NOT substitute tokens! If user says "TRX", do NOT use WTRX address!**

### Complete Workflow

**Follow these steps in order - DO NOT SKIP ANY STEP:**

```bash
# Step 1: Get Price Quote (✅ REQUIRED - Always)
curl 'https://tnrouter.endjgfsv.link/swap/router?fromToken=<FROM_ADDRESS>&toToken=<TO_ADDRESS>&amountIn=<RAW_AMOUNT>&typeList=PSM,CURVE,CURVE_COMBINATION,WTRX,SUNSWAP_V1,SUNSWAP_V2,SUNSWAP_V3'

# Step 2: Check Balance (✅ REQUIRED - Always)
# Use mcp_mcp_server_tron_get_balance and read_contract (balanceOf)

# Step 3: Check Allowance (✅ REQUIRED for TRC20, ❌ Skip for TRX)
# Use read_contract with allowance function
# If input is native TRX → Skip to Step 5

# Step 4: Approve Token (⚠️ CONDITIONAL - Only if allowance < amountIn)
# 🔴 CRITICAL: Do NOT skip this if input is TRC20 token!
# If allowance >= amountIn → Skip to Step 5
# Otherwise: mcp_mcp_server_tron_write_contract (approve function)
# Wait for approval transaction to confirm before proceeding!

# Step 5: Convert Parameters (✅ REQUIRED - Always)
node skills/sunswap/scripts/format_swap_params.js '<quote_data[0]_json>' '<recipient_address>' '<network>' [slippage]

# Step 6: Execute Swap (✅ REQUIRED - Always)
# Use the JSON output from Step 5 as parameters for:
mcp_mcp_server_tron_write_contract({...output_from_step_5...})
```

### When is Approve Needed?

| Input Token | Approve Needed? | Reason |
|-------------|-----------------|--------|
| Native TRX | ❌ NO | Sent via `value` parameter |
| TRC20 (USDT, WTRX, etc.) | ✅ YES | Router needs permission to spend your tokens |
| Already approved | ❌ NO | If `allowance >= amountIn`, skip approve |

### Quick Token Lookup

```bash
# Find token address quickly
node skills/sunswap/scripts/lookup_token.js <SYMBOL> <NETWORK>
# Example: node skills/sunswap/scripts/lookup_token.js USDT nile
```

### Gas Fee Estimates

- **Approve**: ~5-10 TRX
- **Swap**: ~20-50 TRX  
- **Recommended**: Keep at least 100 TRX for gas

---

## 📋 Quick Start

This skill helps you execute token swaps on SunSwap DEX. Follow the workflow step-by-step.

**Before you start:**
- Ensure `mcp-server-tron` is configured
- Have your wallet set up with sufficient TRX for gas (minimum 100 TRX recommended)

---

## 🎯 User Communication Protocol

**CRITICAL**: You MUST communicate with the user at each step.

### Step Start Template
```
🔄 [Step N]: [Action Name]
📝 What I'm doing: [Brief description]
```

### Step Complete Template
```
✅ [Step N] Complete
📊 Result: [Key information]
➡️ Next: [What happens next]
```

### Error Template
```
❌ Error in [Step N]
🔍 Issue: [What went wrong]
💡 Solution: [How to fix]
```

---

## 🛠️ Execution Workflow

**Follow these steps in order. Each step is in a separate file to keep context focused.**

### Step 0: Token Address Lookup
**File**: [workflow/00_token_lookup.md](workflow/00_token_lookup.md)

**When to use**: If you don't have token addresses for the swap pair.

**User Message**:
```
🔍 Step 0: Looking up token addresses
📝 Checking: [TOKEN_SYMBOL] on [NETWORK]
```

---

### Step 1: Price Quote
**File**: [workflow/01_price_quote.md](workflow/01_price_quote.md)

**Always required**: Get the best swap route and expected output.

**🚨 CRITICAL**: Use EXACTLY the token symbols user specified. DO NOT substitute TRX for WTRX or vice versa!

**User Message**:
```
💰 Step 1: Getting price quote
📝 Querying: [AMOUNT] [FROM_TOKEN] → [TO_TOKEN]
📝 Using token addresses exactly as user specified
```

---

### Step 2: Balance & Allowance Check
**File**: [workflow/02_balance_check.md](workflow/02_balance_check.md)

**Always required**: Verify you have sufficient balance and token approval.

**User Message**:
```
📊 Step 2: Checking balance and allowance
📝 Verifying: Wallet balance and router approval
```

---

### Step 3: Approve Token (Conditional)
**File**: [workflow/03_approve.md](workflow/03_approve.md)

**When to use**: Only if input is a token (not TRX) AND allowance is insufficient.

**User Message**:
```
✅ Step 3: Approving token
📝 Approving: [TOKEN] for SunSwap Router
⏳ Please wait for confirmation...
```

---

### Step 4: Execute Swap
**File**: [workflow/04_execute_swap.md](workflow/04_execute_swap.md)

**Always required**: Execute the actual swap transaction.

**User Message**:
```
🔄 Step 4: Executing swap
📝 Swapping: [AMOUNT_IN] [TOKEN_IN] → [EXPECTED_OUT] [TOKEN_OUT]
⏳ Submitting transaction...
```

---

## 🔧 Helper Tools

### Parameter Formatter Script

**Location**: `skills/sunswap/scripts/format_swap_params.js`

**Purpose**: Automatically generates MCP-ready parameters from API quote.

**Usage**:
```bash
node skills/sunswap/scripts/format_swap_params.js \
  '<quote_json>' \
  '<recipient_address>' \
  '<network>' \
  [slippage]
```

**Output**: Complete MCP `write_contract` parameters (JSON).

---

## 📚 Resources

- **Token Registry**: [resources/common_tokens.json](resources/common_tokens.json)
- **Contract Addresses**: [resources/sunswap_contracts.json](resources/sunswap_contracts.json)
- **Complete Examples**: [examples/](examples/) - Real working examples with full output
- **Token Lookup Tool**: [scripts/lookup_token.js](scripts/lookup_token.js) - Quick token address finder

---

## 📖 Examples

**Two complete examples with full output:**

1. **[TRX → USDJ](examples/complete_swap_example.md)** - Native TRX swap (no approve needed)
   - Simple 3-step workflow
   - Direct execution with `value` parameter
   - Lower gas cost

2. **[USDT → TRX](examples/swap_with_approve.md)** - TRC20 token swap (approve required)
   - Complete 4-step workflow including approve
   - Balance and allowance checking
   - Higher gas cost (includes approve)

**Use these as references when implementing swaps!**

---

## 🚨 Critical Rules

1. **User Communication**: Announce every step before and after execution
2. **No Shortcuts**: Follow all steps in order
3. **🔴 RESPECT USER'S EXACT TOKEN CHOICE - MOST IMPORTANT RULE**:
   - **User says "TRX"** → Use TRX address for price quote AND swap
   - **User says "WTRX"** → Use network-specific WTRX address for price quote AND swap
   - **User says "USDT"** → Use USDT address for price quote AND swap
   - **NEVER EVER substitute or change the token without user's explicit confirmation**
   - **NEVER assume** user meant a different token
   - **If unclear**, STOP and ASK the user to clarify which token they want
   - This applies to BOTH price quote API call AND swap execution
4. **Use Helper Script**: Always use `format_swap_params.js` for Step 4
5. **Include ABI**: Always include ABI for Nile testnet

---

## ⚠️ TRX vs WTRX - Critical Distinction

**TRX (Native)**:
- Address: `T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb` (same on all networks)
- This is the native TRON token
- When used as input: Send via `value` parameter (no approval needed)
- User says: "swap TRX to USDT" → Use TRX address

**WTRX (Wrapped)**:
- **Mainnet**: `TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR`
- **Nile**: `TYsbWxNnyTgsZaTFaue9hqpxkU3Fkco94a`
- This is a TRC20 token wrapper
- When used as input: Requires approval like any other token
- User says: "swap WTRX to USDT" → Use network-specific WTRX address

**Example - User Intent Matters:**
```
✅ CORRECT:
User: "swap 1 TRX to USDT on nile"
Agent: *uses TRX address T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb*

✅ CORRECT:
User: "swap 1 WTRX to USDT on nile"
Agent: *uses WTRX address TYsbWxNnyTgsZaTFaue9hqpxkU3Fkco94a*

✅ CORRECT:
User: "swap 1 WTRX to USDT on mainnet"
Agent: *uses WTRX address TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR*
```

---

## 📖 Detailed Workflow Files

Each workflow step is in a separate file to keep context focused:

- `workflow/00_token_lookup.md` - Find token addresses
- `workflow/01_price_quote.md` - Get swap quote from API
- `workflow/02_balance_check.md` - Verify balance and allowance
- `workflow/03_approve.md` - Approve token spending
- `workflow/04_execute_swap.md` - Execute the swap

**Load only the file you need for the current step.**

---

## 🔧 Troubleshooting

**Only consult this section if you encounter errors.**

### API Errors

**400 Bad Request**: Check that you're using the exact API format from the Quick Reference Card above.

**Empty data array**: The token pair may not have liquidity on this network. Verify token addresses are correct for the network (mainnet vs nile).

**Response validation fails**: Ensure `amountIn` in the response matches your intended input amount.

### Transaction Errors

**INSUFFICIENT_OUTPUT_AMOUNT**: Increase slippage tolerance or split into smaller swaps.

**TRANSFER_FAILED**: Check balance and allowance (return to Step 2).

**EXPIRED**: Deadline passed - get a new quote and retry.
