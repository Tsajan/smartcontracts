async function main() {
    const PokeToken = await ethers.getContractFactory("PokeToken");
    const pokeToken = await PokeToken.deploy();
    console.log("Contract deployed to the address: ", pokeToken.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });