// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PBVotingv2 {

    // structure to store the details of a given project
    struct Project {
        // id will be indexed from 0 to n-1
        string name;
        uint256 cost;
    }

    // structure to store details of each project with their status of election results
    struct Result {
        uint256 projectId;
        string projectName;
        uint256 projectCost;
        uint256 totalVotes;
        bool selected;
    }

    address public owner;
    address[] public voters;
    uint256 public totalBudget;
    Project[] public projects;
    Result[] public results;
    
    mapping(address => uint256[]) public userVotes;
    mapping(address => bool) public hasVoted;

    bool public votingOpen;
    uint public votingStartTime;
    uint public votingEndTime;

    event UserVoted(address userAddress, uint256[] projectIds);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyDuringVotingPeriod() {
        require(votingOpen, "Voting is not currently open");
        require(block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "Outside voting period");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner has access!");
        _;
    }

    // function to set available budget for PB process
    function setAvailableBudget(uint256 _availableBudget) external onlyOwner {
        require(!votingOpen, "Budget cannot be changed during voting period");
        totalBudget = _availableBudget;
    }

    // function to add a new project with its cost
    function addProject(string memory projectName, uint256 cost) external onlyOwner {
        require(!votingOpen, "Projects cannot be added during elections");
        require(cost > 0, "Project cost should be greater than 0");
        require(bytes(projectName).length > 0, "Project name is required");
        projects.push(Project(projectName, cost));
    }

    // we will just pass array of integer values: 0 for unselected; 1 for selected. Array length equals total number of projects;
    function approvalVote(uint256[] memory _projectSelections) public {
        require(!hasVoted[msg.sender], "Voter has already voted");
        require(votingOpen, "Voting is not currently open");
        require(_projectSelections.length == projects.length, "Should provide approval vote for all set of available projects");
        
        uint256 totalProjectCost = 0;

        for (uint256 i=0; i < _projectSelections.length; i++) {
            uint256 currProjectVoted = _projectSelections[i];
            if(currProjectVoted == 1) {
                totalProjectCost += projects[i].cost;
            }
        }

        // additional check to ensure votes with budget exceeding total budget are not accepted
        require(totalBudget >= totalProjectCost, "Projects selected have greater cost than total available budget");

        // add the user vote
        userVotes[msg.sender] = _projectSelections;
        voters.push(msg.sender);
        hasVoted[msg.sender] = true; // prevent re-voting by the same user
        emit UserVoted(msg.sender, _projectSelections);


        // aggregate votes
        for (uint256 i = 0; i < _projectSelections.length; i++) {
            uint256 isVotedByUser = _projectSelections[i];

            if(isVotedByUser == 1) {
                results[i].totalVotes += 1;
            }
        }

    }

    function getGreedyApprovalResults() public onlyOwner returns (Result[] memory) {
        require(block.timestamp >= votingEndTime, "Votes cannot be aggregated until election closes");

        uint256 availableBudget = totalBudget;

        // Sort the array based on maximum number of votes
        sortResults();

        // determine selected projects based on total votes and cost
        for (uint256 i=0; i < results.length; i++) {
            if(availableBudget >= results[i].projectCost) {
                results[i].selected = true;
                availableBudget -= results[i].projectCost;
            } else {
                break;
            }
        }

        return results;
    }

    // helper function to sort the results array based on the number of votes on descending order
    function sortResults() internal {
        uint256 n = results.length;

        for (uint256 i = 0; i < n - 1; i++) {
            for (uint256 j = 0; j < n - i - 1; j++) {
                if (results[j].totalVotes < results[j + 1].totalVotes) {
                    Result memory temp = results[j];
                    results[j] = results[j + 1];
                    results[j + 1] = temp;
                }
            }
        }
    }

    function openVotingFor(uint256 numHours) public {
        require(!votingOpen, "Voting is already open");
        require(projects.length > 0, "No projects have been added yet");
        votingOpen = true;
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + (numHours * 1 hours); // Set a default duration of 1 hour if not explicitly set

        // initialize results
        for (uint256 i=0; i < projects.length; i++) {
            Project memory project = projects[i];
            Result memory currProject;
            currProject.projectId = i;
            currProject.projectName = project.name;
            currProject.totalVotes = 0;
            currProject.projectCost = project.cost;
            currProject.selected = false;
            results.push(currProject);
        }
    }

    function closeVoting() public {
        require(votingOpen, "Voting is not currently open");
        require(block.timestamp >= votingEndTime, "Voting end time has not yet elapsed");
        votingOpen = false;
    }

}