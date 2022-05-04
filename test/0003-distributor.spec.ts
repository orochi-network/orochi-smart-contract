import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { BigNumber, utils } from 'ethers';
import hre from 'hardhat';
import { DuelistKingToken, TestToken } from '../typechain';
import BytesBuffer from './helpers/bytes';
import Card from './helpers/card';
import { emptyBytes32, maxUint256, stringToBytes32, uint, zeroAddress } from './helpers/const';
import initDuelistKing, { IDeployContext } from './helpers/deployer-duelist-king';
import initInfrastructure from './helpers/deployer-infrastructure';
import { craftProof, dayToSec, getCurrentBlockTimestamp, printAllEvents } from './helpers/functions';

let context: IDeployContext;
let accounts: SignerWithAddress[];
let boxes: string[] = [];
let cards: string[] = [];
let token: DuelistKingToken;

describe('DuelistKingDistributor', function () {
  this.beforeAll('all initialized should be correct', async () => {
    accounts = await hre.ethers.getSigners();
    context = await initDuelistKing(
      await initInfrastructure(hre, {
        network: hre.network.name,
        deployerSigner: accounts[0],
        migratorAddresses: [accounts[1].address],
        salesAgentAddress: accounts[9].address,
        infrastructure: {
          operatorAddress: accounts[0].address,
          oracleAddresses: [accounts[1].address],
        },
        duelistKing: {
          operatorAddress: accounts[2].address,
          oracleAddresses: [accounts[3].address],
        },
      }),
    );
  });

  it('Should be failed when creating a new campaign because invalid Sales Agent', async function () {
    const {
      duelistKing: { merchant },
    } = context;
    const timestamp = await getCurrentBlockTimestamp(hre);
    const config = {
      phaseId: 1,
      totalSale: 20000,
      deadline: Math.round(timestamp + dayToSec(30)),
      // It is $5
      basePrice: 5000000,
    };
    await expect(merchant.connect(accounts[1]).createNewCampaign(config)).to.be.revertedWith(
      'UserRegistry: Only allow call from same domain',
    );
    await expect(merchant.connect(accounts[2]).createNewCampaign(config)).to.be.revertedWith(
      'UserRegistry: Only allow call from same domain',
    );
  });

  it('Sales Agents must able to create new campaign', async () => {
    const {
      duelistKing: { merchant },
      deployer,
    } = context;
    // Deploy token to buy boxes
    token = <DuelistKingToken>await deployer.contractDeploy('test1/DuelistKingToken', [], accounts[0].address);

    // Transfer token to buyer
    await token.connect(accounts[0]).transfer(accounts[4].address, BigNumber.from(10000).mul(uint));

    // Create campaign for phase 1
    const timestamp = await getCurrentBlockTimestamp(hre);

    printAllEvents(
      await merchant.connect(accounts[9]).createNewCampaign({
        phaseId: 1,
        totalSale: 20000,
        deadline: Math.round(timestamp + dayToSec(30)),
        // It is $5
        basePrice: 5000000,
      }),
    );

    // Create campaign for phase 20
    printAllEvents(
      await merchant.connect(accounts[9]).createNewCampaign({
        phaseId: 20,
        totalSale: 20000,
        deadline: Math.round(timestamp + dayToSec(30)),
        // It is $5
        basePrice: 5000000,
      }),
    );

    printAllEvents(await merchant.connect(accounts[9]).manageStablecoin(token.address, 18, true));
  });

  it('Should NOT be able to buy box with trash token', async () => {
    const {
      duelistKing: { merchant },
      deployer,
    } = context;
    const trashToken = <TestToken>await deployer.connect(accounts[0]).contractDeploy('test1/TestToken', []);
    await trashToken.connect(accounts[0]).transfer(accounts[4].address, BigNumber.from(10000).mul(uint));
    await trashToken.connect(accounts[4]).approve(merchant.address, maxUint256);
    await expect(merchant.connect(accounts[4]).buy(1, 50, trashToken.address, emptyBytes32)).to.be.revertedWith(
      'ME:Stablecoin was not supported',
    );
  });

  it('Anyone would able to buy box from DuelistKingMerchant', async () => {
    const {
      duelistKing: { merchant, item },
    } = context;
    // Approve token transfer
    await token.connect(accounts[4]).approve(merchant.address, maxUint256);
    const txResult = await (await merchant.connect(accounts[4]).buy(0, 50, token.address, emptyBytes32)).wait();

    console.log(
      txResult.logs
        .filter((e) => e.topics[0] === utils.id('Transfer(address,address,uint256)') && e.address === item.address)
        .map((e) => item.interface.decodeEventLog('Transfer', e.data, e.topics))
        .map((e) => {
          const { from, to, tokenId } = e;
          const nftTokenId = BigNumber.from(tokenId).toHexString();
          if (from === zeroAddress) boxes.push(nftTokenId);
          return `Transfer(${[from, to, nftTokenId].join(', ')})`;
        })
        .join('\n'),
      `\n${txResult.gasUsed.toString()} Gas`,
    );
  });

  it('owner should able to open their boxes', async () => {
    const {
      duelistKing: { distributor, item },
    } = context;
    const packedTokenId = BytesBuffer.newInstance();
    for (let i = 0; i < boxes.length; i += 1) {
      packedTokenId.writeUint256(boxes[i]);
    }

    const txResult = await (await distributor.connect(accounts[4]).openBoxes(packedTokenId.invoke())).wait();
    console.log(
      txResult.logs
        .filter((e) => e.topics[0] === utils.id('Transfer(address,address,uint256)'))
        .map((e) => {
          return item.interface.decodeEventLog('Transfer', e.data, e.topics);
        })
        .map((e) => {
          const { from, to, tokenId } = e;
          const nftTokenId = BigNumber.from(tokenId).toHexString();
          if (from !== zeroAddress) {
            boxes.pop();
          }
          return `Transfer(${[from, to, nftTokenId].join(', ')})`;
        })
        .join('\n'),
      `\n${txResult.gasUsed.toString()} Gas`,
    );
  });

  it('Owner should be able to buy phase 20 (campaignId = 1) with 50 boxes from DuelistKingDistributor', async () => {
    const {
      duelistKing: { merchant, item },
    } = context;
    const txResult = await (await merchant.connect(accounts[4]).buy(1, 50, token.address, emptyBytes32)).wait();

    console.log(
      txResult.logs
        .filter((e) => e.topics[0] === utils.id('Transfer(address,address,uint256)') && e.address === item.address)
        .map((e) => item.interface.decodeEventLog('Transfer', e.data, e.topics))
        .map((e) => {
          const { from, to, tokenId } = e;
          if (from === zeroAddress) boxes.push(BigNumber.from(tokenId).toHexString());
          return `Transfer(${[from, to, BigNumber.from(tokenId).toHexString()].join(', ')})`;
        })
        .join('\n'),
      `\n${txResult.gasUsed.toString()} Gas`,
    );
  });

  it('owner should able to open their boxes', async () => {
    const {
      duelistKing: { distributor, item },
    } = context;
    const packedTokenId = BytesBuffer.newInstance();
    for (let i = 0; i < boxes.length; i += 1) {
      packedTokenId.writeUint256(boxes[i]);
    }

    const txResult = await (await distributor.connect(accounts[4]).openBoxes(packedTokenId.invoke())).wait();
    const txTransferLogs = txResult.logs
      .filter((e) => e.topics[0] === utils.id('Transfer(address,address,uint256)'))
      .map((e) => {
        return item.interface.decodeEventLog('Transfer', e.data, e.topics);
      });
    cards = [...txTransferLogs.map((e) => e.tokenId)];
    console.log(
      txTransferLogs
        .map((e) => {
          const { from, to, tokenId } = e;
          return `Transfer(${[from, to, BigNumber.from(tokenId).toHexString()].join(', ')})`;
        })
        .join('\n'),
      `\n${txResult.gasUsed.toString()} Gas`,
    );
  });

  it('Owner balance should have 0 box after unboxing all boxes', async () => {
    const {
      duelistKing: { item, card },
    } = context;
    expect((await item.balanceOf(accounts[4].address)).toNumber()).to.eq(0);
    expect((await item.totalSupply()).toNumber()).to.eq(0);
    expect((await card.balanceOf(accounts[4].address)).toNumber()).to.eq(500);
    expect((await card.totalSupply()).toNumber()).to.eq((await card.balanceOf(accounts[4].address)).toNumber());
  });

  it('Duelistking Operator should able to call issueGenesisCard() in DuelistKingDistributor', async () => {
    const {
      duelistKing: { distributor, card },
    } = context;

    boxes = [];
    const operator = accounts[2];
    const txResult = await (await distributor.connect(operator).issueGenesisCard(accounts[4].address, 400)).wait();

    console.log(
      txResult.logs
        .filter((e) => e.topics[0] === utils.id('Transfer(address,address,uint256)'))
        .map((e) => card.interface.decodeEventLog('Transfer', e.data, e.topics))
        .map((e) => {
          const { from, to, tokenId } = e;
          const nftTokenId = BigNumber.from(tokenId).toHexString();
          const card = Card.from(nftTokenId);
          expect(card.getEdition()).to.eq(0xffff);
          expect(card.getId()).to.eq(400n);
          expect(card.getGeneration()).to.eq(1);
          expect(card.getRareness()).to.eq(0);
          expect(card.getType()).to.eq(0);
          if (from === zeroAddress) boxes.push(nftTokenId);
          return `Transfer(${[from, to, nftTokenId].join(', ')})`;
        })
        .join('\n'),
      `\n${txResult.gasUsed.toString()} Gas`,
    );
  });

  it('Duelistking Operator should able to call setRemainingBoxes() in DuelistKingDistributor', async () => {
    const {
      duelistKing: { merchant, distributor, card },
    } = context;

    const operator = accounts[2];
    const timestamp = await getCurrentBlockTimestamp(hre);
    const setAmount = 1000;
    const phaseId = 2;
    const config = {
      phaseId,
      totalSale: 20000,
      deadline: Math.round(timestamp + dayToSec(30)),
      basePrice: 5000000,
    };
    await expect(merchant.connect(accounts[1]).createNewCampaign(config)).to.be.revertedWith(
      'UserRegistry: Only allow call from same domain',
    );
    await (await distributor.connect(operator).setRemainingBoxes(phaseId, setAmount)).wait();
    const afterSetValue = await (await distributor.connect(operator).getRemainingBox(phaseId)).toNumber();
    expect(afterSetValue).to.eq(setAmount);
  });

  it('OracleProxy should able to forward upgradeCard() to DuelistKingDistributor', async () => {
    const {
      duelistKing: { distributor, oracle, card },
      config: { duelistKing },
    } = context;
    boxes = [];
    const txResult = await (
      await oracle
        .connect(accounts[8])
        .safeCall(
          await craftProof(await hre.ethers.getSigner(duelistKing.oracleAddresses[0]), oracle),
          distributor.address,
          0,
          distributor.interface.encodeFunctionData('upgradeCard', [cards[0], 500000000]),
        )
    ).wait();

    console.log(
      txResult.logs
        .filter((e) =>
          [
            utils.id('Transfer(address,address,uint256)'),
            utils.id('CardUpgradeFailed(address,uint256)'),
            utils.id('CardUpgradeSuccessful(address,uint256,uint256)'),
          ].includes(e.topics[0]),
        )
        .map((e) => {
          if (e.topics[0] === utils.id('CardUpgradeFailed(address,uint256)')) {
            const { owner, oldCardId } = distributor.interface.decodeEventLog('CardUpgradeFailed', e.data, e.topics);
            return `CardUpgradeFailed(${[owner, oldCardId.toHexString()].join(',')})`;
          } else if (e.topics[0] === utils.id('CardUpgradeSuccessful(address,uint256,uint256)')) {
            const { owner, oldCardId, newCardId } = distributor.interface.decodeEventLog(
              'CardUpgradeSuccessful',
              e.data,
              e.topics,
            );
            return `CardUpgradeSuccessful${[owner, oldCardId.toHexString(), newCardId.toHexString()].join(',')}`;
          }
          const { from, to, tokenId } = card.interface.decodeEventLog('Transfer', e.data, e.topics);
          return `Transfer(${[from, to, tokenId.toHexString()].join(',')})`;
        })
        .join('\n'),
      `\n${txResult.gasUsed.toString()} Gas`,
    );
  });

  it('Discount should be calculated correctly', async () => {
    const {
      duelistKing: { merchant },
    } = context;

    const buyBoxes = Math.floor(Math.random() * 255);

    function boxDiscount(noBoxes: number) {
      if (noBoxes <= 10) return 0;
      const discount = (Math.floor(noBoxes - 10) / 5) * 2;
      if (discount >= 30) return 30;
      return discount;
    }

    // ALO discount 10%
    printAllEvents(await merchant.connect(accounts[9]).setDiscount([stringToBytes32('ALO')], [100000]));
    const basePrice = BigNumber.from('5000000000000000000');
    // 10% discount code
    const price = basePrice.sub(basePrice.mul(10).div(100));
    // 2% box discount
    const lastPrice = price.sub(price.mul(boxDiscount(buyBoxes)).div(100));
    expect((await merchant.tokenAmountAfterDiscount(5000000, buyBoxes, stringToBytes32('ALO'), 18)).toString()).to.eq(
      lastPrice.toString(),
    );
  });
});
