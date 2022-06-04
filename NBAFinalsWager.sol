// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./Owner.sol";

contract NBAFinalsWager is Owner {
    // Status of the betting window
    enum Status {
        Paused,
        Opened,
        Closed
    }
    Status public status;

    // Team A struct schema
    struct TeamA {
        string name;
        address[] votes;
        uint amount;
    }
    TeamA private teamA;

    // Team B struct schema
    struct TeamB {
        string name;
        address[] votes;
        uint amount;
    }
    TeamB private teamB;

    constructor(string memory _nameA, string memory _nameB) {
        setTeamName(_nameA, _nameB);
    }

    function viewTeam() 
        external 
        view 
        returns (string memory, uint, uint) 
    {
        return (teamA.name, teamA.votes.length, teamA.amount);
    }

    function wage(uint8 team) public payable {
        require(team == 0 || team == 1, "Invalid team value");
        require(msg.value > 0, "You must include funds to wage");

        deposit(team, msg.value, msg.sender);
        
    }

    function deposit(uint8 team, uint256 value, address sender) internal {
        if (team == 0) {
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