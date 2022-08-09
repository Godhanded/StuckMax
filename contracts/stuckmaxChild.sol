//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract metastuck_movies_child{


    uint moviePrice;
    uint netValue;
    uint comunityFunds;
    uint modFunds;
    uint valuebackpercent;
    uint fees;

    address moderator;
    address dev;

    mapping (address=>bool) private viewGranted;
    mapping  (address=>uint) private deadline;


    error invalidAmount();
    error invalidUser();



    receive() external payable
    {
        uint amount= msg.value;
        if ((amount == moviePrice) && (block.timestamp>deadline[msg.sender])) 
        {
            uint stuckFee= (amount * 5)/100;
            amount-=stuckFee;
            netValue+=amount;
            comunityFunds+=amount*(valuebackpercent/100);
            modFunds+=(amount-comunityFunds);
            fees+=stuckFee;
            deadline[msg.sender]= block.timestamp + 1 days;
            viewGranted[msg.sender]=true;
        }else{
            revert invalidAmount();
        }
    }

    function pullfunds()external 
    {
        if(msg.sender==moderator)
        {
            uint fee= fees;
            uint moderatorValue=modFunds;
            fees-=fee;
            modFunds-=moderatorValue;
            netValue-=(moderatorValue);
            (bool sentmod, )= payable(moderator).call{value:moderatorValue}("");
            (bool sentStuck, )= payable(dev).call{value:fee}("");
            require((sentmod && sentStuck),"transaction failed");

        }else{
            revert invalidUser();
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