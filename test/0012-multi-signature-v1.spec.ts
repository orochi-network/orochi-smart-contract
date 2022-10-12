import hre from 'hardhat';
import chai, { expect } from 'chai';
import { TestToken, MultiSignatureV1, MultiSignatureMaster } from '../typechain';
import { utils, BigNumber, ethers } from 'ethers';
import { solidity } from 'ethereum-waffle';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import Deployer from './helpers/deployer';
import BytesBuffer from './helpers/bytes';
import { dayToSec, printAllEvents } from './helpers/functions';

chai.use(solidity);

// Create a new proposal and do qick transfer
const PERMISSION_CREATE = 1;
// Allowed to sign quick transfer message and vote a proposal
const PERMISSION_VOTE = 2;
// Permission to execute the proposal
const PERMISSION_EXECUTE = 4;
// View permission only
const PERMISSION_OBSERVER = '0x100000000';

const unit = '1000000000000000000';

const ROLE_CREATOR = `0x10000000${PERMISSION_CREATE}`;
const ROLE_VOTER = `0x10000000${PERMISSION_VOTE}`;
const ROLE_EXECUTOR = `0x10000000${PERMISSION_EXECUTE}`;
const ROLE_VIEWER = PERMISSION_OBSERVER;
const ROLE_ADMIN = `0x10000000${PERMISSION_CREATE | PERMISSION_EXECUTE | PERMISSION_VOTE}`;

async function timeTravel(secs: number) {
  await hre.network.provider.request({
    method: 'evm_increaseTime',
    params: [secs],
  });
}

async function shouldFailed(asyncFunction: () => Promise<any>): Promise<boolean> {
  let error = false;
  try {
    await asyncFunction();
    let error = false;
  } catch (e) {
    console.log((e as Error).message);
    error = true;
  }
  return error;
}

let accounts: SignerWithAddress[],
  contractMultiSig: MultiSignatureV1,
  cloneMultiSig: MultiSignatureV1,
  contractTestToken: TestToken,
  contractMultiSigMaster: MultiSignatureMaster;
let deployerSigner: SignerWithAddress,
  creator: SignerWithAddress,
  voter: SignerWithAddress,
  executor: SignerWithAddress,
  viewer: SignerWithAddress,
  admin1: SignerWithAddress,
  admin2: SignerWithAddress,
  admin3: SignerWithAddress;

describe('MultiSignatureV1', function () {
  it('MultiSignature must be deployed correctly', async () => {
    accounts = await hre.ethers.getSigners();
    [deployerSigner, creator, voter, executor, viewer, admin1, admin2, admin3] = accounts;
    const deployer: Deployer = Deployer.getInstance(hre);
    deployer.connect(deployerSigner);
    contractTestToken = <TestToken>await deployer.contractDeploy('test/TestToken', []);
    contractMultiSig = <MultiSignatureV1>await deployer.contractDeploy('test/MultiSignatureV1', []);

    await contractTestToken.transfer(contractMultiSig.address, BigNumber.from(10000).mul(unit));

    printAllEvents(
      await contractMultiSig.init(
        [creator, voter, executor, viewer, admin1, admin2, admin3].map((e) => e.address),
        [ROLE_CREATOR, ROLE_VOTER, ROLE_EXECUTOR, ROLE_VIEWER, ROLE_ADMIN, ROLE_ADMIN, ROLE_ADMIN],
        2,
        3,
      ),
    );

    expect((await contractMultiSig.getTotalSigner()).toNumber()).to.eq(4);
  });

  it('should able to deploy multisig master correctly', async () => {
    const deployer: Deployer = Deployer.getInstance(hre);
    contractMultiSigMaster = <MultiSignatureMaster>(
      await deployer.contractDeploy(
        'test/MultiSignatureMaster',
        [],
        [deployerSigner.address, deployerSigner.address],
        [1, 2],
        contractMultiSig.address,
        0,
      )
    );
  });

  it('anyone could able to create new signature from multi signature master', async () => {
    const deployer: Deployer = Deployer.getInstance(hre);
    printAllEvents(
      await contractMultiSigMaster.createWallet(1, [admin1.address, admin2.address], [ROLE_ADMIN, ROLE_ADMIN], 1, 2),
    );

    cloneMultiSig = <MultiSignatureV1>(
      await deployer.contractAttach(
        'test/MultiSignatureV1',
        await contractMultiSigMaster.predictWalletAddress(deployerSigner.address, 1),
      )
    );
  });

  it('admin should able to perform quick transfer with ', async () => {
    await deployerSigner.sendTransaction({
      to: cloneMultiSig.address,
      value: BigNumber.from(5).mul(unit),
    });
    const beforeValue = await admin1.getBalance();
    const tx = await contractMultiSig.getPackedTransaction(admin1.address, BigNumber.from(1).mul(unit), '0x');
    printAllEvents(
      await cloneMultiSig
        .connect(admin2)
        .quickTransfer(
          [await admin1.signMessage(utils.arrayify(tx)), await admin2.signMessage(utils.arrayify(tx))],
          tx,
        ),
    );
    const afterBalance = await admin1.getBalance();
    expect(afterBalance.sub(beforeValue).div(unit)).to.eq(1);
  });

  it('init() can not able to be called twice', async () => {
    expect(
      await shouldFailed(async () =>
        contractMultiSig.connect(deployerSigner).init(
          [creator, voter, executor, viewer, admin1, admin2, admin3].map((e) => e.address),
          [ROLE_CREATOR, ROLE_VOTER, ROLE_EXECUTOR, ROLE_VIEWER, ROLE_ADMIN, ROLE_ADMIN, ROLE_ADMIN],
          2,
          3,
        ),
      ),
    ).to.eq(true);
  });

  it('Creator should able to create new proposal', async () => {
    printAllEvents(
      await contractMultiSig
        .connect(creator)
        .createProposal(
          contractTestToken.address,
          0,
          0,
          contractTestToken.interface.encodeFunctionData('transfer', [
            accounts[9].address,
            BigNumber.from(100).mul(unit),
          ]),
        ),
    );
  });

  it('Unwanted accounts should not able to create new proposal', async () => {
    expect(
      await shouldFailed(async () =>
        contractMultiSig
          .connect(voter)
          .createProposal(
            contractTestToken.address,
            0,
            0,
            contractTestToken.interface.encodeFunctionData('transfer', [
              accounts[9].address,
              BigNumber.from(100).mul(unit),
            ]),
          ),
      ),
    ).to.eq(true);
    expect(
      await shouldFailed(async () =>
        contractMultiSig
          .connect(viewer)
          .createProposal(
            contractTestToken.address,
            0,
            0,
            contractTestToken.interface.encodeFunctionData('transfer', [
              accounts[9].address,
              BigNumber.from(100).mul(unit),
            ]),
          ),
      ),
    ).to.eq(true);
    expect(
      await shouldFailed(async () =>
        contractMultiSig
          .connect(executor)
          .createProposal(
            contractTestToken.address,
            0,
            0,
            contractTestToken.interface.encodeFunctionData('transfer', [
              accounts[9].address,
              BigNumber.from(100).mul(unit),
            ]),
          ),
      ),
    ).to.eq(true);
    expect(
      await shouldFailed(async () =>
        contractMultiSig
          .connect(accounts[9])
          .createProposal(
            contractTestToken.address,
            0,
            0,
            contractTestToken.interface.encodeFunctionData('transfer', [
              accounts[9].address,
              BigNumber.from(100).mul(unit),
            ]),
          ),
      ),
    ).to.eq(true);
  });

  it('Unwanted accounts should not able to vote', async () => {
    expect(await shouldFailed(async () => contractMultiSig.connect(creator).votePositive(0))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(viewer).votePositive(0))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(executor).votePositive(0))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(accounts[9]).votePositive(0))).to.eq(true);
  });

  it('Unwanted accounts should not able to quick transfer', async () => {
    expect(await shouldFailed(async () => contractMultiSig.connect(viewer).quickTransfer([], '0x'))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(executor).quickTransfer([], '0x'))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(voter).quickTransfer([], '0x'))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(accounts[9]).votePositive(0))).to.eq(true);
  });

  it('Unwanted accounts should not able to exec the proposal', async () => {
    expect(await shouldFailed(async () => contractMultiSig.connect(viewer).execute(0))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(creator).execute(0))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(voter).execute(0))).to.eq(true);
    expect(await shouldFailed(async () => contractMultiSig.connect(accounts[9]).execute(0))).to.eq(true);
  });

  it('Proposal should be voted and executed normally', async () => {
    await contractMultiSig.connect(voter).votePositive(0);
    await contractMultiSig.connect(admin1).votePositive(0);
    await timeTravel(dayToSec(2));
    await contractMultiSig.connect(admin2).execute(0);
    expect((await contractTestToken.balanceOf(accounts[9].address)).div(unit)).to.eq(100);
  });

  it('Creator able to perform quick transfer', async () => {
    const tx = await contractMultiSig.getPackedTransaction(
      contractTestToken.address,
      0,
      contractTestToken.interface.encodeFunctionData('transfer', [accounts[8].address, BigNumber.from(100).mul(unit)]),
    );
    await timeTravel(120);
    printAllEvents(
      await contractMultiSig
        .connect(creator)
        .quickTransfer(
          [
            await voter.signMessage(utils.arrayify(tx)),
            await admin1.signMessage(utils.arrayify(tx)),
            await admin2.signMessage(utils.arrayify(tx)),
          ],
          tx,
        ),
    );
    expect((await contractTestToken.balanceOf(accounts[8].address)).div(unit)).to.eq(100);
  });

  it('Creator able to perform quick transfer native token', async () => {
    const balanceBefore = await hre.ethers.provider.getBalance(accounts[7].address);
    await accounts[0].sendTransaction({
      to: contractMultiSig.address,
      value: 100,
    });
    expect((await hre.ethers.provider.getBalance(contractMultiSig.address)).toNumber()).to.eq(100);
    const tx = await contractMultiSig.getPackedTransaction(accounts[7].address, 100, '0x');
    printAllEvents(
      await contractMultiSig
        .connect(creator)
        .quickTransfer(
          [
            await voter.signMessage(utils.arrayify(tx)),
            await admin1.signMessage(utils.arrayify(tx)),
            await admin2.signMessage(utils.arrayify(tx)),
          ],
          tx,
        ),
    );
    expect((await hre.ethers.provider.getBalance(accounts[7].address)).sub(balanceBefore).toNumber()).to.eq(100);
    expect((await hre.ethers.provider.getBalance(contractMultiSig.address)).toNumber()).to.eq(0);
  });
});
