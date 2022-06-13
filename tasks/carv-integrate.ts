/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { Signer } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
import { env } from '../env';
import abiIno from '../abi/ino.json';
// @ts-ignore
import { NFT } from '../typechain';

export async function unlockAddress(hre: HardhatRuntimeEnvironment, address: string): Promise<Signer> {
  await hre.network.provider.request({
    method: 'hardhat_impersonateAccount',
    params: [address],
  });
  return hre.ethers.provider.getSigner(address);
}

task('carv:integrate', 'Integrate with carv').setAction(async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
  const privateKey = env.PRIVATE_KEY;
  const deployer = Deployer.getInstance(hre);
  const confirmation = hre.network.name === 'binance' ? 5 : 0;
  const salesAgent =
    hre.network.name === 'binance'
      ? new hre.ethers.Wallet(privateKey, hre.ethers.provider)
      : await unlockAddress(hre, '0x74f453DB88C774357579C7500956069cE348fE24');
  deployer.connect(salesAgent);
  const nft = <NFT>await deployer.contractAttach('Duelist King/NFT', '0xe2f0c8f0F80D3a1f0a66Eb3ab229c4f63CCd11d0');

  const ino = new hre.ethers.Contract('0xc90eC63988B7fC61038fAec3F85B6672c0e40445', abiIno, salesAgent);

  const tx1 = await nft.setApprovalForAll('0xc90eC63988B7fC61038fAec3F85B6672c0e40445', true);
  await tx1.wait(5);
  const data = JSON.parse(fs.readFileSync(`${__dirname}/result.json`).toString());
  for (let i = 0; i < data.length; i += 50) {
    const start = i;
    const end = start + 50 > data.length ? data.length : start + 50;
    console.log('Processing: ', start, end);
    const tx = await ino.addOfferBatch(data.slice(start, end));
    await tx.wait(confirmation);
  }
});

export default {};
