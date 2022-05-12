/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import { Signer } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
import { printAllEvents } from '../test/helpers/functions';
import { env } from '../env';
// @ts-ignore
import { DuelistKingMerchant } from '../typechain';

export async function unlockAddress(hre: HardhatRuntimeEnvironment, address: string): Promise<Signer> {
  await hre.network.provider.request({
    method: 'hardhat_impersonateAccount',
    params: [address],
  });
  return hre.ethers.provider.getSigner(address);
}

const tokens = [
  {
    blockchain: 'binance',
    name: 'Binance-Peg BSC-USD',
    address: '0x55d398326f99059fF775485246999027B3197955',
    symbol: 'USDT',
    decimal: 18,
  },
  {
    blockchain: 'binance',
    name: 'Binance-Peg Dai Token (DAI)',
    address: '0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3',
    symbol: 'DAI',
    decimal: 18,
  },
  {
    blockchain: 'binance',
    name: 'Binance-Peg USD Coin (USDC)',
    address: '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
    symbol: 'USDC',
    decimal: 18,
  },
  {
    blockchain: 'binance',
    name: 'Binance-Peg BUSD Token (BUSD)',
    address: '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56',
    symbol: 'BUSD',
    decimal: 18,
  },
];

task('campaign:create', 'Create a campaign on BSC for the first time').setAction(
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
      await deployer.contractAttach('Duelist King/DuelistKingMerchant', '0xe0D0FdfF80AE5D9219422E60790545B61F7F5c52')
    );
    // Add support stablecoin
    for (let i = 0; i < tokens.length; i += 1) {
      const { address, decimal, symbol } = tokens[i];
      const tx = await merchant.manageStablecoin(address, decimal, true);
      console.log('Add stablecoin: ', address, symbol);
      await printAllEvents(tx);
      await tx.wait(confirmation);
    }
    // Create a new campaign

    const tx = await merchant.createNewCampaign({
      phaseId: 4,
      totalSale: 20000,
      // Deadline is 30 days
      deadline: (await hre.ethers.provider.getBlock('latest')).timestamp + 2592000,
      basePrice: 5000000,
    });
    await printAllEvents(tx);
    await tx.wait(confirmation);
    const { phaseId, totalSale, basePrice, deadline } = await merchant.getCampaignDetail(0);
    console.table({
      'Phase Id': phaseId.toNumber(),
      'Total Sale': totalSale.toNumber(),
      'Base price': basePrice.toNumber() / 1000000,
      'Campaign Deadline': `${new Date(deadline.toNumber() * 1000).toISOString()} (end in ${Math.round(
        Math.ceil(deadline.toNumber() - Date.now() / 1000) / (24 * 60 * 60),
      )} days)`,
    });
  },
);

export default {};
