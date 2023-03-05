import { ethers } from 'ethers'

/**
 * Deploy the given contract
 * @param {string} contractName name of the contract to deploy
 * @param {Array<any>} args list of constructor' parameters
 * @param {Number} accountIndex account index from the exposed account
 * @return {Contract} deployed contract
 */
export const deploy = async (contractName: string, args: Array<any>, accountIndex?: number): Promise<ethers.Contract> => {    

    console.log(`deploying ${contractName}`)
    // Note that the script needs the ABI which is generated from the compilation artifact.
    // Make sure contract is compiled and artifacts are generated
    const artifactsPath = `browser/contracts/artifacts/${contractName}.json` // Change this for different path

    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
    // 'web3Provider' is a remix global variable object
    
    const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner(accountIndex)

    const factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer)

    const contract = await factory.deploy(...args)

    // The contract is NOT deployed yet; we must wait until it is mined
    await contract.deployed()
    return contract
}

export async function deployWithProxy(contract: string, calldata: ethers.BytesLike, proxyAddress?: string) {
    const impl = await deploy(contract, []);
    const artifactsPath = `browser/contracts/artifacts/${contract}.json`
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))

    const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner();

    if (typeof proxyAddress === 'undefined') {
        const proxy = await deploy('UUPSUpgradeProxy', [impl.address, calldata]);
        return ethers.getContractAt(metadata.abi, proxy.address, signer);
    }

    const proxy = await ethers.getContractAt(metadata.abi, proxyAddress, signer);
    await proxy.upgradeTo(impl.address);
    return proxy;
}
