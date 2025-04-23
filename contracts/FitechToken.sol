// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FitechToken is ERC20, Ownable {
    uint256 private constant TOTAL_SUPPLY = 10_000_000 * 10**18; // 10M tokens with 18 decimals

    constructor() ERC20("FitechToken", "FITECH") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY); // Mint 10M tokens to the deployer
    }

    // Optional: Function to allow the owner to burn tokens if needed
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }
}