# Decentralized-Git-on-IPFS Wrapper
### (currently alpha)
Maintain a truly decentralized software repository with this IPFS wrapper layer for Git VCS.

This wrapper is meant to be compatible with standard git commands wherever possible.

## Setup
	cp dgit.sh /usr/local/bin 			# Copy dgit.sh to /usr/local/bin
	chmod +x /usr/local/bin/dgit.sh 	# Make dgit.sh executable

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
