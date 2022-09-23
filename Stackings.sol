// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Stacking {
    // change owner , stacking 0.5 eth , withdraw time generate , reward calculator , withdraw , balance , withdraw owner

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner, aborting!");
        _;
    }

    struct StackStruct {
        uint balance;
        uint stake_time;
    }

    mapping(address => StackStruct) StackMap;

    event NewOwner(address _prevOwner, address _newOwner);
    event StakeDetails(address _staker, uint _amount, address _contractAddress);
    event Withdraw_Details(
        address _staker,
        uint _reward,
        address _contractAddress
    );
    event WithdrawOwner(
        address _owner,
        address _to,
        uint _amount,
        address _contractAddress
    );

    function new_owner(address _owner) public {
        require(_owner != address(0), "Wrong Address, aborting");
        require(_owner != owner, "Already Owner, aborting!");

        _owner = owner;

        emit NewOwner(msg.sender, _owner);
    }

    receive() external payable {}

    function stacking_eth(address payable _staker, uint _amount)
        public
        payable
    {
        require(_amount >= 0.5 ether, "Not enough ethers provided, aborting!");
        require(StackMap[_staker].balance == 0, "Already staked, aborting!");

        StackMap[_staker].balance += _amount;
        StackMap[_staker].stake_time = block.timestamp;

        emit StakeDetails(_staker, _amount, address(this));
    }

    function withdraw_time(address _staker) public view returns (uint) {
        uint stake_time = StackMap[_staker].stake_time;
        uint withdraw_stake_time = stake_time + (30 * 24 * 60 * 60);
        return withdraw_stake_time;
    }

    function calculate_reward(address _staker) public view returns (uint) {
        uint reward = (StackMap[_staker].balance * 2) / 100;
        return reward;
    }

    function withdraw_stake(address payable _staker) public {
        require(StackMap[_staker].bal > 0, "Not staked yet, aborting!");
        require(
            withdraw_time(_staker) <= block.timestamp,
            "Withdraw time isn't over yet, aborting!"
        );
        uint reward_stake = StackMap[_staker].balance +
            calculate_reward(_staker);
        require(
            address(this).balance >= reward_stake,
            "Not enough funds, contact owner!"
        );

        StackMap[_staker].balance = 0;
        StackMap[_staker].stake_time = 0;

        _staker.transfer(reward_stake);

        emit Withdraw_Details(_staker, reward_stake, address(this));
    }

    function stake_balance(address _staker) public view returns (uint) {
        return StackMap[_staker].balance;
    }

    function withdraw_owner(address payable _to, uint _amount)
        public
        onlyOwner
    {
        require(
            address(this).balance >= _amount,
            "Not enough funds, aborting!"
        );
        _to.transfer(_amount);
        emit WithdrawOwner(msg.sender, _to, _amount, address(this));
    }
}
