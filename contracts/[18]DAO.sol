// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface INFT {
    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(
        address onwer,
        uint256 index
    ) external view returns (uint256);
}

contract DAO {
    //  we are checking if the user owns the nft or not and then allowing them to mint
    INFT nft;

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

    enum Vote {
        yes, //yes = 0
        no // 1
    }

    address public owner;

    modifier nftHolderOnly() {
        require(nft.balanceOf(msg.sender) > 0, "Not a DAO member");
        _;
    }

    constructor(address _nft) payable {
        nft = INFT(_nft);
        owner = msg.sender;
    }

    modifier activeProposalsOnly(uint256 _id) {
        require(proposals[_id].deadline > block.timestamp, "Deadline exceeded");
        _;
    }

    /// @return Returns index of the proposal created
    function startProposal(
        string memory _proposal
    ) external nftHolderOnly returns (uint256) {
        Proposal storage proposal = proposals[numProposals];
        proposal.proposalName = _proposal;
        proposal.deadline = block.timestamp + 1 days;
        numProposals++;
        return numProposals - 1;
    }

    function voting(
        uint256 _id,
        Vote vote
    ) external nftHolderOnly activeProposalsOnly(_id) {
        Proposal storage proposal = proposals[_id];
        if (vote == Vote.yes) {
            proposal.yesVotes++;
        }
        if (vote == Vote.no) {
            proposal.noVotes++;
        }
    }

    function getVotes(uint256 _id) public view returns (uint256, uint256) {
        Proposal storage proposal = proposals[_id];
        uint256 yes = proposal.yesVotes;
        uint256 no = proposal.noVotes;
        return (yes, no);
    }

    modifier inactiveProposalOnly(uint256 _id) {
        require(
            proposals[_id].deadline <= block.timestamp,
            "Deadline not exceeded"
        );
        require(proposals[_id].executed = false, "proposal already executed");
        _;
    }

    function executeProposal(
        uint256 _id
    ) external nftHolderOnly inactiveProposalOnly(_id) {
        Proposal storage proposal = proposals[_id];
        if (proposal.yesVotes > proposal.noVotes) {
            proposal.executed = true;
        } else {
            proposal.executed = false;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can access this function");
        _;
    }

    function withdrawEther() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "tx failed");
    }

    receive() external payable {}

    fallback() external payable {}
}
