/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { Signer } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
import { env } from '../env';
// @ts-ignore
import { DuelistKingDistributor, OracleProxy } from '../typechain';
import Card from '../test/helpers/card';
import BytesBuffer from '../test/helpers/bytes';
import { craftProof } from '../test/helpers/functions';

export async function unlockAddress(hre: HardhatRuntimeEnvironment, address: string): Promise<Signer> {
  await hre.network.provider.request({
    method: 'hardhat_impersonateAccount',
    params: [address],
  });
  return hre.ethers.provider.getSigner(address);
}

task('box:mint', 'Create a campaign on BSC for the first time').setAction(
  async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const privateKey = env.PRIVATE_KEY;
    const deployer = Deployer.getInstance(hre);
    const confirmation = hre.network.name === 'binance' ? 5 : 0;

    const [signer] = await hre.ethers.getSigners();

    const salesAgent =
      hre.network.name === 'binance'
        ? new hre.ethers.Wallet(privateKey, hre.ethers.provider)
        : await unlockAddress(hre, '0x74f453DB88C774357579C7500956069cE348fE24');
    deployer.connect(salesAgent);

    const distributor = <DuelistKingDistributor>(
      await deployer.contractAttach('Duelist King/DuelistKingDistributor', '0x57cB34Ac43Aa5b232e46c8b7DFcFe488c80D7259')
    );

    const migratorProxy = <OracleProxy>(
      await deployer.contractAttach('Duelist King/OracleProxy', '0x3AFe5b5085d08F168741B4C7Fe9B3a58F7FDB1d0')
    );

    const phase = 4n;
    const start = 1000000;
    const length = 200;
    const end = start + length;
    const card = new Card('0x0000000000000000000000000000000000000000000000000000000000000000');
    const batch = [];
    card.setId(phase);
    for (let i = start; i < end; i += 100) {
      const buff = new BytesBuffer();
      for (let j = 1; j <= 100; j += 1) {
        card.setSerial(BigInt(i + j));
        buff.writeUint256(card.toString());
        batch.push(card.toString());
      }

      const proof = await craftProof(salesAgent, migratorProxy);
      const tx = await migratorProxy
        .connect(signer)
        .safeCall(
          proof,
          distributor.address,
          0,
          distributor.interface.encodeFunctionData('batchMigrate', [
            await salesAgent.getAddress(),
            true,
            true,
            buff.invoke(),
          ]),
        );
      tx.wait(confirmation);
    }
    fs.writeFileSync(`${__dirname}/result.json`, JSON.stringify(batch));
  },
);

export default {};
