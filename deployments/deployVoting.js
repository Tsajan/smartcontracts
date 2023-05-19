async function main() {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy(60);
    console.log("Contract deployed to the address: ", voting.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });