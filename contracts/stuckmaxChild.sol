//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract metastuck_movies_child{


    uint moviePrice;
    uint netValue;

    address moderator;
    address dev;

    mapping (address=>bool) private viewGranted;
    mapping  (address=>uint) private deadline;


    error invalidAmount();



    receive() external payable
    {
        if ((msg.value == moviePrice) && (block.timestamp>deadline[msg.sender])) 
        {
            netValue+=msg.value;
            deadline[msg.sender]= block.timestamp + 1 days;
            viewGranted[msg.sender]=true;
        }else{
            revert invalidAmount();
        }
    }

    function hasAccess(address addr) external view returns(bool)
    {
        return viewGranted[addr];
    }

    function getTimeLeft(address addr) external view returns(uint)
    {
        return deadline[addr];
    }






   
}