/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
// import { ethers } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
import { registryRecords } from '../test/helpers/const';

task('deploy:merchant', 'Deploy all smart contracts')
  // .addParam('account', "The account's address")
  .setAction(async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const accounts = await hre.ethers.getSigners();
    const deployer = Deployer.getInstance(hre);
    await deployer.connect(accounts[0]);
    await deployer.contractDeploy(
      'Duelist King/DuelistKingMerchant',
      [],
      '0x3a2a0B5A8e260bD0c2E8cf3EAA706acD0C832763',
      registryRecords.domain.duelistKing,
    );
    deployer.printReport();
    console.log('Domain:\t', registryRecords.domain.duelistKing);
    console.log('Name:\t', registryRecords.name.merchant);
  });

export default {};
