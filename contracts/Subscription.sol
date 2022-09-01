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


error failed();

contract Subscriptions {

    address private stuckMax;

    uint public price;
    uint private balance;

    mapping(address => uint) public subscribed;

    event ValidSubscription(address indexed addr, uint period);

    modifier onlyOwner {
        if (msg.sender== stuckMax)
        {
            _;
        }else{
            revert failed();
        }
    }

    modifier noContracts {
        if(tx.origin!=msg.sender) revert failed();
        _;
    }


    constructor(uint256 _price) {
        stuckMax=msg.sender;
        price= _price;
    }

    
    receive()external payable noContracts
    {
        if ((msg.value==price) && (block.timestamp>=subscribed[msg.sender])){
            balance+=msg.value;
            subscribed[msg.sender] = block.timestamp + 30 days;
            emit ValidSubscription(msg.sender, subscribed[msg.sender]);
        }else{
            revert failed();
        }
    }

    function subscribeFor(address _addr)external payable noContracts
    {
        if ((msg.value==price) && (block.timestamp>=subscribed[msg.sender])) {
            subscribed[_addr] = block.timestamp + 30 days;
            emit ValidSubscription(msg.sender, subscribed[_addr]);
        }else{
            revert failed();
        }
    }

    function changeOwner(address _addr)external onlyOwner noContracts
    {
        stuckMax=_addr;
    }

    function pullFunds(uint _amount)external onlyOwner noContracts
    {
        balance-=_amount;
        (bool sent,)= payable(stuckMax).call{value:_amount}("");
        require(sent,"transaction failed");
    }

    function setPrice(uint256 _amount)external onlyOwner noContracts
    {
        price=_amount;
    }

    function viewBalance()external view returns(uint)
    {
        return balance;
    }

    function validTill(address _addr)external view returns(uint)
    {
        return subscribed[_addr];
    }

}