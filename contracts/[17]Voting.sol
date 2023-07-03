// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Voting {
    struct Proposal {
        string proposalName;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
        // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
        bool executed;
        // voters - a mapping to check if the address has casted the vote or not
        mapping(address => bool) voters;
    }

    // mapping proposal id to proposal
    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals = 0;

    enum Vote{
        yes, //yes = 0
        no  // 1
    }

    modifier activeProposalsOnly (uint256 _id) {
        require(proposals[_id].deadline > block.timestamp, "Deadline exceeded");
        _;
    }

    /// @return Returns index of the proposal created
    function startProposal(string memory _proposal) external returns(uint256){
        Proposal storage proposal = proposals[numProposals];
        proposal.proposalName = _proposal;
        proposal.deadline = block.timestamp + 1 days;
        numProposals++;
        return numProposals - 1;
    }

    function voting(uint256 _id, Vote vote) external activeProposalsOnly(_id){
        Proposal storage proposal = proposals[_id];
        if(vote == Vote.yes){
            proposal.yesVotes ++ ;
        }
        if(vote == Vote.no){
            proposal.noVotes ++ ;
        }
    }

    function getVotes(uint256 _id) public view returns(uint256, uint256){
        Proposal storage proposal = proposals[_id];
        uint256 yes = proposal.yesVotes;
        uint256 no = proposal.noVotes;
        return(yes, no);
    }
}
