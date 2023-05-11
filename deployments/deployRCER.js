async function main() {
    const CERT = await ethers.getContractFactory("ReducedCarbonEmissionRewards");
    const cert = await CERT.deploy("Reduced Carbon Emission Rewards Token", "RCER", 5000000);
    console.log("Contract deployed to the address: ", cert.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });