// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function totalSupply() external view returns(uint) ;

    function balanceOf(address account) external view returns(uint);

    function transfer(address recipient , uint amount) external returns(bool) ;

    function allowance(address owner, address apender) external view returns(uint) ;

    function approve(address spender, uint amount) external returns(bool) ;

    function transferFrom(
        address sender,
        address recepient,
        uint amount
    ) external returns(bool) ;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

abstract contract ERC20 is IERC20 {
    uint public totalSupply;
    string public name = "Arcsh7";
    string public symbol = "arcxx";
    uint8 public decimals = 18;
    mapping(address => uint) public balanceOf;
    /// msg.sender => spender => value
    // owner allows the sender to spend a certain amount
    mapping(address => mapping(address => uint)) allowance; 

    /// transfer to recepient 
    function transfer(address recepient, uint amount) external returns (bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[recepient] += amount;
        emit Transfer(msg.sender,recepient, amount);
        return true;
    }

    // approval to someone to spend some amount
    function approve(address spender, uint amount) external returns(bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // transfer from spender to recipent, only works if the spender is approved
    //allowing contracts to transfer tokens on your behalf. In order to use this, you need to approve the spender contract to withdraw tokens from your address
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount) ;
        return true;
    }

    function mint(uint amount) external{
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external{
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender,address(0), amount);
    }

}
