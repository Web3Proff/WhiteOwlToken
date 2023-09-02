pragma solidity ^0.8.4;  
// SPDX-License-Identifier: MIT


contract Proxy {

    address internal implementation;
    address internal proxyAdmin; 
    bool internal implement_synchronized; 
    string internal versionName;  

 constructor(){ 
     proxyAdmin=msg.sender;
 } 
 function getAdmin() external view returns(address) { 
     return proxyAdmin;
 }  
 function version()public view returns(string memory ){ 
     return versionName;
 }
 function getImplement()public view returns(address){ 
    return implementation;
    }
 function changeOwner(address newOwner) public onlyAdmin{ 
     transferOwner(newOwner);
 } 
 function transferOwner(address newOwner) private notZero(newOwner) notContract(newOwner){ 
      address oldOwner=proxyAdmin;
      proxyAdmin=newOwner;  
      emit OwnerTransfered(oldOwner,newOwner);
 } 
 modifier notZero(address account){ 
     require(account!=address(0) && account!=0x000000000000000000000000000000000000dEaD); 
     _;
 } 
 modifier notContract(address account){ 
     require(!isContract(account)); 
     _;
 }
 modifier onlyAdmin{ 
     require(msg.sender==proxyAdmin,"You is not proxy admin !"); 
     _;
 } 

function setImplementation(string memory _version,address implementation_) public onlyAdmin {
 require(isContract(implementation_),"Not contract !"); 
  
 implementation = implementation_; 
 versionName=_version;  
 emit Upgraded(_version,implementation);
 
    
 
 } 
 
function isContract(address account) private view returns(bool){ 
    uint size; 
    assembly{ 
        size:=extcodesize(account)
    } 
    return size>0;
}
function _delegate() internal { 
        
          assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
       
       
       } 
      receive() external payable {
        _delegate();
    }
     fallback() external payable {
       assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
}   
     event Upgraded(string indexed version,address indexed implementation);
     event OwnerTransfered(address indexed oldOwner,address indexed newOwner);
} 

