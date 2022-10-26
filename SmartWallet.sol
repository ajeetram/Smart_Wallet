// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Smart_Wallet
{
    address payable public owner;
    mapping(address=>bool) public isAllowedToSend;
    mapping(address=>uint) public Allowence;
    mapping(address=>bool) public Gaurdians;
    address payable nextOwner;
    uint GaurdiansResetCount ;
    uint public constant confirmationsFromGuardiansForReset = 3;

    constructor()
    {
        owner = payable(msg.sender);
    }
    
    receive() external payable{}
    function setGaurdians(address _gaurdian, bool _isGaurdian) public 
    {
        
       require(msg.sender==owner,"you are not the owner, aborting");
       Gaurdians[_gaurdian] = _isGaurdian;

    }

    function  proposeNewOwner(address payable _newOwner) public{
        require(Gaurdians[msg.sender],"You are not the gaurdian");
        if(_newOwner!=nextOwner)
        {
            nextOwner = _newOwner;
            GaurdiansResetCount = 0;
        }
        GaurdiansResetCount++;
        if(GaurdiansResetCount>=confirmationsFromGuardiansForReset )
        {
            owner=nextOwner;
            nextOwner = payable(address(0));
        }
    }
    function SetAllowence(address _for, uint _amount) public
    {
       require(msg.sender==owner,"you are not the owner, aborting");
       Allowence[_for] = _amount;
       if(_amount>0)
       {
           isAllowedToSend[_for] = true;
       }
       else
       {
           isAllowedToSend[_for] = false;
       }
    }

    function transfer(address payable _to, uint _amount, bytes memory _payload) public returns(bytes memory)
    {
        require(msg.sender==owner,"you are not owner,aborting");

        if(msg.sender!=owner)
        {
            require(isAllowedToSend[msg.sender],"you are not allowed to send from this smart contract");
            require(Allowence[msg.sender]>=_amount,"you are sending more than u allowed to, aborting");
            Allowence[msg.sender]-=_amount;
        }
        (bool success, bytes memory returnData) = _to.call{value:_amount}(_payload);
        require(success,"Aborting, call was not successful");
        return returnData;

    }
}
