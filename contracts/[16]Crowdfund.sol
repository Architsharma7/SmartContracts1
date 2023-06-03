// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}

contract CrowdFund {

    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint startAt,
        uint endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    struct Campaign{
        address creator;
        // total amount pledged
        uint pledged;
        //amount to be raised
        uint goal;
        uint startAt;
        uint endAt;
        // if the goal is reached and creator has claimed
        bool claimed;
    }

    IERC20 public immutable token;
    constructor(address _token) {
        token = IERC20(_token);
    }

    // total no. of campaigns created 
    // also used to generate id for new campaigns.
    uint public count;

    // Mapping from id to Campaign
    mapping(uint => Campaign) public campaigns;
    // Mapping from campaign id => pledger => amount pledged
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    function LaunchCampaign(uint _goal, uint _startAt, uint _endAt) external {
        require(_startAt >= block.timestamp, "");
        require(_startAt < _endAt, "");
        require(_endAt <= block.timestamp + 90 days, "");
        count += 1;
        campaigns[count] = Campaign({
            creator : msg.sender,
            pledged: 0,
            goal : _goal,
            startAt : _startAt,
            endAt : _endAt,
            claimed : false 
        });
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function CancelCampaign(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "");
        require(campaign.endAt < block.timestamp, "already ended");
        require(block.timestamp < campaign.startAt, "started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function PledgeInCampaign(uint _id, uint _amount) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.endAt < block.timestamp, "already ended");
        require(block.timestamp < campaign.startAt, "started");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledge(_id, msg.sender, _amount);
    }

    function UnPledgeInCampaign(uint _id, uint _amount) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.endAt < block.timestamp, "already ended");
        require(block.timestamp < campaign.startAt, "started");

        pledgedAmount[_id][msg.sender] -= _amount;
        campaign.pledged -= _amount;

        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function ClaimFromCampaign(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.endAt >= block.timestamp, "");
        require(campaign.creator == msg.sender, "");
        require(!campaign.claimed, "");

        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);
        emit Claim(_id);
    }

    function RefundTokens(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.endAt >= block.timestamp, "");
        require(campaign.pledged > campaign.goal , "");

        uint balance = pledgedAmount[_id][msg.sender];
        token.transfer(msg.sender, balance);
        pledgedAmount[_id][msg.sender] = 0;

        emit Refund(_id, msg.sender, balance);
    }
}