/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
import { BigNumber, Signer } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import Deployer from '../test/helpers/deployer';
// @ts-ignore
import { DuelistKingToken, MultiSignatureV1 } from '../typechain';

export async function unlockAddress(hre: HardhatRuntimeEnvironment, address: string): Promise<Signer> {
  await hre.network.provider.request({
    method: 'hardhat_impersonateAccount',
    params: [address],
  });
  return hre.ethers.provider.getSigner(address);
}

export async function setBalance(hre: HardhatRuntimeEnvironment, address: string, balance: BigNumber): Promise<void> {
  await hre.network.provider.request({
    method: 'hardhat_setBalance',
    params: [address, balance.toHexString().replace('0x0', '0x')],
  });
}

task('multisig:test', 'Test multi-signature v1').setAction(async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
  const deployer = Deployer.getInstance(hre);
  const tokenOwner = await unlockAddress(hre, '0x25FBabC27be0dFFd966b73019c0FB962200d8cB2');
  const operator1 = await unlockAddress(hre, '0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4');
  const operator2 = await unlockAddress(hre, '0x90EBFC3D7FeeB282cd3b9b4296754bacba8ab75a');
  const operator3 = await unlockAddress(hre, '0xea01844207ebf56C87E1F6f4173d65fb662B15ba');
  const operator4 = await unlockAddress(hre, '0xeE4fe9347a7902253a515CC76EaA3253b47a1837');
  const operators = [operator1, operator2, operator3, operator4];
  for (let i = 0; i < operators.length; i += 1) {
    await setBalance(hre, await operators[i].getAddress(), BigNumber.from('100000000000000000000'));
  }
  deployer.connect(tokenOwner);
  const token = <DuelistKingToken>(
    await deployer.contractAttach('Duelist King/DuelistKingToken', '0x55d398326f99059fF775485246999027B3197955')
  );
  const multisig = <MultiSignatureV1>(
    await deployer.contractAttach('Duelist King/MultiSignatureV1', '0x712A8DeF765dE7B4566604B02b4B81996c4849F7')
  );
  const balance = await token.balanceOf(await tokenOwner.getAddress());
  console.log('Owner has:', balance.div('1000000000000000000').toNumber());
  await token.transfer(multisig.address, balance);
  const contractBalance = await token.balanceOf(multisig.address);
  console.log('Contract has:', contractBalance.div('1000000000000000000').toNumber());
  await multisig
    .connect(operator1)
    .createProposal(
      '0x55d398326f99059fF775485246999027B3197955',
      0,
      0,
      token.interface.encodeFunctionData('transfer', [await tokenOwner.getAddress(), contractBalance]),
    );
  for (let i = 0; i < operators.length - 1; i += 1) {
    await await multisig.connect(operators[i]).votePositive(0);
  }
  await multisig.connect(operator4).execute(0);
  const balanceFinal = await token.balanceOf(await tokenOwner.getAddress());
  console.log('Token owner final balance:', balanceFinal.div('1000000000000000000').toNumber());
});

export default {};
