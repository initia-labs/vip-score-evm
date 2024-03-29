# VIP Score

## Constructor

Set sender to default member of allowList.

```solidity
constructor() {
    allowList[msg.sender] = true;
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

Response type

```solidity
{
  "stage": 123,
  "addr": "init1...",
  "score": 123
}
```

### `get_scores`

Get scores of given stage

```solidity
{
  "get_scores": {
    "stage": 123, // stage
    "limit": 123, // amount of result (max: 255)
    "start_after": "init1..." // optional, where to begin fetching the next batch of results
  }
}
```

Response type

```solidity
{
  "scores": [
    {
      "stage": 123,
      "addr": "init1...",
      "score": 123
    },
    {
      "stage": 123,
      "addr": "init1...",
      "score": 123
    },
    ...
  ]
}
```

### `get_stage_info`

Get stage info

```solidity
{
  "get_stage_info": {
    "stage": 123 // stage
  }
}
```

Response type

```solidity
{
  "stage": 123,
  "total_score": 123,
  "is_finalized": false
}
```
