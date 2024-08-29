// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
        
    }

    mapping (uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    function createCampaign(string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns(uint256) {
        Campaign storage newCampaign = campaigns[numberOfCampaigns];
        
        require(newCampaign.deadline < block.timestamp, "Deadline must be in the future");
        
        newCampaign.owner = msg.sender;
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.target = _target;
        newCampaign.deadline = _deadline;
        newCampaign.amountCollected = 0;
        newCampaign.image = _image;
        numberOfCampaigns++;
        return numberOfCampaigns-1;

    }


    function donateToCampaign(uint256 _campaignId) public payable {
        Campaign storage selectedCampaign = campaigns[_campaignId];
        require(block.timestamp < selectedCampaign.deadline, "Campaign is closed");
        require(msg.value > 0, "Donation must be greater than 0");
        selectedCampaign.donators.push(msg.sender);
        selectedCampaign.donations.push(msg.value);

        (bool sent , ) = selectedCampaign.owner.call{value: msg.value}("");
        if(sent) {
            selectedCampaign.amountCollected += msg.value;
        }
    }


    function getDonators(uint256 _campaignId) public view returns(address[] memory, uint256[] memory) {
        return (campaigns[_campaignId].donators, campaigns[_campaignId].donations);
    }

    function getCampaigns() public view returns(Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        for(uint256 i = 0; i < numberOfCampaigns; i++) {
            allCampaigns[i] = campaigns[i];
        }
        return allCampaigns;
    }
}