// SPDX-License-Identifier: SEE LICENSE IN LICENSE
// solhint-disable-next-line
pragma solidity ^0.8.7;

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

    error failed();

    constructor() {
        stuckMax=msg.sender;
    }

    
    receive()external payable
    {
        if ((msg.value==price) && (block.timestamp>=subscribed[msg.sender])){
            balance+=msg.value;
            subscribed[msg.sender] = block.timestamp + 30 days;
            emit ValidSubscription(msg.sender, subscribed[msg.sender]);
        }else{
            revert failed();
        }
    }

    function subscribeFor(address _addr)external payable
    {
        if ((msg.value==price) && (block.timestamp>=subscribed[msg.sender])) {
            subscribed[_addr] = block.timestamp + 30 days;
            emit ValidSubscription(msg.sender, subscribed[_addr]);
        }else{
            revert failed();
        }
    }

    function changeOwner(address _addr)external onlyOwner
    {
        stuckMax=_addr;
    }

    function pullFunds(uint _amount)external onlyOwner
    {
        balance-=_amount;
        (bool sent,)= payable(stuckMax).call{value:_amount}("");
        require(sent,"transaction failed");
    }

    function viewBalance()external view onlyOwner returns(uint)
    {
        return balance;
    }

    function validTill(address _addr)external view returns(uint)
    {
        return subscribed[_addr];
    }

}