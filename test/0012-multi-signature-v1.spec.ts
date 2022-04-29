import hre from 'hardhat';
import chai, { expect } from 'chai';
import { TestToken, MultiSig, MultiSignatureV1 } from '../typechain';
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
const PERMISSION_OBSERVER = 4294967296;

const uint = '1000000000000000000';

const ROLE_CREATOR = PERMISSION_CREATE;
const ROLE_VOTER = PERMISSION_VOTE;
const ROLE_EXECUTOR = PERMISSION_EXECUTE;
const ROLE_VIEWER = PERMISSION_OBSERVER;
const ROLE_ADMIN = PERMISSION_CREATE | PERMISSION_EXECUTE | PERMISSION_OBSERVER | PERMISSION_VOTE;

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

let accounts: SignerWithAddress[], contractMultiSig: MultiSignatureV1, contractTestToken: TestToken;
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

    await contractTestToken.transfer(contractMultiSig.address, BigNumber.from(10000).mul(uint));

    printAllEvents(
      await contractMultiSig.init(
        [creator, voter, executor, viewer, admin1, admin2, admin3].map((e) => e.address),
        [ROLE_CREATOR, ROLE_VOTER, ROLE_EXECUTOR, ROLE_VIEWER, ROLE_ADMIN, ROLE_ADMIN, ROLE_ADMIN],
        50,
        70,
      ),
    );

    expect((await contractMultiSig.getTotalSigner()).toNumber()).to.eq(4);
  });

  it('init() can not able to be called twice', async () => {
    expect(
      await shouldFailed(async () =>
        contractMultiSig.connect(deployerSigner).init(
          [creator, voter, executor, viewer, admin1, admin2, admin3].map((e) => e.address),
          [ROLE_CREATOR, ROLE_VOTER, ROLE_EXECUTOR, ROLE_VIEWER, ROLE_ADMIN, ROLE_ADMIN, ROLE_ADMIN],
          50,
          70,
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
            BigNumber.from(100).mul(uint),
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
              BigNumber.from(100).mul(uint),
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
              BigNumber.from(100).mul(uint),
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
              BigNumber.from(100).mul(uint),
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
              BigNumber.from(100).mul(uint),
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
    expect((await contractTestToken.balanceOf(accounts[9].address)).div(uint)).to.eq(100);
  });

  it('Creator able to perform quick transfer', async () => {
    const tx = await contractMultiSig.getPackedTransaction(
      contractTestToken.address,
      0,
      contractTestToken.interface.encodeFunctionData('transfer', [accounts[8].address, BigNumber.from(100).mul(uint)]),
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
    expect((await contractTestToken.balanceOf(accounts[8].address)).div(uint)).to.eq(100);
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
