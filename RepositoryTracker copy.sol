// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

contract RepositoryTracker {
    string private _ipfsAddress;
    string private _friendlyName;
    address private _superOwner;

    // collaborators:
    address[] private _auditors;
    address[] private _developers;
    address[] private _owners;

    constructor(string memory bafyHash, string memory friendlyName) {
        _superOwner = msg.sender;
        _ipfsAddress = bafyHash;
        _friendlyName = friendlyName;
    }

    // Ownership stuff
    function owner() public view virtual returns (address) {
        return _superOwner;
    }

    function getSuperOwner() private view returns (address) {
        return _superOwner;
    }

    function isOwner() private view returns (bool) {
        for (uint i = 0; i < _owners.length; i++) {
            if (_owners[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function isDeveloper() private view returns (bool) {
        for (uint i = 0; i < _developers.length; i++) {
            if (_developers[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function isAuditor() private view returns (bool) {
        for (uint i = 0; i < _auditors.length; i++) {
            if (_auditors[i] == msg.sender) {
                return true;
            }
        }

        return false;
    }

    modifier onlySuperOwner() {
        require(
            getSuperOwner() == msg.sender,
            "Super ownership Assertion: Caller of the function is not the superowner."
        );
        _;
    }

    modifier onlyOwner() {
        require(
            isOwner(),
            "Ownership Assertion: Caller of the function is not an owner."
        );
        _;
    }

    modifier onlyDeveloper() {
        require(
            isDeveloper(),
            "Developer Assertion: Caller of the function is not a developer."
        );
        _;
    }

    modifier onlyAuditor() {
        require(
            isAuditor(),
            "Auditor Assertion: Caller of the function is not an auditor."
        );
        _;
    }

    function transferOwnership(address newOwner) public virtual onlySuperOwner {
        _superOwner = newOwner;
    }

    // End ownership stuff!
    // TODO: extend ownership to contributors or other relations
    // TODO: migrate to OpenZeppelin Ownable class

    function setIpfsAddress(string calldata bafyHash) public onlySuperOwner {
        _ipfsAddress = bafyHash;
    }

    function setFriendlyName(
        string calldata friendlyName
    ) public onlySuperOwner {
        _friendlyName = friendlyName;
    }

    function getIpfsAddress() external view returns (string memory) {
        return _ipfsAddress;
    }

    function getFriendlyName() external view returns (string memory) {
        return _friendlyName;
    }
}
