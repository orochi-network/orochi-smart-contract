/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { Signer } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
import { env } from '../env';
// @ts-ignore
import { DuelistKingMerchant } from '../typechain';
import { stringToBytes32 } from '../test/helpers/const';

export async function unlockAddress(hre: HardhatRuntimeEnvironment, address: string): Promise<Signer> {
  await hre.network.provider.request({
    method: 'hardhat_impersonateAccount',
    params: [address],
  });
  return hre.ethers.provider.getSigner(address);
}

task('discount:add', 'Create a campaign on BSC for the first time').setAction(
  async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const privateKey = env.PRIVATE_KEY;
    const deployer = Deployer.getInstance(hre);
    const confirmation = hre.network.name === 'binance' ? 5 : 0;
    const salesAgent =
      hre.network.name === 'binance'
        ? new hre.ethers.Wallet(privateKey, hre.ethers.provider)
        : await unlockAddress(hre, '0x74f453DB88C774357579C7500956069cE348fE24');
    deployer.connect(salesAgent);
    const merchant = <DuelistKingMerchant>(
      await deployer.contractAttach('Duelist King/DuelistKingMerchant', '0x5c113573dB9E56622473BE713DE990ED4f1EfB81')
    );

    const discounts = fs
      .readFileSync(`${__dirname}/discount.csv`)
      .toString()
      .split('\n')
      .map((e) => e.split(','));

    for (let i = 0; i < discounts.length; i += 50) {
      const start = i;
      const end = i + 50 >= discounts.length ? discounts.length : i + 50;
      const chunk = discounts.slice(start, end);
      console.log(
        'Completed:',
        start,
        end,
        chunk,
        chunk.map((e) => stringToBytes32(e[0])),
        chunk.map((e) => e[1]),
      );
      const tx = await merchant.setDiscount(
        chunk.map((e) => stringToBytes32(e[0])),
        chunk.map((e) => e[1]),
      );
      await tx.wait(confirmation);
    }
  },
);

export default {};
