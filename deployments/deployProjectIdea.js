async function main() {
    const ProjectIdea = await ethers.getContractFactory("ProjectIdea");
    const projectIdea = await ProjectIdea.deploy();
    console.log("ProjectIdea Contract deployed to the address: ", projectIdea.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });