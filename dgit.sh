#/bin/bash

stty size | perl -ale 'print "-"x$F[1]'
echo -e "Decentralized-Git-on-IPFS Wrapper"
stty size | perl -ale 'print "-"x$F[1]'

cmd=$1
ipfs_cid=$2
key=$3

function get_repo_from_ipfs {
    rm -rf ~/.tmp
    mkdir ~/.tmp
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
        key='vcvra-1002'

        #fn call
        get_repo_from_ipfs

        echo -e "Pushing repository... \n"
        git remote rm temp
        git remote add temp ~/.tmp/bare/$friendname
        git push temp

        # zip bare repo
        (cd ~/.tmp/bare/ && zip -q -re ../$friendname.enc .)

        # zip -q -re ~/.tmp/$friendname.enc ~/.tmp/bare/$friendname

        ipfs add ~/.tmp/$friendname.enc 

        # fn call
        # clean_up

    ;;
    'pull')
        #get prior IPFS CID and friendname from .git/description
        ipfs_cid=$(sed -n 1p .git/description)
        friendname=$(sed -n 2p .git/description)
        key='vcvra-1002'

        #fn call
        get_repo_from_ipfs

        echo -e "Pulling repository... \n"
        git pull ~/.tmp/bare/$friendname $friendname

        # fn call
        clean_up
    ;;

esac