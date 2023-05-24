pragma solidity ^0.8.9;

contract IdeaContract {
    struct Idea {
        address creator;
        string content;
    }

    mapping(uint256 => Idea) public ideas;
    uint256 public ideaCount;

    event IdeaCreated(uint256 indexed id, address indexed creator, string content);

    constructor() {
        ideaCount = 0;
    }

    function createIdea(string memory content) external {
        require(bytes(content).length <= 1000, "Content exceeds 1000 characters limit");

        ideas[ideaCount] = Idea(msg.sender, content);
        emit IdeaCreated(ideaCount, msg.sender, content);
        ideaCount++;
    }

    function getAllIdeas() external view returns (Idea[] memory) {
        Idea[] memory allIdeas = new Idea[](ideaCount);

        for(uint256 i=0; i < ideaCount; i++) {
            allIdeas[i] = ideas[i];
        }
        return allIdeas;
    }
}