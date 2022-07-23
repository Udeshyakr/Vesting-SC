// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MangoToken is Ownable, ERC20 {
    constructor(uint256 initialSupply) ERC20("MANGO", "MNGO") {
            _mint(owner(), initialSupply * 10 ** decimals());
    }
}