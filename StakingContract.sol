// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyToken is ERC20, ReentrancyGuard  {

    error NotEnoughFunds();
    error MustBeMoreThanZero();

    mapping(address => uint256) staked;
    mapping(address => uint256) stakedFromTS;


    constructor() ERC20("DefiToken", "DEFI") {
        
        _mint(msg.sender, 1000000000);
    }


    // Staking function 
    function stake(uint256 amount) external {
        if (amount <= 0) revert MustBeMoreThanZero();
        if (balanceOf(msg.sender) < amount) revert NotEnoughFunds();
        
        _transfer(msg.sender, address(this), amount);
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    // Withdrawal function returns staked tokens and mints reward tokens 
    function withdraw() external nonReentrant {
        if (staked[msg.sender] <= 0) revert MustBeMoreThanZero();

        _transfer(address(this), msg.sender, staked[msg.sender]);
        _mint(msg.sender, rewards());

        delete staked[msg.sender];
        delete stakedFromTS[msg.sender];
    }

    // This function allows the user to see their rewards at any point
    function rewards() public view returns(uint256) {
        uint256 reward = (staked[msg.sender]/1000) * daysSinceStake();
        return reward;
    }
    
    // Function to calculate the number of days since user staked coins
    function daysSinceStake() internal view returns (uint256) {
        uint256 numOfDays = (block.timestamp - stakedFromTS[msg.sender]) /86400; 
        return numOfDays;
    }
}