async function main() {
    const PBApprovalVotingContract = await ethers.getContractFactory("PBApprovalVoting");
    const pbApprovalVotingContract = await PBApprovalVotingContract.deploy();
    console.log("PBVoting approval contract v2 deployed to the address: ", pbApprovalVotingContract.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });