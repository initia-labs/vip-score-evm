# VIP Score EVM

This guide explains how a rollup can prepare for and integrate Initia's [VIP](https://docs.initia.xyz/home/core-concepts/vip/introduction#vip-introduction).

## Prerequisites

- [Weave CLI](https://docs.initia.xyz/developers/developer-guides/tools/clis/weave-cli/rollup/introduction)
- [Minitiad CLI](https://docs.initia.xyz/developers/developer-guides/tools/clis/minitiad-cli/introduction)

## VIP Integration Steps

### Deploy Your Rollup and Install Minitiad CLI

First, launch your rollup. For local deployments, you can use the [Weave CLI](/developers/developer-guides/tools/clis/weave-cli/rollup/introduction) to launch a rollup.

Once your rollup is running, we need to fetch the rollup's version. To do so, run the following command:

```bash
export RPC_URL={YOUR_ROLLUP_RPC_URL}
curl -X POST $RPC_URL/abci_info
```

The output will be in the format below. The `version` field is the rollup's version.

```json highlight={7}
{
    "jsonrpc": "2.0",
    "id": -1,
    "result": {
        "response": {
            "data": "minitia",
            "version": "v1.0.2",
            "last_block_height": "10458738",
            "last_block_app_hash": "lS/hN6BDFU45Z0Oee04MZm15TS49yx+//SQJsXSSfms="
        }
    }
}
```

We then need to install the `minitiad` CLI that matches the rollup's version.

```bash
export MINIEVM_VERSION=1.1.7 # Replace with your rollup's version

git clone https://github.com/initia-labs/minievm.git
cd minievm
git checkout $MINIEVM_VERSION
make install
```

### Create an operator and VIP contract deployer account

Next, we will create a VIP operator account and a VIP contract deployer account to deploy the VIP scoring contract.
- The VIP operator account will receive the VIP operator rewards
-  the VIP contract deployer account will handle the deployment of the VIP scoring contract.

If you have an existing account you want to use for these roles, you can use the `--recover` option to recover it using a BIP39 mnemonic phrase. If you do not have a mnemonic phrase, you can create a new account without this option.

```bash
export OPERATOR_KEY_NAME=operator
export DEPLOYER_KEY_NAME=deployer

minitiad keys add $OPERATOR_KEY_NAME --recover
# > Enter your bip39 mnemonic
# glare boil shallow hurt distance grant rose pledge begin main stage affair alpha garlic tornado enemy enable swallow unusual foster maid pelican also bus

minitiad keys add $DEPLOYER_KEY_NAME --recover
# > Enter your bip39 mnemonic
# room fruit chalk buyer budget wisdom theme sound north square regular truck deal anxiety wrestle toy flight release actress critic saddle garment just found
```

Alternatively, if you want to use a Ledger hardware wallet, you can use the `--ledger` option to create an account that uses Ledger for signing transactions.

```bash
minitiad keys add $OPERATOR_KEY_NAME --ledger
```

### Deploy the VIP Scoring Contract

In this step, you will deploy the VIP scoring contract that tracks addresses and scores. To do so, follow the steps based on your rollup's VM.
    
The VIP scoring contract must specify the stage at which the rollup participates in VIP when deployed. To retrieve the current VIP stage, choose the example for your network and run either the curl request or the TypeScript example. Both will query the VIP module store on L1 and return the current VIP stage information.

For Mainnet (`interwoven-1`),

```bash curl
curl https://rest.initia.xyz/initia/move/v1/accounts/0x3a886b32a802582f2e446e74d4a24d1d7ed01adf46d2a8f65c5723887e708789/resources/by_struct_tag?struct_tag=0x3a886b32a802582f2e446e74d4a24d1d7ed01adf46d2a8f65c5723887e708789%3A%3Avip%3A%3AModuleStore
```

```ts initia.js
import { RESTClient } from '@initia/initia.js'

const L1_VIP_CONTRACT   = '0x3a886b32a802582f2e446e74d4a24d1d7ed01adf46d2a8f65c5723887e708789' 
const L1_REST_URL       = 'https://rest.initia.xyz'                                    

async function getCurrentStage(): Promise<string> {
    const rest = new RESTClient(L1_REST_URL)
    return rest.move.resource<any>(L1_VIP_CONTRACT, `${L1_VIP_CONTRACT}::vip::ModuleStore`).then((res) => res.data.stage)
}
```

For Testnet (`initiation-2`),

```bash curl
curl https://rest.testnet.initia.xyz/initia/move/v1/accounts/0xe55cc823efb411bed5eed25aca5277229a54c62ab3769005f86cc44bc0c0e5ab/resources/by_struct_tag?struct_tag=0xe55cc823efb411bed5eed25aca5277229a54c62ab3769005f86cc44bc0c0e5ab%3A%3Avip%3A%3AModuleStore
```

```ts initia.js
import { RESTClient } from '@initia/initia.js'

const L1_VIP_CONTRACT   = '0xe55cc823efb411bed5eed25aca5277229a54c62ab3769005f86cc44bc0c0e5ab'
const L1_REST_URL       = 'https://rest.testnet.initia.xyz'                                   

async function getCurrentStage(): Promise<string> {
    const rest = new RESTClient(L1_REST_URL)
    return rest.move.resource<any>(L1_VIP_CONTRACT, `${L1_VIP_CONTRACT}::vip::ModuleStore`).then((res) => res.data.stage)
}
```

Clone the [`vip-score-evm`](https://github.com/initia-labs/vip-score-evm) repository.
      
```bash
git clone https://github.com/initia-labs/vip-score-evm.git
```

Compile the `VIPScore.sol` contract. If you do not have [Foundry](https://github.com/foundry-rs/foundry) installed, follow the [Foundry installation instructions](https://getfoundry.sh).

```bash
forge build
```

Deploy the contract. Make sure to set the `JSON_RPC_URL`, `PRIVATE_KEY`, and `INIT_STAGE` environment variables before running the script. Set `JSON_RPC_URL` to your rollup’s RPC endpoint, `PRIVATE_KEY` to the VIP contract deployer key, and `INIT_STAGE` to the starting VIP stage number.

To get `INIT_STAGE`, you can check the current VIP stage by using the curl request or the TypeScript example provided in the previous note.

```bash
export JSON_RPC_URL=https://json-rpc.minievm-2.initia.xyz  # Replace with your rollup's JSON_RPC endpoint
export PRIVATE_KEY=0xabcd1234...                           # Replace with your deployer's private key
export INIT_STAGE=1                                        # Replace with the starting stage number for scoring.

forge script script/VipScore.s.sol:DeployVipScore --rpc-url $JSON_RPC_URL --broadcast

# ...
# ✅  [Success] Hash: 0xd55beed5a745b203b56dc68c9e9141fcfd433c4c47587ce50655a99f5c449abc
# Contract Address: 0x1F00dfc319F1B74462B2Ef301c3978ee71f0d0E2
# Block: 238
# Paid: 0.000000000000525763 ETH (525763 gas * 0.000000001 gwei)

# ✅ Sequence #1 on 1982194020580198 | Total Paid: 0.000000000000525763 ETH (525763 gas * avg 0.000000001 gwei)
# ...
```

Save the deployed contract address. It will be required for the VIP whitelist proposal.

### Operate the VIP Scoring Contract

| Action          | Method                                    | Description                                                                                       |
| --------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Update scores   | `updateScores(stage, addrs[], amounts[])` | Update the scores for a list of addresses in the specified stage                                  |
| Finalize stage  | `finalizeStage(uint64 stage)`             | Finalize the given stage, preventing further changes and prepares the contract for the next stage |

This code snippet shows how to use the [viem](https://viem.sh/) library to interact with the VIP scoring contract:

```ts vip-score-evm-tutorial.ts
import { createPublicClient, createWalletClient, http, parseAbi, encodeFunctionData, Hash, defineChain } from 'viem';
import { privateKeyToAccount } from 'viem/accounts'; 
import { RESTClient } from '@initia/initia.js';

/* -------------------------------------------------------- *
*  Environment variables                                   *
* -------------------------------------------------------- */

const JSON_RPC_URL     =  process.env.JSON_RPC_URL   || 'https://json-rpc.minievm-2.initia.xyz'; // Your rollup's JSON RPC endpoint
const PRIVATE_KEY      =  process.env.PRIVATE_KEY    || '0xabcd1234...';                         // Your contract deployer's private key. Do not hardcode it in production
const SCORE_CONTRACT   =  process.env.SCORE_CONTRACT || '0x12345...';                            // The deployed VIP scoring contract address  
const EVM_CHAIN_ID     =  process.env.EVM_CHAIN_ID   || '1982194020580198';                      // Your rollup's chain ID
const TARGET_STAGE     =  process.env.TARGET_STAGE   || '1';                                     // The stage number you want to update scores for

/* -------------------------------------------------------- *
    *  Update addresses and scores (Mock Implementation)       *
    *  Replace these with actual addresses and scores          *
    * -------------------------------------------------------- */

// ADDRESSES and SCORES should be arrays of the same length.
const ADDRESSES = [
    '0x1111111111111111111111111111111111111111',
    '0x2222222222222222222222222222222222222222',
] as `0x${string}`[];
const SCORES = [100n, 250n];

const chain = defineChain({
        id: parseInt(EVM_CHAIN_ID),
        name: 'MiniEVM',
        nativeCurrency: {
        decimals: 18,
        name: 'Gas Token',
        symbol: 'GAS',
    },
    rpcUrls: {
        default: {
            http: [JSON_RPC_URL],
        },
    },
})

const publicClient  = createPublicClient({ chain, transport: http(JSON_RPC_URL) });
const account       = privateKeyToAccount(PRIVATE_KEY as `0x${string}`);
const walletClient  = createWalletClient({ chain, transport: http(JSON_RPC_URL), account });

const vipAbi = parseAbi([
    'function updateScores(uint64 stage, address[] addrs, uint64[] amounts)',
    'function finalizeStage(uint64 stage)',
]);

async function send(txData: Hash) {
    const receipt = await publicClient.waitForTransactionReceipt({ hash: txData });
    if (receipt.status !== 'success') throw new Error(`Tx failed: ${txData}`);
    return receipt;
}

async function run() {
    const stage = TARGET_STAGE; // or await getCurrentStage();

    /* update scores ---------------------------------- */
    const tx1 = await walletClient.sendTransaction({
        to: SCORE_CONTRACT as `0x${string}`,
        data: encodeFunctionData({
            abi: vipAbi,
            functionName: 'updateScores',
            args: [BigInt(stage), ADDRESSES, SCORES],
        }),
    });
    await send(tx1);
    console.log('Scores updated successfully.');

    /* finalize stage --------------------------------- */
    const tx2 = await walletClient.sendTransaction({
        to: SCORE_CONTRACT as `0x${string}`,
        data: encodeFunctionData({ abi: vipAbi, functionName: 'finalizeStage', args: [BigInt(stage)] }),
    });
    await send(tx2);
    console.log('Stage finalized successfully.');
}

run().catch(console.error);
```

> To get the EVM chain ID, call the `eth_chainId` JSON-RPC method. For example, using `curl`:
> ```bash
> curl -X POST https://json-rpc.minievm-2.initia.xyz/ \
>     -H "Content-Type: application/json" \
>     -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
> ```


## External functions

All functions can only be executed by addresses that are in the allow list.

### `prepareStage`

Initialize Stage

```solidity
function prepareStage(uint64 stage) external
```

### `finalizeStage`

Finalize stage. Once stage finalized, can't change score of that stage anymore.

```solidity
function finalizeStage(uint64 stage) external
```

### `increaseScore`

Increase score.

```solidity
function increaseScore(uint64 stage, address addr, uint64 amount) external
```

### `decreaseScore`

Decrease score.

```solidity
function decreaseScore(uint64 stage, address addr, uint64 amount) external
```

### `updateScore`

Update the score by setting it to the given amount.

```solidity
function updateScore(uint64 stage, address addr, uint64 amount) external
```

### `updateScores`

Update several scores at once.

```solidity
function updateScores(uint64 stage, address[] calldata addrs, uint64[] calldata amounts) external
```

### `addAllowList`

Add new address to allow list

```solidity
function addAllowList(address addr) external
```

### `removeAllowList`

Remove address from allow list

```solidity
function removeAllowList(address addr) external
```

## Public storage

### `stages`

mapping of stage Info

```solidity
struct StageInfo {
    uint64 stage;
    uint64 totalScore;
    bool isFinalized;
}

mapping(uint64 => StageInfo) public stages;
```

### `scores`

mapping of user score

```solidity
struct ScoreResponse {
    address addr;
    uint64 amount;
    uint64 index;
}

mapping(uint64 => mapping(address => Score)) public scores; // stage => address => score
```

## View functions

### `getScores`

Get scores

```solidity
function getScores(uint64 stage, uint64 offset, uint8 limit) public view returns (ScoreResponse[] memory)
```

Response type

```solidity
struct ScoreResponse {
    address addr;
    uint64 amount;
    uint64 index;
}
```
