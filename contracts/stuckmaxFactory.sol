// SPDX-License-Identifier: SEE LICENSE IN LICENSE
/** 
 ██████╗  ██████╗ ██████╗  █████╗ ███╗   ██╗██████╗ 
██╔════╝ ██╔═══██╗██╔══██╗██╔══██╗████╗  ██║██╔══██╗
██║  ███╗██║   ██║██║  ██║███████║██╔██╗ ██║██║  ██║
██║   ██║██║   ██║██║  ██║██╔══██║██║╚██╗██║██║  ██║
╚██████╔╝╚██████╔╝██████╔╝██║  ██║██║ ╚████║██████╔╝
 ╚═════╝  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ 
*/ 

// solhint-disable-next-line
pragma solidity ^0.8.7;

import "./Istuckchild.sol";
import "./stuckmaxChild.sol";

error notOwner(string);

contract StuckMaxFactory {

    address public stuckmax;

    uint public totalChilden;

    ChildInfo[] private children;

    mapping(string=>address) public childName;

    struct ChildInfo {
        string name;
        address addr;
    }

 

    event ChildCreated(string indexed name, address indexed addr,string tname);

    modifier onlyOwner {
        if (msg.sender== stuckmax)
        {
            _;
        }else{
            revert notOwner("only owner");
        }
    }


    constructor() {
        stuckmax=msg.sender;
    }

    function generateChild(string calldata _name, uint _price, uint _valueBack, address _sub)external returns(address)
    {
        MetastuckMoviesChild child=new MetastuckMoviesChild();
        address childAddr=address(child);
        Istuckmaxchild(childAddr).initialize(_price, _valueBack, msg.sender, stuckmax,_sub);
        childName[_name]=childAddr;
        children.push(ChildInfo({name:_name,addr:childAddr}));
        totalChilden+=1;
        emit ChildCreated(_name, childAddr, _name);
        return childAddr;
    }

    function changeStuckMax(address addr)external onlyOwner
    {
        stuckmax=addr;
    }

    function findByName(string calldata _name)external view returns(address)
    {
        return childName[_name];
    }

    function viewAllChild()external view returns(ChildInfo[] memory)
    {
        return children;
    }

}