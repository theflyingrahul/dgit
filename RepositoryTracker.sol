// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract RepositoryTracker is Ownable, AccessControl {
    string private _ipfsAddress;
    string private _friendlyName;

    // Roles
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");
    bytes32 public constant AUDIT_ROLE = keccak256("AUDIT_ROLE");

    constructor(string memory bafyHash, string memory friendlyName) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _ipfsAddress = bafyHash;
        _friendlyName = friendlyName;
    }

    modifier onlyDeveloper() {
        require(hasRole(DEV_ROLE, msg.sender), "Caller is not a developer!");
        _;
    }

    modifier onlyAuditor() {
        require(hasRole(AUDIT_ROLE, msg.sender), "Caller is not an auditor!");
        _;
    }

    function addDeveloper(address memory devAddress) external onlyOwner {
        _grantRole(DEV_ROLE, devAddress);
    }

    function addDevelopers(address[] memory devAddresses) external onlyOwner {
        for (uint256 i = 0; i < devAddresses.length; i++) {
            _grantRole(DEV_ROLE, devAddresses[i]);
        }
    }

    function addAuditor(address memory auditAddress) external onlyOwner {
        _grantRole(AUDIT_ROLE, auditAddress);
    }

    function addAuditors(address[] memory auditAddresses) external onlyOwner {
        for (uint256 i = 0; i < auditAddresses.length; i++) {
            _grantRole(AUDIT_ROLE, auditAddresses[i]);
        }
    }

    // End ownership stuff!

    function setIpfsAddress(string calldata bafyHash) public {
        _ipfsAddress = bafyHash;
    }

    function setFriendlyName(string calldata friendlyName)
        public
        onlySuperOwner
    {
        _friendlyName = friendlyName;
    }

    function getIpfsAddress() external view returns (string memory) {
        return _ipfsAddress;
    }

    function getFriendlyName() external view returns (string memory) {
        return _friendlyName;
    }
}
