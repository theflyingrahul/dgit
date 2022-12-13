// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

contract RepositoryTracker {
    string private _ipfsAddress;
    string private _friendlyName;
    address private _owner;

    constructor(string memory bafyHash, string memory friendlyName) {
        _owner = msg.sender;
        _ipfsAddress = bafyHash;
        _friendlyName = friendlyName;
    }

// Ownership stuff
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(
            owner() == msg.sender,
            "Ownership Assertion: Caller of the function is not the owner."
        );
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
    }
// End ownership stuff!
// TODO: extend ownership to contributors or other relations
// TODO: migrate to OpenZeppelin Ownable class

    function setIpfsAddress(string calldata bafyHash) public onlyOwner {
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
}
