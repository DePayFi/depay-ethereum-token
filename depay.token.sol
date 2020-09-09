// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";

contract DEPAY is ERC20 {

    uint public lastVestingRelease;
    uint public vestingPeriodEnd;
    uint public vestingRewardPerSecond;
    address public vestingBeneficial;
    
    modifier onlyBeneficial {
        require(
            msg.sender == vestingBeneficial,
            "Only beneficial can call this function."
        );
        _;
    }
    
    constructor() public ERC20("DePay", "DEPAY") {
        uint supply = 100000000000000000000000000;
        vestingBeneficial = msg.sender;
        lastVestingRelease = block.timestamp;
        vestingPeriodEnd = block.timestamp.add(1095 days); // 3 years
        vestingRewardPerSecond = supply.div(vestingPeriodEnd.sub(lastVestingRelease));
        _mint(address(this), supply);
    }
    
    function releasable() public view returns (uint) {
        uint secondsSinceLastVestingRelease = block.timestamp.sub(lastVestingRelease);
        uint secondsTillVestingPeriodEnd = vestingPeriodEnd.sub(block.timestamp);
        if (secondsTillVestingPeriodEnd <= 0) {
            return balanceOf(address(this)); // total amount left
        } else {
            return vestingRewardPerSecond.mul(secondsSinceLastVestingRelease);
        }
    }
    
    function release() public onlyBeneficial {
        _transfer(address(this), vestingBeneficial, releasable());
        lastVestingRelease = block.timestamp;
        vestingRewardPerSecond = balanceOf(address(this)).div(vestingPeriodEnd.sub(lastVestingRelease));
    }
    
    function extendVestingPeriod(uint extension) public onlyBeneficial {
        vestingPeriodEnd = vestingPeriodEnd.add(extension);
        vestingRewardPerSecond = balanceOf(address(this)).div(vestingPeriodEnd.sub(lastVestingRelease));
    }
    
    function burnBeforeRelease(uint amount) public onlyBeneficial {
        _burn(address(this), amount);
        vestingRewardPerSecond = balanceOf(address(this)).div(vestingPeriodEnd.sub(lastVestingRelease));   
    }
    
}
