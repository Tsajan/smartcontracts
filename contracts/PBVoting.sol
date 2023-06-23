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
        uint256 id;
        string name;
        uint256 cost;
        uint256 voteCounts;
        bool selected;
    }

    address public owner;
    address[] public voters;
    uint256 public totalBudget;
    mapping(uint256 => Project) public projects;
    Result[] public result; // an array of Result object to store election results after voting
    mapping(address => UserVote[]) public userVotes;
    mapping(address => bool) public hasVoted;

    bool public votingOpen;
    uint public votingStartTime;
    uint public votingEndTime;

    event UserVoted(address userAddress, UserVote[] votes);

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

    function addProject(uint256 projectId, string memory projectTitle, uint256 cost) external onlyOwner {
        require(projectId > 0, "Invalid project ID");
        require(cost > 0, "Invalid project cost");
        require(bytes(projectTitle).length > 0, "Project name is required");
        projects[projectId] = Project(projectId, projectTitle, cost);
    }

    function approvalVote(UserVote[] calldata votes) external {
        require(!hasVoted[msg.sender], "Voter has already voted");
        require(votingOpen, "Voting is not currently open");
        
        uint256 userAvailableBudget = totalBudget;
        for (uint256 i = 0; i < votes.length; i++) {
            uint256 projectId = votes[i].projectId;
            uint256 cost = votes[i].cost;

            require(projects[projectId].cost > 0, "Project does not exist");
            require(cost > 0, "Invalid cost");
            require(userAvailableBudget >= cost, "Budget limit exceeded");

            userVotes[msg.sender].push(UserVote(projectId, cost));
            userAvailableBudget -= cost;
        }

        voters.push(msg.sender);
        hasVoted[msg.sender] = true; // prevent re-voting by the same user

        emit UserVoted(msg.sender, votes);
    }

    function greedyVoteAggregate() external onlyOwner {
        require(block.timestamp >= votingEndTime, "Votes cannot be aggregated until election closes");

        uint256 availableBudget = totalBudget;

        // iterate over all voter
        for (uint256 i = 0; i < voters.length; i++) {
            address currentVoter = voters[i];
            UserVote[] cuv = userVotes[currentVoter];


            
        }
    }

    function openVotingFor(uint256 numHours) public {
        require(!votingOpen, "Voting is already open");
        votingOpen = true;
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + (numHours * 1 hours); // Set a default duration of 1 hour if not explicitly set
    }

    function closeVoting() public {
        require(votingOpen, "Voting is not currently open");
        votingOpen = false;
    }

}