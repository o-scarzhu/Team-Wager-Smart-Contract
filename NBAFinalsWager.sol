// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./Owner.sol";

contract NBAFinalsWager is Owner {
    enum Status {
        Paused,
        Opened,
        Closed
    }
    Status public status;

    struct Profile {
        string team;
        uint amount;
    }
    mapping (address => Profile) public profile;

    struct TeamA {
        string name;
        address[] votes;
        uint amount;
    }
    TeamA private teamA;

    struct TeamB {
        string name;
        address[] votes;
        uint amount;
    }
    TeamB private teamB;

    constructor(string memory _nameA, string memory _nameB) {
        setTeamName(_nameA, _nameB);
    }

    function viewTeam(string memory team) 
        external 
        view 
        returns (string memory, uint, uint) 
    {
        require(
            keccak256(abi.encodePacked(team)) == keccak256(abi.encodePacked(teamA.name)) 
            || keccak256(abi.encodePacked(team)) == keccak256(abi.encodePacked(teamB.name)), 
            "Invalid team value");
        if (keccak256(abi.encodePacked(team)) == keccak256(abi.encodePacked(teamA.name))) 
            return (teamA.name, teamA.votes.length, teamA.amount);
        else {
            return (teamB.name, teamB.votes.length, teamB.amount);
        }
    }

    function viewCurrentBet() external view returns (string memory, uint) {
        return (profile[msg.sender].team, profile[msg.sender].amount);
    }

    function wage(string memory team) public payable {
        Profile storage sender = profile[msg.sender];

        require(
            keccak256(abi.encodePacked(team)) == keccak256(abi.encodePacked(teamA.name)) 
            || keccak256(abi.encodePacked(team)) == keccak256(abi.encodePacked(teamB.name)), 
            "Invalid team value");
        require(msg.value > 0, "You must include funds to wage");

        sender.team = team;
        sender.amount = msg.value;

        deposit(team, msg.value, msg.sender); 
    }

    function deposit(string memory team, uint256 value, address sender) internal {
        if (keccak256(abi.encodePacked(team)) == keccak256(abi.encodePacked(teamA.name))) {
            teamA.votes.push(address(sender));
            teamA.amount += value;
        } else {
            teamB.votes.push(address(sender));
            teamB.amount += value;
        }
    }

    function setTeamName(string memory _nameA, string memory _nameB) public isOwner {
        teamA.name = _nameA;
        teamB.name = _nameB;
    }
}