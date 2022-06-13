/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';

task('deploy:migration', 'Deploy migration contract').setAction(
  async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const accounts = await hre.ethers.getSigners();
    const deployer: Deployer = Deployer.getInstance(hre);
    // We assume that accounts[0] is infrastructure operator
    deployer.connect(accounts[0]);
    if (hre.network.name === 'fantom') {
      await deployer.contractDeploy(
        'Duelist King/DuelistKingMigration',
        [],
        '0xC44b1022f4895F3C04e965f8A82437a8B5cebB70',
        '0x6c375585A31718c38D4E3eb3eddbfb203f142834',
      );
    }
    if (hre.network.name === 'polygon') {
      await deployer.contractDeploy(
        'Duelist King/DuelistKingMigration',
        [],
        '0xb5c01956842cE3a658109776215F86CA4FeE2CBc',
        '0x0000000000000000000000000000000000000000',
      );
    }
    if (hre.network.name === 'hardhat') {
      await deployer.contractDeploy(
        'Duelist King/DuelistKingMigration',
        [],
        '0x0000000000000000000000000000000000000000',
        '0x0000000000000000000000000000000000000000',
      );
    }
    console.log('Deployer:', accounts[0].address);
    deployer.printReport();
  },
);

export default {};
