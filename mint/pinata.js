const pinataSDK = require('@pinata/sdk');
const fs = require('fs');
const path = require('path');
require('dotenv').config()

const pinata = new pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_API_SECRET);

const options = {
    pinataMetadata: {
        name: "A wonderful NFT",
    },
    pinataOptions: {
        cidVersion: 0
    }
};

//To upload the image to IPFS
const pinFileToIPFS = () => {
    const imageFile = path.join(__dirname, '../images/pikachu.jpg');
    const readableStreamForFile = fs.createReadStream(imageFile);
    return pinata.pinFileToIPFS(readableStreamForFile, options).then((result) => {
        return `https://gateway.pinata.cloud/ipfs/${result.IpfsHash}`
    }).catch((err) => {
        console.log(err);
    });
}

//To add metadata to the image
const pinJSONToIPFS = (body) => {
    return pinata.pinJSONToIPFS(body, options).then((result) => {
        return `https://gateway.pinata.cloud/ipfs/${result.IpfsHash}`
    }).catch((err) => {
        console.log(err);
    });
}

//To get the token URI from IPFS
module.exports = async function getPinataTokenUri() {
    const imageUrl = await pinFileToIPFS()
    const body = {
        name: 'Pikachu',
        type: 'electric',
        secondaryType: 'normal',
        description: "Mouse Pokemon",
        image: imageUrl
    };
    const metadata = await pinJSONToIPFS(body)
    console.log(metadata)
    return metadata;
}