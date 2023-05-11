require('dotenv').config();
var getPinataTokenUri = require('./pinata')
const ethers = require('ethers');

// Get Alchemy API Key
const API_URL = process.env.API_URL;

// Define an Alchemy Provider
const customNetwork = {
    name: "sepolia",
    chainId: 11155111,
    url: API_URL,
};

const provider = new ethers.providers.JsonRpcProvider(customNetwork.url, customNetwork)

const contract = require("../artifacts/contracts/PokeToken.sol/PokeToken.json");
const privateKey = process.env.PRIVATE_KEY
const signer = new ethers.Wallet(privateKey, provider)

// Get contract ABI and address
const abi = contract.abi
const contractAddress = process.env.CONTRACT_ADDRESS

// Create a contract instance
const pokeTokenNFT = new ethers.Contract(contractAddress, abi, signer)
const to = process.env.RECEIVER_ADDRESS

// Call safeMint function
async function mint(){
    let tokenUri = await getPinataTokenUri()
    let nftTxn = await pokeTokenNFT.safeMint(to, tokenUri)
    await nftTxn.wait()
    console.log(`NFT Minted! Check it out`)
}

mint()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });