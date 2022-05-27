/* eslint-disable global-require */
import { opendirSync } from 'fs';
import { HardhatUserConfig } from 'hardhat/types';
import { env } from './env';
import 'hardhat-typechain';
import '@nomiclabs/hardhat-ethers';
import 'hardhat-gas-reporter';
import 'solidity-coverage';

if (env.DUELIST_KING_DEPLOY_MNEMONIC !== 'baby nose young alone sport inside grain rather undo donor void exotic') {
  const dir = opendirSync(`${__dirname}/tasks`);
  for (let entry = dir.readSync(); entry !== null; entry = dir.readSync()) {
    // eslint-disable-next-line import/no-dynamic-require
    require(`./tasks/${entry.name.replace(/\.ts$/gi, '')}`);
  }
}

const compilers = ['0.8.7'].map((item: string) => ({
  version: item,
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
}));

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  networks: {
    polygon: {
      url: env.DUELIST_KING_RPC,
      chainId: 137,
      accounts: {
        mnemonic: env.DUELIST_KING_DEPLOY_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
    },
    fantom: {
      url: env.DUELIST_KING_RPC,
      chainId: 250,
      accounts: {
        mnemonic: env.DUELIST_KING_DEPLOY_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
    },
    binance: {
      url: env.DUELIST_KING_RPC,
      chainId: 56,
      accounts: {
        mnemonic: env.DUELIST_KING_DEPLOY_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
    },
    testnet: {
      url: env.DUELIST_KING_RPC,
      // Fantom testnet
      chainId: 0xfa2,
      accounts: {
        mnemonic: env.DUELIST_KING_DEPLOY_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
    },
    local: {
      url: 'http://localhost:8545/',
      chainId: 911,
      accounts: {
        mnemonic: env.DUELIST_KING_DEPLOY_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
    },
    // Hard hat network
    hardhat: {
      chainId: 911,
      hardfork: 'london',
      blockGasLimit: 30000000,
      initialBaseFeePerGas: 0,
      gas: 25000000,
      accounts: {
        mnemonic: env.DUELIST_KING_DEPLOY_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
      forking: env.DUELIST_KING_FORK
        ? {
            url: env.DUELIST_KING_RPC,
            enabled: true,
          }
        : undefined,
    },
  },
  solidity: {
    compilers,
  },
};

export default config;
