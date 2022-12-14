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

    function getIpfsAddress()
        external
        view
        onlyAuditor
        returns (string memory)
    {
        return _ipfsAddress;
    }

    function getFriendlyName()
        external
        view
        onlyAuditor
        returns (string memory)
    {
        return _friendlyName;
    }
}
