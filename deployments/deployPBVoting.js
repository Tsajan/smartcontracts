async function main() {
    const PBVotingContract = await ethers.getContractFactory("PBVoting");
    const pbVotingContract = await PBVotingContract.deploy();
    console.log("PBVoting contract deployed to the address: ", pbVotingContract.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });