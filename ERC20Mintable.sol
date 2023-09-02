 import "./ERC20.sol"; 
 pragma solidity ^0.8.18;  
// SPDX-License-Identifier: MIT
 abstract contract ERC20Mintable is ERC20{ 
     bytes32 constant public Minter_Role=keccak256("Permission.MINTER");
     function mint(address to,uint amount)public OnlyRole(Minter_Role) { 
        _mint(to,amount);
    }
}