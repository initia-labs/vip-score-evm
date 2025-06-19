// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/VipScore.sol";

contract DeployVipScore is Script {
    function run() external returns (VipScore deployed) {
        uint256 pk        = vm.envUint("PRIVATE_KEY");
        uint64  initStage = uint64(vm.envUint("INIT_STAGE"));

        vm.startBroadcast(pk);
        deployed = new VipScore(initStage);
        console2.log("VipScore deployed at:", address(deployed));
        vm.stopBroadcast();
    }
}
