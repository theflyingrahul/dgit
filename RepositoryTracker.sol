// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract RepositoryTracker is Ownable, AccessControl {
    string private _ipfsAddress;
    string private _friendlyName;

    /* Nested structs don't work in Solidity as of now, going for a ramshackle soln.
    struct Comment {
        address from;
        string comment;
    }*/

    // TODO: implement pull requests
    enum PullRequestStatus {
        OPEN,
        AUDITING,
        APPROVED,
        MERGED,
        REJECTED
    }
    struct PullRequest {
        address from;
        string title;
        string description;
        // Comment[] comments'
        address[] commentFrom;
        string[] comments;
        string oldBafyHash;
        string prBafyHash;
        address assignedTo;
        string[] labels;
        PullRequestStatus status;
    }

    PullRequest[] private _pullRequests;

    // TODO: implement issues
    enum IssueStatus {
        OPEN,
        ASSIGNED,
        CLOSED
    }

    struct Issue {
        address from;
        string title;
        string description;
        // Comment[] comments;
        address[] commentFrom;
        string[] comments;
        string bafyHash;
        address assignedTo;
        IssueStatus status;
    }

    Issue[] private _issues;

    // Roles
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");
    bytes32 public constant AUDIT_ROLE = keccak256("AUDIT_ROLE"); // TODO: but what does an auditor do?

    modifier onlyDeveloper() {
        require(hasRole(DEV_ROLE, msg.sender), "Caller is not a developer!");
        _;
    }

    modifier onlyAuditor() {
        require(
            hasRole(AUDIT_ROLE, msg.sender) || hasRole(DEV_ROLE, msg.sender),
            "Caller is not an auditor!"
        );
        _;
    }

    function addDeveloper(address devAddress) public onlyOwner {
        _grantRole(DEV_ROLE, devAddress);
    }

    function addDevelopers(address[] memory devAddresses) public onlyOwner {
        for (uint256 i = 0; i < devAddresses.length; i++) {
            _grantRole(DEV_ROLE, devAddresses[i]);
        }
    }

    function addAuditor(address auditAddress) public onlyOwner {
        _grantRole(AUDIT_ROLE, auditAddress);
    }

    function addAuditors(address[] memory auditAddresses) public onlyOwner {
        for (uint256 i = 0; i < auditAddresses.length; i++) {
            _grantRole(AUDIT_ROLE, auditAddresses[i]);
        }
    }

    // End roles stuff!

    constructor(
        string memory bafyHash,
        string memory friendlyName,
        address[] memory devAddresses,
        address[] memory auditAddresses
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        addDevelopers(devAddresses);
        addAuditors(auditAddresses);

        _ipfsAddress = bafyHash;
        _friendlyName = friendlyName;
    }

    function setIpfsAddress(string calldata bafyHash) public onlyDeveloper {
        _ipfsAddress = bafyHash;
    }

    function setFriendlyName(string calldata friendlyName) public onlyOwner {
        _friendlyName = friendlyName;
    }

    function getIpfsAddress() external view returns (string memory) {
        return _ipfsAddress;
    }

    function getFriendlyName() external view returns (string memory) {
        return _friendlyName;
    }

    // Pull Requests stuff!
    function getPullRequest(uint256 id)
        public
        view
        returns (PullRequest memory)
    {
        return _pullRequests[id - 1];
    }

    function newPullRequest(
        string calldata title,
        string calldata description,
        string calldata oldBafyHash,
        string calldata prBafyHash
    ) public onlyAuditor returns (uint256) {
        string[] memory labels;
        labels[0] = "new";

        address[] memory commentFrom;
        commentFrom[0] = msg.sender;

        string[] memory comments;
        comments[0] = "Pull request created";

        // Comment[] memory comments;
        // comments[0] = Comment(msg.sender, "Pull request created");
        PullRequest memory pr = PullRequest(
            msg.sender,
            title,
            description,
            // comments,
            commentFrom,
            comments,
            oldBafyHash,
            prBafyHash,
            address(0),
            labels,
            PullRequestStatus.OPEN
        );
        _pullRequests.push(pr);
        return _pullRequests.length;
    }

    function assignAuditorToPullRequest(uint256 prId, address auditorAddress)
        public
        onlyDeveloper
    {
        _pullRequests[prId].assignedTo = auditorAddress;
    }

    // Issue tracker stuff!
    function getIssue(uint256 id) public view returns (Issue memory) {
        return _issues[id];
    }

    function newIssue(
        string calldata title,
        string calldata description,
        string calldata bafyHash
    ) public onlyAuditor returns (uint256) {
        // Comment[] memory comments;
        // comments[0] = Comment(msg.sender, "Issue created");

        address[] memory commentFrom;
        commentFrom[0] = msg.sender;

        string[] memory comments;
        comments[0] = "Pull request created";
        
        Issue memory issue = Issue(
            msg.sender,
            title,
            description,
            // comments,
            commentFrom,
            comments,
            bafyHash,
            address(0),
            IssueStatus.OPEN
        );
        _issues.push(issue);
        return _issues.length;
    }

    function assignAuditorToIssue(uint256 issueId, address auditorAddress)
        public
        onlyDeveloper
    {
        _issues[issueId].assignedTo = auditorAddress;
        _issues[issueId].status = IssueStatus.ASSIGNED;
    }

    function commentOnIssue(uint256 issueId, string calldata comment)
        public
        onlyAuditor
    {
        _issues[issueId].commentFrom.push(msg.sender);
        _issues[issueId].comments.push(comment);
    }

    function updateIssueTitle(uint256 issueId, string calldata title) public {
        require(
            _issues[issueId].from == msg.sender,
            "Caller is the person who created the issue!"
        );
        _issues[issueId].title = title;
    }

    function updateIssueDescription(uint256 issueId, string calldata desc) public {
        require(
            _issues[issueId].from == msg.sender,
            "Caller is the person who created the issue!"
        );
        _issues[issueId].description = desc;
    }

    function updateIssueBafyHash(uint256 issueId, string calldata bafyHash) public {
        require(
            _issues[issueId].from == msg.sender,
            "Caller is the person who created the issue!"
        );
        _issues[issueId].bafyHash = bafyHash;
    }

    function updateIssueStatus(uint256 issueId, IssueStatus status)
        public
        onlyDeveloper
    {
        _issues[issueId].status = status;
    }
}
