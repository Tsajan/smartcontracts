async function main() {
    const PBRewardToken = await ethers.getContractFactory("PBRewardToken");
    const pbRewardToken = await PBRewardToken.deploy();
    console.log("PBRewardToken contract deployed to the address: ", pbRewardToken.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });