// This script can be used to deploy the "Storage" contract using ethers.js library.
// Please make sure to compile "./contracts/1_Storage.sol" file before running this script.
// And use Right click -> "Run" from context menu of the file to run the script. Shortcut: Ctrl+Shift+S

import { deploy, deployWithProxy } from './ethers-lib'
import { ethers } from 'ethers'

(async () => {
    try {
        const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner();
        const accessToken = await deploy('AccessToken', []);
        const okimochi = await deployWithProxy('OkimochiToken', '0x8129fc1c');

        await accessToken.mint(await signer.getAddress());

        const conciliatorProxy = await deployWithProxy('ConciliatorProxy', '0x8129fc1c');
        await conciliatorProxy.setAccessTokenContract(accessToken.address);

        await conciliatorProxy.transferOwnership(conciliatorProxy.address);
        await accessToken.transferOwnership(conciliatorProxy.address);
        await okimochi.transferOwnership(conciliatorProxy.address);

        console.log(`ConciliatorProxy: ${conciliatorProxy.address}`);
        console.log(`AccessToken: ${accessToken.address}`);
        console.log(`OkimochiToken: ${okimochi.address}`);
    } catch (e) {
        console.log(e.message)
    }
  })()