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
        address[] commentFrom;
        string[] comments;
        string oldBafyHash;
        string prBafyHash;
        address assignedTo;
        // Disabling advanced label features for now, out of gas?
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
        address[] commentFrom;
        string[] comments;
        string bafyHash;
        address assignedTo;
        string[] labels;
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

    // Label helper functions for PR and Issue Tracker

    function labelAlreadyPresent(string[] storage labels, string calldata label)
        private
        onlyDeveloper
        returns (bool)
    {
        for (uint256 i = 0; i < labels.length; i++) {
            if (
                keccak256(abi.encodePacked(labels[i])) ==
                keccak256(abi.encodePacked(label))
            ) {
                return true;
            }
        }
        return false;
    }

    // Ah these fns are expensive! Need to optimise!
    /*function findLabelIndex(string[] storage labels, string calldata label) private onlyDeveloper returns(uint) {
        uint i = 0;
        while (keccak256(abi.encodePacked(labels[i])) != keccak256(abi.encodePacked(label))) {
            i++;
        }
        return i;
    }

    function removeLabel(string[] storage labels, string calldata label) private onlyDeveloper returns (string[] storage) {
        uint i = findLabelIndex(labels, label);
        return removeLabelByIndex(labels, i);
    }

    function removeLabelByIndex(string[] storage labels, uint i) private onlyDeveloper returns (string[] storage) {
        while (i<labels.length-1) {
            labels[i] = labels[i+1];
            i++;
        }
        labels.pop();

        return labels;
    }*/

    // Pull Requests stuff!
    function getPullRequest(uint256 id)
        public
        view
        returns (PullRequest memory)
    {
        return _pullRequests[id];
    }

    function newPullRequest(
        string calldata title,
        string calldata description,
        string calldata oldBafyHash,
        string calldata prBafyHash
    ) public onlyAuditor returns (uint256) {
        PullRequest memory pr;
        pr.from = msg.sender;
        pr.title = title;
        pr.description = description;
        pr.oldBafyHash = oldBafyHash;
        pr.prBafyHash = prBafyHash;
        pr.status = PullRequestStatus.OPEN;
        _pullRequests.push(pr);
        return _pullRequests.length;
    }

    // assuming PR review can be done by both dev'r and auditor
    function assignAuditorToPullRequest(uint256 prId, address auditorAddress)
        public
        onlyDeveloper
    {
        _pullRequests[prId].assignedTo = auditorAddress;
    }

    function commentOnPullRequest(uint256 prId, string calldata comment)
        public
        onlyAuditor
    {
        _pullRequests[prId].commentFrom.push(msg.sender);
        _pullRequests[prId].comments.push(comment);
    }

    // add and remove labels from the PR (assuming only devel can add labels?)

    function addLabelToPullRequest(uint256 prId, string calldata label)
        public
        onlyDeveloper
    {
        require(
            !labelAlreadyPresent(_pullRequests[prId].labels, label),
            "Label is already present!"
        );
        _pullRequests[prId].labels.push(label);
    }

    // broken, need to write an optimised algo for removing string from string[] storage
    /*function removeLabelFromPullRequest(uint256 prId, string calldata label)
        public
        onlyDeveloper
    {
        require(
            labelAlreadyPresent(_pullRequests[prId].labels, label),
            "Label is absent!"
        );
        _pullRequests[prId].labels = removeLabel(
            _pullRequests[prId].labels,
            label
        );
    }*/

    function updatePullRequestTitle(uint256 prId, string calldata title)
        public
    {
        require(
            _pullRequests[prId].from == msg.sender,
            "Caller is not the person who created the pull request!"
        );
        _pullRequests[prId].title = title;
    }

    function updatePullRequestDescription(uint256 prId, string calldata desc)
        public
    {
        require(
            _pullRequests[prId].from == msg.sender,
            "Caller is not the person who created the pull request!"
        );
        _pullRequests[prId].description = desc;
    }

    function updatePullRequestOldBafyHash(
        uint256 prId,
        string calldata oldBafyHash
    ) public {
        require(
            _pullRequests[prId].from == msg.sender,
            "Caller is not the person who created the pull request!"
        );
        _pullRequests[prId].oldBafyHash = oldBafyHash;
    }

    function updatePullRequestNewBafyHash(
        uint256 prId,
        string calldata prBafyHash
    ) public {
        require(
            _pullRequests[prId].from == msg.sender,
            "Caller is not the person who created the pull request!"
        );
        _pullRequests[prId].prBafyHash = prBafyHash;
    }

    function approvePullRequest(uint256 prId) public onlyAuditor {
        require(
            _pullRequests[prId].assignedTo == msg.sender ||
                hasRole(DEV_ROLE, msg.sender),
            "Caller is not the assigned auditor or a developer!"
        );
        require(
            _pullRequests[prId].status != PullRequestStatus.APPROVED,
            "PR is already approved!"
        );
        _pullRequests[prId].status = PullRequestStatus.APPROVED;
    }

    function rejectPullRequest(uint256 prId) public onlyAuditor {
        require(
            _pullRequests[prId].assignedTo == msg.sender ||
                hasRole(DEV_ROLE, msg.sender),
            "Caller is not the assigned auditor or a developer!"
        );
        require(
            _pullRequests[prId].status != PullRequestStatus.REJECTED &&
                _pullRequests[prId].status != PullRequestStatus.MERGED,
            "PR is already rejected or merged!"
        );
        _pullRequests[prId].status = PullRequestStatus.REJECTED;
    }

    function mergePullRequest(uint256 prId, string calldata bafyHash)
        public
        onlyAuditor
    {
        require(
            _pullRequests[prId].status != PullRequestStatus.MERGED &&
                _pullRequests[prId].status != PullRequestStatus.REJECTED,
            "PR is rejected or already merged!"
        );
        _pullRequests[prId].status = PullRequestStatus.MERGED;
        //  NOTE: merging needs to be done manually - use dGit
        _ipfsAddress = bafyHash;
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
        Issue memory issue;
        issue.from = msg.sender;
        issue.title = title;
        issue.description = description;
        issue.bafyHash = bafyHash;
        issue.status = IssueStatus.OPEN;
        _issues.push(issue);
        return _issues.length;
    }

    function assignDeveloperToIssue(uint256 issueId, address developerAddress)
        public
        onlyDeveloper
    {
        require(
            hasRole(DEV_ROLE, developerAddress),
            "developerAddress doesn't have DEV_ROLE!"
        );
        require(
            _issues[issueId].status == IssueStatus.OPEN,
            "Issue is already assigned or closed!"
        );
        _issues[issueId].assignedTo = developerAddress;
        _issues[issueId].status = IssueStatus.ASSIGNED;
    }

    function commentOnIssue(uint256 issueId, string calldata comment)
        public
        onlyAuditor
    {
        _issues[issueId].commentFrom.push(msg.sender);
        _issues[issueId].comments.push(comment);
    }

    // add and remove labels from the issue (assuming only devel can add labels?)

    function addLabelToIssue(uint256 issueId, string calldata label)
        public
        onlyDeveloper
    {
        require(
            !labelAlreadyPresent(_issues[issueId].labels, label),
            "Label is already present!"
        );
        _issues[issueId].labels.push(label);
    }

    function updateIssueTitle(uint256 issueId, string calldata title) public {
        require(
            _issues[issueId].from == msg.sender,
            "Caller is not the person who created the issue!"
        );
        _issues[issueId].title = title;
    }

    function updateIssueDescription(uint256 issueId, string calldata desc)
        public
    {
        require(
            _issues[issueId].from == msg.sender,
            "Caller is not the person who created the issue!"
        );
        _issues[issueId].description = desc;
    }

    function updateIssueBafyHash(uint256 issueId, string calldata bafyHash)
        public
    {
        require(
            _issues[issueId].from == msg.sender,
            "Caller is not the person who created the issue!"
        );
        _issues[issueId].bafyHash = bafyHash;
    }

    function closeIssue(uint256 issueId) public onlyDeveloper {
        require(
            _issues[issueId].status != IssueStatus.CLOSED,
            "Issue is already closed!"
        );
        _issues[issueId].status = IssueStatus.CLOSED;
    }
}
