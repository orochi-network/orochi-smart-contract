/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import { Signer } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
// @ts-ignore
import { DuelistKingMerchant, DuelistKingToken } from '../typechain';

export async function unlockAddress(hre: HardhatRuntimeEnvironment, address: string): Promise<Signer> {
  await hre.network.provider.request({
    method: 'hardhat_impersonateAccount',
    params: [address],
  });
  return hre.ethers.provider.getSigner(address);
}

task('merchant:test', 'Create a campaign on BSC for the first time').setAction(
  async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const deployer = Deployer.getInstance(hre);
    const tokenOwner = await unlockAddress(hre, '0x25FBabC27be0dFFd966b73019c0FB962200d8cB2');
    const operator = await unlockAddress(hre, '0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4');
    deployer.connect(tokenOwner);
    const token = <DuelistKingToken>(
      await deployer.contractAttach('Duelist King/DuelistKingToken', '0x55d398326f99059fF775485246999027B3197955')
    );
    deployer.connect(operator);
    const merchant = <DuelistKingMerchant>(
      await deployer.contractAttach('Duelist King/DuelistKingMerchant', '0x5c113573dB9E56622473BE713DE990ED4f1EfB81')
    );
    const balance = await token.balanceOf(await tokenOwner.getAddress());
    console.log('Owner has:', balance.div('1000000000000000000').toNumber());
    await token.transfer(merchant.address, balance);
    const contractBalance = await token.balanceOf(merchant.address);
    console.log('Contract has:', contractBalance.div('1000000000000000000').toNumber());
    console.log(await merchant.signer.getAddress());
    await merchant.withdraw(await tokenOwner.getAddress(), '0x55d398326f99059fF775485246999027B3197955');
    const balanceFinal = await token.balanceOf(await tokenOwner.getAddress());
    console.log(balanceFinal.div('1000000000000000000').toNumber());
    console.log(await merchant.getCampaignDetail(0));
    await token.approve(merchant.address, '0xffffffffffffffffffffffffffffffffffffffff');
    const tx = await merchant
      .connect(tokenOwner)
      .buy(0, 5, '0x55d398326f99059fF775485246999027B3197955', Buffer.alloc(32));
    await tx.wait();
  },
);

export default {};
