# Decentralized-Git-on-IPFS Wrapper
### (currently alpha)
Maintain a truly decentralized software repository with this IPFS wrapper layer for Git VCS.

## What you should know?
1. IPFS is a decentralized storage system and protocol.
2. IPFS is transparent and immutable.
3. IPFS used content-addressing.
4. This wrapper uses a symmetric encryption algorithm to protect content on the IPFS network.
5. This wrapper is meant to be compatible with standard git commands (wherever possible).

## Setup

 1. Copy dgit.sh to /usr/local/bin: `cp dgit.sh /usr/local/bin/dgit`
 2. Make dgit.sh executable: `chmod +x /usr/local/bin/dgit`

## Usage
Use as: `dgit <command> <symmetric key> <IPFS content ID of repository>`
where command takes init, clone, push, or pull...
...and IPFS CID takes a QmHash/bafyHash

## Commands
### dgit init
Initialize a new repository or reinitialize an existing git repository and migrate repository to IPFS storage.
Returns operation status, IPFS content ID, and friendly name (directory name) of the repository.

> Required arguments: `symmetric encryption key`

### dgit clone
Clones an existing repository from IPFS network to local storage (in pwd) from the given IPFS content ID.
Returns operation status, IPFS content ID, friendly name (directory name), and destination directory in local of the repository.

> Required arguments: `symmetric encryption key used when publishing to IPFS`, `IPFS content ID`

### dgit push
Push changes to IPFS network with a **NEW** content ID. Because of the data immutability property of IPFS, it is required to push the contents as new IPFS blocks.
Returns operation status, a new IPFS content ID, and friendly name (directory name) of the repository.

> Required arguments: None

### dgit pull
Pulls from a given IPFS content ID and merges the changes to the local copy of the repository.
Returns operation status.

> Required arguments: `symmetric encryption key used when publishing to IPFS`, `IPFS content ID`

## TODOs
1. Multi-branch repositories might be problematic as of now, needs fix.
2. Requires stronger evaluation against less-commonly used git commands.
3. Tracking IPFS content IDs across pushes.

## Contributing to this project
Create pull requests with proposed changes!