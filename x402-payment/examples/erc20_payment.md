# ERC20 Payment Example (EVM)

This example demonstrates how to invoke an x402-enabled agent using ERC20 USDC on the Ethereum Sepolia testnet.

## Scenario
The user wants to use a premium image generation agent using their EVM wallet.

## Steps

### 1. Check Wallet
Ensure your EVM wallet is configured.
```bash
node x402-payment/dist/x402_invoke.js --check
```
**Output:**
```
[OK] EVM Wallet: 0x123...abc
```

### 2. Invoke Agent
Send a prompt to the `generate` entrypoint.
```bash
node x402_payment/dist/x402_invoke.js \
  --url https://sepolia.api.x402.org \
  --entrypoint generate \
  --input '{"prompt": "A futuristic city in the style of cyberpunk"}' \
  --network sepolia
```

### 3. Automatic Flow
1. The tool detects EVM network `sepolia`.
2. It handles ERC20 approval if necessary (requires ETH for gas).
3. It signs the EIP-712 payment permit.
4. It completes the request.

**Sample Response:**
```json
{
  "status": 200,
  "body": {
    "file_path": "/tmp/x402_image_1707654321_abc123.png",
    "content_type": "image/png"
  }
}
```
*(Note: Binary files like images are saved to a temporary path as indicated in the response)*
