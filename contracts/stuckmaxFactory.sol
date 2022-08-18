// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import './Istuckchild.sol';
import './stuckmaxChild.sol';

contract stuckMaxFactory {

    address public stuckmax;

    uint public totalChilden;

    mapping (string=>address)childName;

    struct childInfo {
        string name;
        address addr;
    }

    childInfo[] children;

    error failed(string);

    modifier onlyOwner {
        if (msg.sender== stuckmax)
        {
            _;
        }else{
            revert failed('only owner');
        }
    }

    constructor() {
        stuckmax=msg.sender;
    }

    function generateChild(string calldata _name, uint _price, uint _valueBack)external returns(address)
    {
        metastuck_movies_child child=new metastuck_movies_child();
        address childAddr=address(child);
        Istuckmaxchild(childAddr).initialize(_price, _valueBack, msg.sender, stuckmax);
        childName[_name]=childAddr;
        children.push(childInfo({name:_name,addr:childAddr}));
        totalChilden+=1;
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

    function viewAllChild()external view returns(childInfo[] memory)
    {
        return children;
    }

}