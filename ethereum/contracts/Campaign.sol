// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CampaignFactory {
    Campaign[] public deployedCampaigns;

    function createCampaign(uint256 minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (Campaign[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address payable recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    // 'storage' variables
    address public manager;

    uint256 public minimumContribution;
    uint256 public approversCount;
    uint256 numRequests;

    mapping(address => bool) public approvers;
    mapping (uint => Request) requests;

    modifier restrictedToManager() {
        require(msg.sender == manager);
        _;
    }

    constructor(uint256 minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(
        string calldata description,
        uint256 value,
        address payable recipient
    ) public restrictedToManager {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = recipient;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint256 index) public {
        Request storage request = requests[index];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 index) public restrictedToManager {
        Request storage request = requests[index];

        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}

// mapping is good for single value look-up
// but not good for storing info that we want to iterate
