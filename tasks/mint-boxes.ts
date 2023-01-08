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
      //hre.network.name === 'binance'
      new hre.ethers.Wallet(privateKey, hre.ethers.provider);
    //: await unlockAddress(hre, '0x74f453DB88C774357579C7500956069cE348fE24');
    deployer.connect(salesAgent);

    const distributor = <DuelistKingDistributor>(
      await deployer.contractAttach('Duelist King/DuelistKingDistributor', '0x57cB34Ac43Aa5b232e46c8b7DFcFe488c80D7259')
    );

    const migratorProxy = <OracleProxy>(
      await deployer.contractAttach('Duelist King/OracleProxy', '0x3AFe5b5085d08F168741B4C7Fe9B3a58F7FDB1d0')
    );

    const airdrops = [
      ['0xd0deedffbf125bb75e27694170fb5c1e5ac1e855', 4],
      ['0xff674AEe650a766fb2248C2e950c1129DBB2830E', 4],
      ['0xb69ADef1596b2b0f600452581C786E3Db7B87De6', 4],
      ['0x704A3E08AB16Ab481A56D54Fa3A411C0b2557cB5', 2],
      ['0xa9AAa887C89EAd16373cB97Da4fd8343D086d220', 2],
      ['0xfB8a7f9525a544E730Aa2B41f1917036C44DabF0', 2],
      ['0xa9AAa887C89EAd16373cB97Da4fd8343D086d220', 2],
      ['0x3f2bd800218146562aC75D89BFdeD9E0AD9E960C', 34],
      ['0x3F9a5a0267ce4fF6d84C08Fd5150AcB593E4523C', 22],
      ['0x6CE7BD2E0aA015E412De39285881170EBe06cc92', 14],
      ['0xE9C563ec2701D922816eb7c50e266f88a2480033', 2],
      ['0x7ae299A8358B00316e7541ED89c7C608893D9D8A', 2],
      ['0xb99c38602c12675fbd1708FCbf6FF8D9B658B199', 2],
      ['0x9218dff231590717A4B84b086E3C7b844140Ee7C', 1],
      ['0xD22a3d81C8BE60520A489d55F4E1CC6C3C081935', 1],
    ];

    const phase = 4n;
    let serial = 1000400;
    const card = new Card('0x0000000000000000000000000000000000000000000000000000000000000000');
    const batch = [];
    card.setId(phase);
    for (let i = 0; i < airdrops.length; i += 1) {
      const [address, noBoxes] = airdrops[i];
      const buff = new BytesBuffer();
      for (let j = 1; j <= noBoxes; j += 1) {
        serial += 1;
        console.log(serial);
        card.setSerial(BigInt(serial));
        buff.writeUint256(card.toString());
        batch.push(card.toString());
      }
      const buffInvoked = buff.invoke();
      const proof = await craftProof(salesAgent, migratorProxy);
      console.log('Mint:', address, 'boxes:', noBoxes, buffInvoked.length / 32);
      console.log(buffInvoked.toString('hex'));
      const tx = await migratorProxy
        .connect(signer)
        .safeCall(
          proof,
          '0x57cB34Ac43Aa5b232e46c8b7DFcFe488c80D7259',
          0,
          distributor.interface.encodeFunctionData('batchMigrate', [address as string, true, true, buffInvoked]),
        );
      tx.wait(confirmation);
    }

    fs.writeFileSync(`${__dirname}/result.json`, JSON.stringify(batch));
  },
);

export default {};
