// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract EduchainResearchRepository is AccessControl 
{
    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant CONTRIBUTER_ROLE = keccak256("CONTRIBUTER_ROLE");
    bytes32 public constant REVIEWER_ROLE = keccak256("REVIEWER_ROLE");

    // Structure for research paper metadata
    struct ResearchPaper 
    {
        string title;
        string author;
        string paper_abstract;
        string document_hash; // IPFS or Arweave hash
        uint256 version;
        uint256 comment_count;
        uint256 view_count;
        uint256 download_count;
    }

    // Structure for research paper comments
    struct Comment 
    {
        address commenter;
        string text;
        uint256 timestamp;
    }

    // Map of research paper id to research paper metadata
    mapping(uint256 => ResearchPaper) private papers;
    mapping(uint256 => Comment[]) private paperComments;

    // ID of the next research paper added to the repository
    uint256 private nextPaperId;

    // Define events
    event PaperAdded(uint256 indexed paperId, string title, string author);
    event PaperUpdated(uint256 indexed paperId, string title, string author);
    event PaperDeleted(uint256 indexed paperId);
    event CommentAdded(uint256 indexed paperId, address indexed commenter, string text);
    event PaperViewed(uint256 indexed paperId, address indexed viewer);
    event PaperDownloaded(uint256 indexed paperId, address indexed downloader);

    // Assign roles to the deployer of the contract
    constructor() 
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(REVIEWER_ROLE, msg.sender);
    }

    // Modifier to check if the caller is an admin
    modifier onlyAdmin() 
    {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    // Modifier to check if the caller is a contributer
    modifier onlyContributer() 
    {
        require(hasRole(CONTRIBUTER_ROLE, msg.sender), "Caller is not a contributer");
        _;
    }

    // Modifier to check if the caller is a reviewer
    modifier onlyReviewer() 
    {
        require(hasRole(REVIEWER_ROLE, msg.sender), "Caller is not a reviewer");
        _;
    }

    // Add a new research paper to the repository(Admin only)
    function addResearchPaper(string memory _title, string memory _author, string memory _paper_abstract, string memory _document_hash) public onlyAdmin 
    {
        uint256 paperId = nextPaperId++;
        papers[paperId] = ResearchPaper({title: _title, author: _author, paper_abstract: _paper_abstract, document_hash: _document_hash, version: 1, comment_count: 0, view_count: 0, download_count: 0});
        
        // Trigger the event
        emit PaperAdded(paperId, _title, _author);
    }

    // Update an existing research paper in the repository(Admin only)
    function updateResearchPaper(uint256 _paperId, string memory _title, string memory _author, string memory _paper_abstract, string memory _document_hash) public onlyAdmin 
    {
        require(papers[_paperId].version > 0, "Paper does not exist");
        papers[_paperId] = ResearchPaper({title: _title, author: _author, paper_abstract: _paper_abstract, document_hash: _document_hash, version: papers[_paperId].version + 1, comment_count: papers[_paperId].comment_count, view_count: papers[_paperId].view_count, download_count: papers[_paperId].download_count});
        
        // Trigger the event
        emit PaperUpdated(_paperId, _title, _author);
    }

    // Delete an existing research paper from the repository(Admin only)
    function deleteResearchPaper(uint256 _paperId) public onlyAdmin 
    {
        require(papers[_paperId].version > 0, "Paper does not exist");
        delete papers[_paperId];
        delete paperComments[_paperId];
        
        // Trigger the event
        emit PaperDeleted(_paperId);
    }

    // Add comment to a research paper (Contributer or Reviewer)
    function addComment(uint256 _paperId, string memory _text) public onlyContributer onlyReviewer 
    {
        require(papers[_paperId].version > 0, "Paper does not exist");
        paperComments[_paperId].push(Comment({commenter: msg.sender, text: _text, timestamp: block.timestamp}));
        papers[_paperId].comment_count++;
        
        // Trigger the event
        emit CommentAdded(_paperId, msg.sender, _text);
    }

    // Reterieve comments for a research paper
    function getComments(uint256 _paperId) public view returns (Comment[] memory) 
    {
        return paperComments[_paperId];
    }

    // Record a view of a research paper
    function recordView(uint256 _paperId) public 
    {
        require(papers[_paperId].version > 0, "Paper does not exist");
        papers[_paperId].view_count++;
        
        // Trigger the event
        emit PaperViewed(_paperId, msg.sender);
    }

    // Record the download of a research paper
    function recordDownload(uint256 _paperId) public 
    {
        require(papers[_paperId].version > 0, "Paper does not exist");
        papers[_paperId].download_count++;
        
        // Trigger the event
        emit PaperDownloaded(_paperId, msg.sender);
    }

    // Add a role to a user (Admin only)
    function addRole(address account, bytes32 role) public onlyAdmin 
    {
        grantRole(role, account);
    }

    // Remove a role from a user (Admin only)
    function removeRole(address account, bytes32 role) public onlyAdmin 
    {
        revokeRole(role, account);
    }

    // Modifier to check if the caller is a contributer or reviewer
    modifier onlyContributerOrReviewer() 
    {
        require(hasRole(CONTRIBUTER_ROLE, msg.sender) || hasRole(REVIEWER_ROLE, msg.sender), "Caller is neither a contributer nor reviewer");
        _;
    }

}