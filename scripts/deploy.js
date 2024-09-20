async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const EduchainResearchRepository = await ethers.getContractFactory("EduchainResearchRepository");
    const contract = await EduchainResearchRepository.deploy();

    console.log("Contract deployed to address:", contract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
