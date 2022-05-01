/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
import { printAllEvents } from '../test/helpers/functions';
import { MultiSignatureV1 } from '../typechain';

// Create a new proposal and do qick transfer
const PERMISSION_CREATE = 1;
// Allowed to sign quick transfer message and vote a proposal
const PERMISSION_VOTE = 2;
// Permission to execute the proposal
const PERMISSION_EXECUTE = 4;
// View permission only
const PERMISSION_OBSERVER = 4294967296;

// eslint-disable-next-line no-bitwise
const ROLE_ADMIN = PERMISSION_CREATE | PERMISSION_EXECUTE | PERMISSION_OBSERVER | PERMISSION_VOTE;

task('deploy:multisig', 'Deploy multi signature v1 contract').setAction(
  async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const accounts = await hre.ethers.getSigners();
    console.log('Deployer:', accounts[0].address);
    const deployer: Deployer = Deployer.getInstance(hre);
    deployer.connect(accounts[0]);
    const multisig = <MultiSignatureV1>await deployer.contractDeploy('Duelist King/MultiSignatureV1', []);
    await printAllEvents(
      await multisig.init(
        [
          '0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4',
          '0x90EBFC3D7FeeB282cd3b9b4296754bacba8ab75a',
          '0xea01844207ebf56C87E1F6f4173d65fb662B15ba',
          '0xeE4fe9347a7902253a515CC76EaA3253b47a1837',
        ],
        [ROLE_ADMIN, ROLE_ADMIN, ROLE_ADMIN, ROLE_ADMIN],
        50,
        70,
      ),
    );
    deployer.printReport();
  },
);

export default {};
