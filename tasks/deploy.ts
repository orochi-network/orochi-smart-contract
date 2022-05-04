/* eslint-disable no-await-in-loop */
import '@nomiclabs/hardhat-ethers';
// import { ethers } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import initInfrastructure, { IConfiguration } from '../test/helpers/deployer-infrastructure';
import initDuelistKing from '../test/helpers/deployer-duelist-king';
import { TestToken } from '../typechain';

/*
import { env } from '../env';
function getWallet(mnemonic: string, index: number): ethers.Wallet {
  return ethers.Wallet.fromMnemonic(mnemonic, `m/44'/60'/0'/0/${index}`);
}
*/

async function getConfig(hre: HardhatRuntimeEnvironment): Promise<IConfiguration> {
  const accounts = await hre.ethers.getSigners();
  /*
  if (hre.network.name === 'binance') {
    return {
      network: hre.network.name,
      deployerSigner: getWallet(env.DUELIST_KING_DEPLOY_MNEMONIC, 0),
      salesAgentAddress: '?',
      infrastructure: {
        operatorAddress: '0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4',
        oracleAddresses: ['?'],
      },
      duelistKing: {
        operatorAddress: '0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4',
        oracleAddresses: ['?'],
      },
    };
  }
  */
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

export default {};
