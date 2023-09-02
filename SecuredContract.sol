 pragma solidity ^0.8.18;  
// SPDX-License-Identifier: MIT

 import "./UpgredableContext.sol";
  abstract contract SecuredContract is UpgradableContext{ 
    mapping(address=>mapping(bytes32=>bool))private accessList; 
    bytes32 private ADMIN_ROLE; 
    bytes32 private Grant_ROLE;
    
    
    event GrantRole(address indexed user,string indexed name);
    event RevokeRole(address indexed user,bytes32 indexed role);
    constructor(){ 
         
        
         ADMIN_ROLE=hashFromString("Permission.ADMIN"); 
         Grant_ROLE=hashFromString("Permission.GRANT");
    } 
   function getAdminn() public view returns(address){ 
       return proxyAdmin;
   }
    modifier OnlyADMIN{ 
        require(hasRole(msg.sender,ADMIN_ROLE),"Acces Denied ,you is not ADMIN"); 
        _;
    } 
    modifier OnlyGranter{ 
         require(hasRole(msg.sender,Grant_ROLE),"Access denied");
         _;
    } 
    function revokeRole(bytes32 role,address user) public onlyAdmin{ 
        accessList[user][role]=false; 
        emit RevokeRole(user,role);
    }

   
    
    modifier OnlyRole(bytes32 role){ 
         require(hasRole(msg.sender,role),"Access Denied");
         _;
    }
    function hasRole(address adr,bytes32 role) internal view returns(bool){ 
        return accessList[adr][role] ||  accessList[adr][ADMIN_ROLE] ||proxyAdmin==adr; 
    }  
   
    function hashFromString(
        string memory  _text
        
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text));
    } 
    function hash(
        bytes memory _text
        
    ) internal pure returns (bytes32) {
        return keccak256(_text);
    }
    function grantRole(address adr,bytes32 role)external OnlyGranter { 
        accessList[adr][role]=true;
    }
}
