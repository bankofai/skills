#!/usr/bin/env node
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

async function findPrivateKey(type: 'tron' | 'evm'): Promise<string | undefined> {
  if (type === 'tron') {
    if (process.env.TRON_PRIVATE_KEY) return process.env.TRON_PRIVATE_KEY;
  } else {
    if (process.env.EVM_PRIVATE_KEY) return process.env.EVM_PRIVATE_KEY;
    if (process.env.ETH_PRIVATE_KEY) return process.env.ETH_PRIVATE_KEY;
  }
  return process.env.PRIVATE_KEY;
}

async function main() {
  const args = process.argv.slice(2);
  const options: Record<string, string> = {};
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg.startsWith('--')) {
      const key = arg.slice(2);
      const value = args[i + 1];
      if (value && !value.startsWith('--')) {
        options[key] = value;
        i++;
      } else { options[key] = 'true'; }
    }
  }

  const url = options.url;
  const entrypoint = options.entrypoint;
  const inputRaw = options.input;
  const methodArg = options.method;

  // Use dynamic imports
  // @ts-ignore
  const { TronWeb } = await import('tronweb');
  (global as any).TronWeb = TronWeb;

  const {
    TronClientSigner,
    EvmClientSigner,
    X402Client,
    X402FetchClient,
    ExactTronClientMechanism,
    ExactEvmClientMechanism,
    ExactPermitTronClientMechanism,
    ExactPermitEvmClientMechanism,
    SufficientBalancePolicy
  } = await import('@bankofai/x402');

  if (options.check === 'true' || options.status === 'true') {
    const tronKey = await findPrivateKey('tron');
    const evmKey = await findPrivateKey('evm');
    if (tronKey) {
      const signer = new TronClientSigner(tronKey);
      console.error(`[OK] TRON Wallet: ${signer.getAddress()}`);
    }
    if (evmKey) {
      const signer = new EvmClientSigner(evmKey);
      console.error(`[OK] EVM Wallet: ${signer.getAddress()}`);
    }
    process.exit(0);
  }

  if (!url) {
    console.error('Error: --url is required');
    process.exit(1);
  }

  const client = new X402Client();

  const tronKey = await findPrivateKey('tron');
  if (tronKey) {
    const signer = new TronClientSigner(tronKey);
    const networks = ['mainnet', 'nile', 'shasta', '*'];
    for (const net of networks) {
      const networkId = net === '*' ? 'tron:*' : `tron:${net}`;
      client.register(networkId, new ExactTronClientMechanism(signer));
      client.register(networkId, new ExactPermitTronClientMechanism(signer));
    }
    console.error(`[x402] TRON mechanisms enabled.`);
  }

  const evmKey = await findPrivateKey('evm');
  if (evmKey) {
    const signer = new EvmClientSigner(evmKey);
    client.register('eip155:*', new ExactEvmClientMechanism(signer));
    client.register('eip155:*', new ExactPermitEvmClientMechanism(signer));
    console.error(`[x402] EVM mechanisms enabled.`);
  }

  client.registerPolicy(new SufficientBalancePolicy(client));

  let finalUrl = url;
  let finalMethod = methodArg || 'GET';
  let finalBody: string | undefined = undefined;

  if (entrypoint) {
    const baseUrl = url.endsWith('/') ? url.slice(0, -1) : url;
    finalUrl = `${baseUrl}/entrypoints/${entrypoint}/invoke`;
    finalMethod = 'POST';
    let inputData = {};
    if (inputRaw) {
      try { inputData = JSON.parse(inputRaw); } catch (e) { inputData = inputRaw; }
    }
    finalBody = JSON.stringify({ input: inputData });
  } else {
    if (methodArg) finalMethod = methodArg.toUpperCase();
    if (inputRaw) finalBody = inputRaw;
  }

  try {
    const fetchClient = new X402FetchClient(client);
    const requestInit: any = {
      method: finalMethod,
      headers: { 'Content-Type': 'application/json' },
      body: finalBody
    };

    console.error(`[x402] Requesting: ${finalMethod} ${finalUrl}`);
    const response = await fetchClient.request(finalUrl, requestInit);

    const contentType = response.headers.get('content-type') || '';
    let responseBody;

    if (contentType.includes('application/json')) {
      responseBody = await response.json();
    } else if (contentType.includes('image/') || contentType.includes('application/octet-stream')) {
      const buffer = Buffer.from(await response.arrayBuffer());
      const tmpDir = os.tmpdir();
      const isImage = contentType.includes('image/');
      const ext = isImage ? contentType.split('/')[1]?.split(';')[0] || 'bin' : 'bin';
      const fileName = `x402_${isImage ? 'image' : 'binary'}_${Date.now()}_${Math.random().toString(36).substring(7)}.${ext}`;
      const filePath = path.join(tmpDir, fileName);

      fs.writeFileSync(filePath, buffer);
      console.error(`[x402] Binary data saved to: ${filePath}`);
      responseBody = { file_path: filePath, content_type: contentType, bytes: buffer.length };
    } else {
      responseBody = await response.text();
    }

    process.stdout.write(JSON.stringify({
      status: response.status,
      headers: Object.fromEntries(response.headers.entries()),
      body: responseBody
    }, null, 2) + '\n');
  } catch (error: any) {
    console.error(`[x402] Error: ${error.message}`);
    process.stdout.write(JSON.stringify({ error: error.message }, null, 2) + '\n');
    process.exit(1);
  }
}

main();
