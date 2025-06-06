#!/bin/bash

stty size | perl -ale 'print "-"x$F[1]'
echo -e "Decentralized-Git-on-IPFS Wrapper"
stty size | perl -ale 'print "-"x$F[1]'

while getopts c:k:i: flag
do
    case "${flag}" in
        c) cmd=${OPTARG};;
        k) key=${OPTARG};;
        i) ipfs_cid=${OPTARG};;
    esac
done

# debug
echo -e $cmd $key $ipfs_cid

# set default password if key=""
if [ -z "$key" ]; then
    echo -e "Using default password! \n"
    key="password"
fi

rm -rf ~/.tmp
mkdir ~/.tmp

function get_repo_from_ipfs {
    echo -e "Fetching repository from IPFS... \n"
    ipfs get $ipfs_cid -o ~/.tmp/$ipfs_cid.enc

    echo -e "\nDecrypting contents... \n"
    unzip -q -P $key ~/.tmp/$ipfs_cid.enc -d ~/.tmp/bare/
    
    friendname=$(ls ~/.tmp/bare)
    echo -e "Friendly repository name: $friendname\n"

}

function clean_up {
    echo -e "\nCleaning up... \n"
    rm -rf ~/.tmp/
}

case $cmd in
    'init') # to migrate an existing/new repository to IPFS system
        # NOTE: execute init command from inside the repository directory!
        
        friendname=$(pwd | awk -F/ '{print $NF}')
               
        # if dir is empty, create README.md (need to push atleast one commit to bare repo?)
        if find -- "$(pwd)" -prune -type d -empty | grep -q '^'; then
            echo "Empty directory detected... creating README.md"
            touch README.md
        else
            echo "Found existing files..."
        fi
        
        #(re)initialize git repository
        git init
        
        # stage and commit existing changes
        git add .
        git commit -m "Initialized new repository"
        
        mkdir -p ~/.tmp/bare/$friendname
        (cd ~/.tmp/bare/$friendname && git init --bare)

        echo -e "Pushing repository... \n"
        git remote rm temp
        git remote add temp ~/.tmp/bare/$friendname
        git push -u temp --all
        # git push temp

        # zip bare repo
        (cd ~/.tmp/bare/ && zip -q --password "$key" -r ../$friendname.enc .)

        # push to IPFS and capture new ipfs_cid
        ipfs_cid=$(ipfs add ~/.tmp/$friendname.enc | awk '{print $2;}')

        # fn call
        clean_up
        
        echo -e "Writing repository tracking information to disk... \n"
        echo -e "$ipfs_cid\n$friendname" | cat >$(pwd)/.git/description
        echo -e "Updated hash: $ipfs_cid\n"

    ;;
    'clone')
        # NOTE: executing clone will create the repo directory for you. DO NOT create one by yourself!
        
        #fn call
        get_repo_from_ipfs

        echo -e "Cloning repository... \n"
        git clone ~/.tmp/bare/$friendname $friendname
        
        # fn call
        clean_up

        echo -e "Writing repository tracking information to disk... \n"
        echo -e "$ipfs_cid\n$friendname" | cat >$(pwd)/$friendname/.git/description
    ;;
    'push')
        # NOTE: execute push from inside the repository directory.
    
        #get prior IPFS CID and friendname from .git/description
        ipfs_cid=$(sed -n 1p .git/description)
        friendname=$(sed -n 2p .git/description)

        #fn call
        get_repo_from_ipfs

        echo -e "Pushing repository... \n"
        git remote rm temp
        git remote add temp ~/.tmp/bare/$friendname
        git push temp $(git branch --show-current):master

        # zip bare repo
        (cd ~/.tmp/bare/ && zip -q -P $key -r ../$friendname.enc .)

        # push to IPFS and capture new ipfs_cid
        ipfs_cid=$(ipfs add ~/.tmp/$friendname.enc | awk '{print $2;}')

        # update .git/desc to reflect new ipfs_cid
        echo -e "\nWriting repository tracking information to disk... \n"
        echo -e "$ipfs_cid\n$friendname" | cat >$(pwd)/.git/description
        echo -e "Updated hash: $ipfs_cid\n"

        # fn call
        clean_up

    ;;
    'pull')
        # NOTE: execute pull from inside the repository directory.
        
        #get prior IPFS CID and friendname from .git/description
        # ipfs_cid=$(sed -n 1p .git/description)
        friendname=$(sed -n 2p .git/description)

        #fn call
        get_repo_from_ipfs

        echo -e "Pulling repository... \n"
        git pull ~/.tmp/bare/$friendname

        # fn call
        clean_up
    ;;
    *)
         echo -e "Use as: dgit -c <command> -k <symmetric key> -i <IPFS content ID of repository>"
         echo -e "where command takes init, clone, push, or pull...\n...and IPFS CID takes a QmHash/bafyHash\n"
    ;;
esac