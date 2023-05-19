pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;

    bool public votingOpen;
    uint public votingStartTime;
    uint public votingEndTime;

    modifier onlyDuringVotingPeriod() {
        require(votingOpen, "Voting is not currently open");
        require(block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "Outside voting period");
        _;
    }

    constructor(uint durationInMinutes) {
        votingOpen = false;
        votingStartTime = 0;
        votingEndTime = 0;
        setVotingDuration(durationInMinutes);
    }

    function addCandidate(string memory name) public {
        candidates.push(Candidate(name, 0));
    }

    function vote(uint candidateIndex) public onlyDuringVotingPeriod {
        require(candidateIndex < candidates.length, "Invalid candidate index");
        require(!hasVoted[msg.sender], "Already voted");

        candidates[candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getCandidateCount() public view returns (uint) {
        return candidates.length;
    }

    function getCandidate(uint index) public view returns (string memory, uint) {
        require(index < candidates.length, "Invalid candidate index");

        Candidate memory candidate = candidates[index];
        return (candidate.name, candidate.voteCount);
    }

    function setVotingDuration(uint durationInMinutes) public {
        require(!votingOpen, "Voting is currently open");

        uint durationInSeconds = durationInMinutes * 1 minutes;
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + durationInSeconds;
    }

    function openVoting() public {
        require(!votingOpen, "Voting is already open");

        votingOpen = true;
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + (1 hours); // Set a default duration of 1 hour if not explicitly set
    }

    function closeVoting() public {
        require(votingOpen, "Voting is not currently open");

        votingOpen = false;
    }

    function getVotingResults() public view returns (string[] memory, uint[] memory) {
        string[] memory candidateNames = new string[](candidates.length);
        uint[] memory voteCounts = new uint[](candidates.length);

        for (uint i = 0; i < candidates.length; i++) {
            candidateNames[i] = candidates[i].name;
            voteCounts[i] = candidates[i].voteCount;
        }

        return (candidateNames, voteCounts);
    }
}