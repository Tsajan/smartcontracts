async function main() {
    const IdeaContractv2 = await ethers.getContractFactory("IdeaContractv2");
    const ideaContractv2 = await IdeaContractv2.deploy();
    console.log("Contract deployed to the address: ", ideaContractv2.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });