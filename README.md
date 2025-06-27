# VIP Score EVM

VIP Score EVM is a contract used to manage user Vested Interest Program (VIP) scores.

The contract allows you to update scores for users in given stages.

For more information about scoring, please refer to the [VIP Scoring documentation](https://docs.initia.xyz/home/core-concepts/vip/scoring).


# Deployment

> If you don't have installed [Foundry](https://getfoundry.sh/), please follow the [instructions](https://getfoundry.sh/introduction/installation/).

Clone [`vip-score-evm`](https://github.com/initia-labs/vip-score-evm).
      
```bash
git clone https://github.com/initia-labs/vip-score-evm.git
```

Compile `VIPScore.sol` contract. 

```bash
forge build
```

Deploy the contract. Make sure to set the `JSON_RPC_URL`, `PRIVATE_KEY`, and `INIT_STAGE` environment variables before running the script.
`JSON_RPC_URL` should point to your rollup's JSON RPC endpoint. `PRIVATE_KEY` should be the deployer's private key, and `INIT_STAGE` is the initial stage number you will use.

```bash
export JSON_RPC_URL=<YOUR_RPC_URL>
export PRIVATE_KEY=<YOUR_DEPLOYER_PRIVATE_KEY>
export INIT_STAGE=<STAGE_NUMBER>

forge script script/VipScore.s.sol:DeployVipScore --rpc-url $JSON_RPC_URL --broadcast

# ...
# ✅  [Success] Hash: 0xd55beed5a745b203b56dc68c9e9141fcfd433c4c47587ce50655a99f5c449abc
# Contract Address: 0x1F00dfc319F1B74462B2Ef301c3978ee71f0d0E2
# Block: 238
# Paid: 0.000000000000525763 ETH (525763 gas * 0.000000001 gwei)

# ✅ Sequence #1 on 1982194020580198 | Total Paid: 0.000000000000525763 ETH (525763 gas * avg 0.000000001 gwei)
# ...
```

# Contract Description

## Constructor

Set sender to default member of allowList and set start stage.

```solidity
constructor(uint64 initStage_) {
    allowList[msg.sender] = true;
    initStage = initStage_;
    createStage(initStage);
}
```

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
