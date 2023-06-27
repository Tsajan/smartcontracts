// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PBVoting {
    
    // structure to store the details of a user's vote
    struct UserVote {
        uint256 projectId;
        uint256 cost;
    }

    // structure to store the details of a given project
    struct Project {
        uint256 id;
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
    
    mapping(address => UserVote[]) private userVotes;
    mapping(address => bool) public hasVoted;

    bool public votingOpen;
    uint public votingStartTime;
    uint public votingEndTime;

    event UserVoted(address userAddress, uint256[] projectIds, uint256[] projectCosts);

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
        totalBudget = _availableBudget;
    }

    // function to add a new project with its cost
    function addProject(uint256 projectId, string memory projectName, uint256 cost) external onlyOwner {
        require(projectId > 0, "Invalid project ID");
        require(cost > 0, "Invalid project cost");
        require(bytes(projectName).length > 0, "Project name is required");
        projects.push(Project(projectId, projectName, cost));
    }

    // helper function to check if a project is valid or not
    function isValidProjectId(uint256 _projectId) private view returns (bool) {
        for (uint256 i = 0; i < projects.length; i++) {
            if (projects[i].id == _projectId) {
                return true;
            }
        }
        return false;
    }

    function approvalVote(uint256[] memory _projectIds, uint256[] memory _projectCosts) public {
        require(!hasVoted[msg.sender], "Voter has already voted");
        require(votingOpen, "Voting is not currently open");
        require(_projectIds.length == _projectCosts.length, "Unequal number of projects and their costs");
        
        uint256 userAvailableBudget = totalBudget;

        for (uint256 i = 0; i < _projectIds.length; i++) {
            uint256 projectId = _projectIds[i];
            uint256 projectCost = _projectCosts[i];
            require(isValidProjectId(projectId), "Invalid project ID.");
            require(userAvailableBudget >= projectCost, "Budget limit exceeded");

            // add the user vote
            userVotes[msg.sender].push(UserVote(projectId, projectCost));
            // remove corresponding value of project cost from totalAvailable budget
            userAvailableBudget -= projectCost;
        }

        voters.push(msg.sender);
        hasVoted[msg.sender] = true; // prevent re-voting by the same user

        emit UserVoted(msg.sender, _projectIds, _projectCosts);
    }

    function greedyVoteAggregate() public view returns (Result[] memory) {
        require(block.timestamp >= votingEndTime, "Votes cannot be aggregated until election closes");

        uint256 numProjects = projects.length;
        uint256 availableBudget = totalBudget;
        Result[] memory results = new Result[](numProjects);

        // initialize results
        for (uint256 i=0; i < numProjects; i++) {
            Project memory project = projects[i];
            results[i].projectId = project.id;
            results[i].projectName = project.name;
            results[i].totalVotes = 0;
            results[i].projectCost = project.cost;
            results[i].selected = false;
        }

        // aggregate votes
        for (uint256 i = 0; i < numProjects; i++) {
            Project memory project = projects[i];
            
            for (uint256 j=0; j < voters.length; j++) {
                address currentVoter = voters[j];
                UserVote memory vote = userVotes[currentVoter][i];

                if(vote.projectId == project.id) {
                    results[i].totalVotes += 1;
                }
            }
        }

        // Sort the array based on maximum number of votes
        Result[] memory sortedResults = sortResults(results);

        // determine selected projects based on total votes and cost
        for (uint256 i=0; i < sortedResults.length; i++) {
            if(availableBudget >= sortedResults[i].projectCost) {
                sortedResults[i].selected = true;
                availableBudget -= sortedResults[i].projectCost;
            }
        }

        return sortedResults;
    }

    // helper function to sort the results array based on the number of votes on descending order
    function sortResults(Result[] memory _results) internal pure returns (Result[] memory) {
        uint256 n = _results.length;

        for (uint256 i = 0; i < n - 1; i++) {
            for (uint256 j = 0; j < n - i - 1; j++) {
                if (_results[j].totalVotes < _results[j + 1].totalVotes) {
                    Result memory temp = _results[j];
                    _results[j] = _results[j + 1];
                    _results[j + 1] = temp;
                }
            }
        }
        return _results;
    }

    function openVotingFor(uint256 numHours) public {
        require(!votingOpen, "Voting is already open");
        votingOpen = true;
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + (numHours * 1 hours); // Set a default duration of 1 hour if not explicitly set
    }

    function closeVoting() public {
        require(votingOpen, "Voting is not currently open");
        require(block.timestamp >= votingEndTime, "Voting end time has not yet elapsed");
        votingOpen = false;
    }

}