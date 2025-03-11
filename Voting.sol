// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract DecentralizedVoting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Election {
        string title;
        bool active;
        mapping(uint256 => Candidate) candidates;
        uint256 candidateCount;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Election) public elections;
    uint256 public electionCount;

    event ElectionCreated(uint256 electionId, string title);
    event CandidateAdded(uint256 electionId, uint256 candidateId, string name);
    event VoteCasted(uint256 electionId, uint256 candidateId, address voter);

    modifier electionExists(uint256 _electionId) {
        require(_electionId < electionCount, "Election does not exist");
        _;
    }

    modifier isActiveElection(uint256 _electionId) {
        require(elections[_electionId].active, "Election is not active");
        _;
    }

    function createElection(string memory _title) public {
        Election storage newElection = elections[electionCount];
        newElection.title = _title;
        newElection.active = true;
        emit ElectionCreated(electionCount, _title);
        electionCount++;
    }

    function addCandidate(uint256 _electionId, string memory _name) public electionExists(_electionId) {
        Election storage election = elections[_electionId];
        uint256 candidateId = election.candidateCount;
        election.candidates[candidateId] = Candidate(_name, 0);
        election.candidateCount++;
        emit CandidateAdded(_electionId, candidateId, _name);
    }

    function vote(uint256 _electionId, uint256 _candidateId) public electionExists(_electionId) isActiveElection(_electionId) {
        Election storage election = elections[_electionId];

        require(!election.hasVoted[msg.sender], "You have already voted");
        require(_candidateId < election.candidateCount, "Invalid candidate");

        election.candidates[_candidateId].voteCount++;
        election.hasVoted[msg.sender] = true;

        emit VoteCasted(_electionId, _candidateId, msg.sender);
    }

    function endElection(uint256 _electionId) public electionExists(_electionId) {
        elections[_electionId].active = false;
    }

    function getCandidateVotes(uint256 _electionId, uint256 _candidateId) public view electionExists(_electionId) returns (string memory, uint256) {
        require(_candidateId < elections[_electionId].candidateCount, "Invalid candidate");
        Candidate storage candidate = elections[_electionId].candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }
}
