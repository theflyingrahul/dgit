#/bin/bash

stty size | perl -ale 'print "-"x$F[1]'
echo -e "Decentralized-Git-on-IPFS Wrapper"
stty size | perl -ale 'print "-"x$F[1]'

cmd=$1
key=$2
ipfs_cid=$3

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
    # rm -rf ~/.tmp/
}

case $cmd in
    'init') # to migrate an existing/new repository to IPFS system
        friendname=$(pwd | awk -F/ '{print $NF}')

        #(re)initialize git repository
        git init
        mkdir -p ~/.tmp/bare/$friendname
        (cd ~/.tmp/bare/$friendname && git init --bare)

        echo -e "Pushing repository... \n"
        git remote rm temp
        git remote add temp ~/.tmp/bare/$friendname
        git push temp

        # zip bare repo
        (cd ~/.tmp/bare/ && zip -q -P $key -re ../$friendname.enc .)

        ipfs add ~/.tmp/$friendname.enc

        # fn call
        clean_up
        
        echo -e "Writing repository tracking information to disk... \n"
        echo -e "$ipfs_cid\n$friendname" | cat >$(pwd)/$friendname/.git/description

    ;;
    'clone')
        #fn call
        get_repo_from_ipfs

        echo -e "Cloning repository to $(pwd)... \n"
        git clone ~/.tmp/bare/$friendname $friendname
        
        # fn call
        clean_up

        echo -e "Writing repository tracking information to disk... \n"
        echo -e "$ipfs_cid\n$friendname" | cat >$(pwd)/$friendname/.git/description
    ;;
    'push')
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
        (cd ~/.tmp/bare/ && zip -q -P $key -re ../$friendname.enc .)

        # push to IPFS and capture new ipfs_cid
        ipfs_cid=$(ipfs add ~/.tmp/$friendname.enc | awk '{print $2;}')

        # update .git/desc to reflect new ipfs_cid
        echo -e "Writing repository tracking information to disk... \n"
        echo -e "$ipfs_cid\n$friendname" | cat >$(pwd)/.git/description

        # fn call
        clean_up

    ;;
    'pull')
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
         echo -e "Use as: dgit <command> <symmetric key> <IPFS content ID of repository>"
         echo -e "where command takes init, clone, push, or pull...\n...and IPFS CID takes a QmHash/bafyHash\n"
    ;;
esac
