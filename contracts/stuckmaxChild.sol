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

import "./Isubscription.sol";

error invalidAmount();
error invalidUser();
error failed(string);

contract MetastuckMoviesChild{


    uint moviePrice;
    uint netValue;
    uint comunityFunds;
    uint modFunds;
    uint valuebackpercent;
    uint fees;

    address moderator;
    address dev;
    address factory;
    address sub;

    mapping(address=>uint) private deadline;


    
    modifier onlyFactory {
        if (msg.sender== factory)
        {
            _;
        }else{
            revert failed("only factory");
        }
    }

    constructor()
    {
        factory=msg.sender;
    }


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

    function hasAccess(address _addr) external view returns(bool)
    {
        if(deadline[msg.sender]>=block.timestamp)
        {
            return true;
        }else if(Isubscription(sub).validTill(_addr)>=block.timestamp){
            return true;
        }else{
            return false;
        }
    }

    function getTimeLeft(address addr) external view returns(uint)
    {
        return deadline[addr];
    }


    function initialize(uint _price, uint _valueBack, address _mod, address _dev,address _sub)external onlyFactory
    {
        moviePrice=_price;
        valuebackpercent=_valueBack;
        moderator=_mod;
        dev=_dev;
        sub=_sub;
    }



   
}