import { Signer } from 'ethers';
import Deployer from './deployer';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { registryRecords } from './const';

export interface IOperators {
  operatorAddress: string;
  oracleAddresses: string[];
}

export interface IConfiguration {
  network: string;
  deployerSigner: Signer;
  migratorAddresses: string[];
  salesAgentAddress: string;
  infrastructure: IOperators;
  duelistKing: IOperators;
}

async function getAddresses(singers: Signer[]): Promise<string[]> {
  const tmp = [];
  for (let i = 0; i < singers.length; i++) {
    tmp[i] = await singers[i].getAddress();
  }
  return tmp;
}

export default async function init(
  hre: HardhatRuntimeEnvironment,
  config: IConfiguration,
): Promise<{ deployer: Deployer; config: IConfiguration }> {
  const deployer = Deployer.getInstance(hre);
  // Connect to infrastructure operator
  deployer.connect(config.deployerSigner);

  // Deploy registry
  const registry = await deployer.contractDeploy('Infrastructure/Registry', []);

  // Deploy oracle proxy
  await deployer.contractDeploy(
    'Infrastructure/OracleProxy',
    [],
    registry.address,
    registryRecords.domain.infrastructure,
  );

  // Deploy RNG
  await deployer.contractDeploy('Infrastructure/RNG', [], registry.address, registryRecords.domain.infrastructure);

  return {
    deployer,
    config,
  };
}
