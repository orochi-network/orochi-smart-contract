/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
// import { ethers } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import initInfrastructure, { IConfiguration } from '../test/helpers/deployer-infrastructure';
import initDuelistKing from '../test/helpers/deployer-duelist-king';
import { DuelistKingMerchant, TestToken } from '../typechain';
import { stringToBytes32 } from '../test/helpers/functions';

/*
import { env } from '../env';
function getWallet(mnemonic: string, index: number): ethers.Wallet {
  return ethers.Wallet.fromMnemonic(mnemonic, `m/44'/60'/0'/0/${index}`);
}
*/

async function getConfig(hre: HardhatRuntimeEnvironment): Promise<IConfiguration> {
  const accounts = await hre.ethers.getSigners();
  if (hre.network.name === 'binance') {
    return {
      network: hre.network.name,
      deployerSigner: accounts[0],
      migratorAddresses: ['0x74f453DB88C774357579C7500956069cE348fE24'],
      salesAgentAddress: '0x74f453DB88C774357579C7500956069cE348fE24',
      infrastructure: {
        operatorAddress: '0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4',
        oracleAddresses: ['0x74f453DB88C774357579C7500956069cE348fE24'],
      },
      duelistKing: {
        operatorAddress: '0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4',
        oracleAddresses: ['0x74f453DB88C774357579C7500956069cE348fE24'],
      },
    };
  }
  if (hre.network.name === 'testnet') {
    return {
      network: hre.network.name,
      deployerSigner: accounts[0],
      migratorAddresses: [accounts[9].address],
      salesAgentAddress: accounts[0].address,
      infrastructure: {
        operatorAddress: accounts[0].address,
        oracleAddresses: [accounts[9].address],
      },
      duelistKing: {
        operatorAddress: accounts[0].address,
        oracleAddresses: [accounts[9].address],
      },
    };
  }
  return {
    network: hre.network.name,
    deployerSigner: accounts[0],
    salesAgentAddress: '0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4',
    migratorAddresses: ['0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4'],
    infrastructure: {
      operatorAddress: accounts[0].address,
      oracleAddresses: ['0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4'],
    },
    duelistKing: {
      operatorAddress: accounts[0].address,
      oracleAddresses: ['0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4'],
    },
  };
}

task('deploy', 'Deploy all smart contracts')
  // .addParam('account', "The account's address")
  .setAction(async (_taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const {
      deployer,
      config: {
        migratorAddresses,
        salesAgentAddress,
        infrastructure: { operatorAddress, oracleAddresses },
        duelistKing,
      },
    } = await initDuelistKing(await initInfrastructure(hre, await getConfig(hre)));
    if (hre.network.name === 'testnet') {
      const accounts = await hre.ethers.getSigners();
      <TestToken>await deployer.connect(accounts[0]).contractDeploy('Test/TestToken', []);
    }
    if (hre.network.name === 'local') {
      const accounts = await hre.ethers.getSigners();
      const contractTestToken = <TestToken>await deployer.connect(accounts[0]).contractDeploy('Test/TestToken', []);
      await contractTestToken.connect(accounts[0]).transfer(accounts[5].address, '500000000000000000000');
      await contractTestToken.connect(accounts[0]).transfer(accounts[5].address, '10000000000000000000');
      await contractTestToken.connect(accounts[0]).transfer(accounts[5].address, '5000000000000000000');
      console.log('Watching address:         ', accounts[5].address);
    }
    deployer.printReport();
    console.log('Sales Agent:  ', salesAgentAddress);
    console.log('Migrator:  ', migratorAddresses.join(','));
    console.log('Infrastructure Operator:  ', operatorAddress);
    console.log('Infrastructure Oracles:   ', oracleAddresses.join(','));
    console.log('Duelist King Operator:    ', duelistKing.operatorAddress);
    console.log('Duelist King Oracles:     ', duelistKing.oracleAddresses.join(','));
  });

task('createCampaign')
  .addParam('merchant', 'Merchant contract address')
  .setAction(async (taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const merchantAddress = (taskArgs.merchant || '').trim();
    console.log(hre.network.name);

    const accounts = await hre.ethers.getSigners();
    console.log(hre.ethers.utils.isAddress(merchantAddress));
    if (hre.ethers.utils.isAddress(merchantAddress)) {
      try {
        const merchant = <DuelistKingMerchant>(
          await hre.ethers.getContractAt('DuelistKingMerchant', merchantAddress, accounts[0])
        );

        await merchant.connect(accounts[0]).createNewCampaign({
          phaseId: 4,
          basePrice: 5000000,
          deadline: '1655001032',
          totalSale: 30000,
        });
        console.log('Done');
        return;
      } catch (error) {
        console.log(error);
      }
    }
    throw new Error('File not found or invalid creator address');
  });

task('merchantAddStableCoin')
  .addParam('merchant', 'Merchant contract address')
  .addParam('token', 'StableCoin address')
  .setAction(async (taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const merchantAddress = (taskArgs.merchant || '').trim();
    const stableCoinAddress = (taskArgs.token || '').trim();
    console.log(hre.network.name);

    const accounts = await hre.ethers.getSigners();
    if (hre.ethers.utils.isAddress(merchantAddress) && hre.ethers.utils.isAddress(stableCoinAddress)) {
      try {
        const merchant = <DuelistKingMerchant>(
          await hre.ethers.getContractAt('DuelistKingMerchant', merchantAddress, accounts[0])
        );

        await merchant.connect(accounts[0]).manageStablecoin(stableCoinAddress, 18, true);
        return console.log('Done');
      } catch (error) {
        console.log(error);
      }
    }
    throw new Error('File not found or invalid creator address');
  });

task('merchantAddDiscountCode')
  .addParam('merchant', 'Merchant contract address')
  .addParam('code', 'Discount code in string, separated by comma')
  .addParam('rate', 'Discount percent, separated by comma: eg. 10% 10% = 10,10')
  .setAction(async (taskArgs: any, hre: HardhatRuntimeEnvironment) => {
    const accounts = await hre.ethers.getSigners();
    const merchantAddress = (taskArgs.merchant || '').trim();
    const code = (taskArgs.code || '').trim();
    const rate = (taskArgs.rate || '').trim();
    const codeArray = code.split(',').map((item: string) => {
      const codeBytes32 = item.trim();
      return stringToBytes32(codeBytes32);
    });
    const rateArray = rate.split(',').map((item: string) => {
      const rateDiscount = parseInt(item.trim(), 10) * 10000;
      if (rateDiscount > 10 ** 6) {
        throw new Error('Invalid discount rate');
      }
      return rateDiscount.toString();
    });
    console.log(codeArray);
    console.log(rateArray);
    if (codeArray.length !== rateArray.length) {
      throw new Error('code and rate must be the same length');
    }

    if (hre.ethers.utils.isAddress(merchantAddress)) {
      try {
        const merchant = <DuelistKingMerchant>(
          await hre.ethers.getContractAt('DuelistKingMerchant', merchantAddress, accounts[0])
        );

        await merchant.connect(accounts[0]).setDiscount(codeArray, rateArray);
        return console.log('Done');
      } catch (error) {
        return console.log(error);
      }
    }
    throw new Error('Invalid merchant address');
  });

export default {};
