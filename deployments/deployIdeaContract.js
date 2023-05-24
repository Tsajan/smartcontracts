async function main() {
    const IdeaContract = await ethers.getContractFactory("IdeaContract");
    const ideaContract = await IdeaContract.deploy();
    console.log("Contract deployed to the address: ", ideaContract.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });