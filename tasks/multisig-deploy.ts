/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
// @ts-ignore
import { MultiSignatureMaster, MultiSignatureV1 } from '../typechain';

task('multisig:deploy', 'Deploy multisig master and multisig implementation').setAction(
  async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const [deployerSigner] = await hre.ethers.getSigners();
    const deployer = Deployer.getInstance(hre).connect(deployerSigner);

    const multiSignatureV1 = <MultiSignatureV1>await deployer.contractDeploy('Operators/MultiSignatureV1', []);
    const multisigMaster = <MultiSignatureMaster>(
      await deployer.contractDeploy(
        'Operators/MultiSignatureMaster',
        [],
        [deployerSigner.address, deployerSigner.address],
        [1, 2],
        multiSignatureV1.address,
        0,
      )
    );

    console.log(`Master: ${multisigMaster.address}`);
    console.log(
      `MultiSig: ${multiSignatureV1.address} is correct (${
        multiSignatureV1.address === (await multisigMaster.getImplementation())
      })`,
    );
    await deployer.printReport();
  },
);

export default {};
