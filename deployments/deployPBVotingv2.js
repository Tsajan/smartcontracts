async function main() {
    const PBVotingContractv2 = await ethers.getContractFactory("PBVotingv2");
    const pbVotingContractv2 = await PBVotingContractv2.deploy();
    console.log("PBVoting contract v2 deployed to the address: ", pbVotingContractv2.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });