# TRC20 Payment Example (TRON)

This example demonstrates how to invoke an x402-enabled agent using TRC20 USDT on the TRON Nile testnet.

## Scenario
The user wants to use a premium chat agent hosted at `https://nile.api.x402.org` using their TRON wallet.

## Steps

### 1. Check Wallet
Ensure your TRON wallet is configured and has a balance.
```bash
node x402-payment/dist/x402_invoke.js --check
```
**Output:**
```
[OK] TRON Wallet: TQ7...xyz
```

### 2. Invoke Agent
Send a prompt to the `chat` entrypoint.
```bash
node x402_payment/dist/x402_invoke.js \
  --url https://nile.api.x402.org \
  --entrypoint chat \
  --input '{"prompt": "Explain x402 in one sentence."}' \
  --network nile
```

### 3. Automatic Flow
1. The tool sends the request.
2. The server returns `402 Payment Required`.
3. The tool identifies `nile` network and TRC20 USDT requirements.
4. The tool signs a permit or performs a transfer (depending on agent requirements).
5. The tool retries with the `X-PAYMENT` header.
6. The agent returns the response.

**Sample Response:**
```json
{
  "status": 200,
  "body": {
    "output": "x402 is a decentralized protocol for micropayments between AI agents using blockchain tokens."
  }
}
```
