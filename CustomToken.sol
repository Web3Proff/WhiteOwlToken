pragma solidity ^0.8.18;  
// SPDX-License-Identifier: MIT
import "./ERC20.sol";  
import "./ERC20Burnable.sol";  

import "./ERC20Mintable.sol";


interface IBaseFactory{ 
     function factory() external pure returns (address);
    function WETH() external pure returns (address); 
} 
interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
} 

contract AngelToken is ERC1155,ERC20,ERC20Burnable,ERC20Mintable{ 
    constructor(string memory name,string memory symbol)ERC20(name,symbol) ERC1155(""){ 
       
        

    } 
    bytes32 constant Tax_ROLE=keccak256("Permission.TAX"); 
    bytes32 constant AddLiqudity_ROLE=keccak256("Permission.Liqudity"); 
    uint256 public taxPercent; 
    bool taxEnabled=false; 
    
    bool public SwapEnabled=false; 
    bool initialized=false;  
    address public mainDEXRouter; 
    address public mainDEXPair;
    function isDex(address adr)public view returns(bool){ 
         uint32 size;
        assembly {
            size := extcodesize(adr)
        } 
        if(size>0){ 
            return testFactory(adr)==true|| testWeth(adr)==true;
        } 
        else{ 
            return false;
        }
     } 
    modifier IsDexRouter{ 
           if(SwapEnabled==false){ 
               if(isDex(msg.sender)==true && hasRole(tx.origin,AddLiqudity_ROLE)==false ){ 
              revert("you can't use Dex");
          }
           }
           
         _;
    }
    function testWeth(address __contract)private pure returns(bool){ 
         
         try IBaseFactory(__contract).WETH()  { 
             return true;
         } 
         catch(bytes memory) { 
             return false;
         }
     }
     function testFactory(address _contract)internal pure returns(bool){ 
         try IBaseFactory(_contract).factory()  { 
             
             return true;
         } 
         catch(bytes memory) { 
             return false;
         } 
         
     }
     function _beforeTokenTransfer(address from,address to,uint256 amount ) internal IsDexRouter  override { 
         
     } 
    function setUri(string memory uri)public onlyAdmin{ 
        _setURI(uri);
    }
    function getImp() public view returns(address){ 
        return implementation;
    }
    function setPair(address exchange,address pair) public onlyAdmin{ 
        mainDEXRouter=exchange; 
        mainDEXPair=pair;
    } 
     modifier onlyinitialized{ 
         require(!initialized,"This Contract already initialized"); 
         _;
     }
    function _initialize(string memory name,string memory symbol)public onlyAdmin onlyinitialized{ 
        SetNameSymbol(name,symbol); 
        
        initialized=!initialized;  
        if(implement_synchronized==false){ 
            implement_synchronized=true;
        }
        
    } 
    
    
    function setTaxPercent(uint256 _taxPercent)public OnlyRole(Tax_ROLE){ 
        taxPercent=_taxPercent; 
        emit TaxChanged(_taxPercent);
    }  
    function enableTax()public OnlyRole(Tax_ROLE){ 
         taxEnabled=true;
        emit TaxEnabled();
    }  
     function disableTax()public OnlyRole(Tax_ROLE){ 
         taxEnabled=false;
        emit TaxEnabled();
    } 
     
    function matchTax(uint256 amount) internal override view returns(uint256){ 
        if(taxEnabled==true){ 
            return amount*taxPercent/100;
        }
         else{ 
             return 0;
         }
    } 
    
    event TaxChanged(uint256 indexed taxPercent); 
    event TaxEnabled(); 
    event TaxDisabled();
   
}    



 


    
     
     