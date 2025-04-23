// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingRewards {
    IERC20 public fitechToken; // Fitech token contract
    address public owner;
    
    uint256 public stakingDuration = 10 minutes; // Staking period
    uint256 public rewardRate = 100; // 100 Fitech tokens per Ether staked
    
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        bool active;
    }
    
    mapping(address => Stake) public stakes;
    
    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);
    
    constructor(address _fitechToken) {
        fitechToken = IERC20(_fitechToken);
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // Function to stake Ether
    function stake() external payable {
        require(msg.value > 0, "Stake amount must be greater than 0");
        require(!stakes[msg.sender].active, "Already staking");
        
        stakes[msg.sender] = Stake({
            amount: msg.value,
            timestamp: block.timestamp,
            active: true
        });
        
        emit Staked(msg.sender, msg.value, block.timestamp);
    }
    
    // Function to withdraw all active staked Ether and claim rewards
    function withdraw() external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.active, "No active stake");
        require(block.timestamp >= userStake.timestamp + stakingDuration, "Staking period not over");
        
        // Get the total staked amount and calculate reward
        uint256 stakedAmount = userStake.amount;
        uint256 reward = (stakedAmount * rewardRate) / 1 ether; // Reward in Fitech tokens
        
        // Reset the stake
        userStake.amount = 0;
        userStake.timestamp = 0;
        userStake.active = false;
        
        // Transfer all staked Ether back to the user
        payable(msg.sender).transfer(stakedAmount);
        
        // Transfer all Fitech token rewards to the user
        require(fitechToken.transfer(msg.sender, reward * 10**18), "Reward transfer failed");
        
        emit Withdrawn(msg.sender, stakedAmount, reward);
    }
    
    // Function for owner to update reward rate
    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRate = _newRate;
    }
    
    // Function for owner to update staking duration
    function setStakingDuration(uint256 _newDuration) external onlyOwner {
        stakingDuration = _newDuration;
    }
    
    // Function to deposit Fitech tokens into the contract for rewards
    function depositRewards(uint256 _amount) external onlyOwner {
        require(fitechToken.transferFrom(msg.sender, address(this), _amount), "Deposit failed");
    }
    
    // Fallback function to prevent accidental Ether transfers
    receive() external payable {
        revert("Use stake function to send Ether");
    }
}