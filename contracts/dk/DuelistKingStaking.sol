// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../libraries/RegistryUser.sol';

/**
 * Duelist King Staking
 * Name: DuelistKingStaking
 * Doamin: Duelist King
 */

contract DuelistKingStaking is RegistryUser {
  using SafeERC20 for ERC20;
  using Address for address;

  struct StakingCampaign {
    uint64 startDate;
    uint64 endDate;
    uint64 returnRate;
    uint64 rewardPhaseId;
    uint256 maxAmountOfToken;
    uint256 stakedAmountOfToken;
    uint256 limitStakingAmountForUser;
    address tokenAddress;
    uint64 maxNumberOfBoxes;
    uint128 totalReceivedBoxes;
  }

  struct UserStakingSlot {
    uint256 stakingAmountOfToken;
    uint128 stakedAmountOfBoxes;
    uint64 startStakingDate;
    uint64 lastStakingDate;
  }

  uint256 private _totalCampaign;

  mapping(uint256 => StakingCampaign) private _campaignStorage;

  mapping(uint256 => mapping(address => UserStakingSlot)) private _userStakingSlot;

  mapping(address => uint256) private _totalPenalty;

  // New created campaign event
  event NewCampaign(uint64 indexed startDate, address indexed tokenAddress, uint256 indexed campaignId);

  // Staking event
  event Staking(address indexed owner, uint256 indexed amount, uint256 indexed campaignId);

  // Unstaking and claim reward event
  event ClaimReward(
    address indexed owner,
    uint128 indexed numberOfBoxes,
    uint64 indexed rewardPhaseId,
    uint256 campaignId,
    uint256 withdrawAmount,
    bool isPenalty
  );

  // Withdrawal penalty token event
  event Withdrawal(address indexed beneficiary, uint256 indexed amount, uint256 indexed campaignId);

  constructor(address registry_, bytes32 domain_) {
    _registryUserInit(registry_, domain_);
  }

  /*******************************************************
   * Public section
   *******************************************************/

  function staking(uint256 campaignId, uint256 amountOfToken) external returns (bool) {
    StakingCampaign memory currentCampaign = _campaignStorage[campaignId];
    UserStakingSlot memory currentUserStakingSlot = _userStakingSlot[campaignId][msg.sender];
    ERC20 currentToken = ERC20(currentCampaign.tokenAddress);

    // User should stake at least 1 day in event time
    require(
      block.timestamp >= currentCampaign.startDate && block.timestamp < currentCampaign.endDate - (1 days + 1 hours),
      'DKStaking: Not in event time'
    );

    // Validate token limit per user
    require(
      currentUserStakingSlot.stakingAmountOfToken + amountOfToken <= currentCampaign.limitStakingAmountForUser,
      'DKStaking: Token limit per user exceeded'
    );

    if (currentUserStakingSlot.stakingAmountOfToken == 0) {
      currentUserStakingSlot.startStakingDate = uint64(block.timestamp);
      currentUserStakingSlot.lastStakingDate = uint64(block.timestamp);
    }

    // Transfer token from user to this smart contract
    require(currentToken.balanceOf(msg.sender) >= amountOfToken, 'DKStaking: Insufficient balance');
    uint256 beforeBalance = currentToken.balanceOf(address(this));
    currentToken.safeTransferFrom(msg.sender, address(this), amountOfToken);
    uint256 afterBalance = currentToken.balanceOf(address(this));
    require(afterBalance - beforeBalance == amountOfToken, 'DKStaking: Invalid token transfer');

    // Add this amount of token to the pool
    currentCampaign.stakedAmountOfToken += amountOfToken;
    require(currentCampaign.stakedAmountOfToken <= currentCampaign.maxAmountOfToken, 'DKStaking: Token limit exceeded');

    // Calculate user reward
    currentUserStakingSlot.stakedAmountOfBoxes = estimateUserReward(currentCampaign, currentUserStakingSlot);
    currentUserStakingSlot.lastStakingDate = uint64(block.timestamp);
    currentUserStakingSlot.stakingAmountOfToken += amountOfToken;

    // Update campaign and user staking slot
    _campaignStorage[campaignId] = currentCampaign;
    _userStakingSlot[campaignId][msg.sender] = currentUserStakingSlot;
    emit Staking(msg.sender, amountOfToken, campaignId);
    return true;
  }

  function unStaking(uint256 campaignId) external returns (bool) {
    UserStakingSlot memory currentUserStakingSlot = _userStakingSlot[campaignId][msg.sender];
    StakingCampaign memory currentCampaign = _campaignStorage[campaignId];
    uint256 withdrawAmount = currentUserStakingSlot.stakingAmountOfToken;
    uint128 rewardBoxes = estimateUserReward(currentCampaign, currentUserStakingSlot);
    bool isPenalty;

    require(withdrawAmount > 0, 'DKStaking: No token to be unstaked');

    /**
     * User unstake before endDate
     * will be paid for penalty fee: 2% DKT and 50% reward box
     */

    if (block.timestamp < currentCampaign.endDate) {
      uint256 penaltyAmount = withdrawAmount / 50;

      // pnaltyAmount: 2% of user's staked token
      withdrawAmount -= penaltyAmount;

      // penalty rewardBoxes is 50%
      rewardBoxes /= 2;
      _totalPenalty[currentCampaign.tokenAddress] += penaltyAmount;
      isPenalty = true;
    }
    transfer(currentCampaign.tokenAddress, msg.sender, withdrawAmount);
    emit ClaimReward(
      msg.sender,
      rewardBoxes / 1000000,
      currentCampaign.rewardPhaseId,
      campaignId,
      withdrawAmount,
      isPenalty
    );

    // Remove user staking amount from the pool and update total boxes user receive
    currentCampaign.stakedAmountOfToken -= currentUserStakingSlot.stakingAmountOfToken;
    currentCampaign.totalReceivedBoxes += rewardBoxes / 1000000;

    // Reset user staking storage
    currentUserStakingSlot.stakingAmountOfToken = 0;
    currentUserStakingSlot.stakedAmountOfBoxes = 0;
    currentUserStakingSlot.startStakingDate = 0;
    currentUserStakingSlot.lastStakingDate = 0;

    // Update campaign and user staking slot
    _campaignStorage[campaignId] = currentCampaign;
    _userStakingSlot[campaignId][msg.sender] = currentUserStakingSlot;
    return true;
  }

  /*******************************************************
   * Same domain section
   *******************************************************/

  // Create a new staking campaign
  function createNewStakingCampaign(StakingCampaign memory newCampaign)
    external
    onlyAllowSameDomain('StakingOperator')
    returns (bool)
  {
    require(
      newCampaign.startDate > block.timestamp && newCampaign.endDate > newCampaign.startDate,
      'DKStaking: Invalid timeline format'
    );
    uint64 duration = (newCampaign.endDate - newCampaign.startDate) / (1 days);
    require(duration > 1, 'DKStaking: Duration must be greater than 1');

    require(newCampaign.rewardPhaseId >= 1, 'DKStaking: Invalid phase id');
    require(newCampaign.tokenAddress.isContract(), 'DKStaking: Token address is not a smart contract');

    newCampaign.returnRate = uint64(
      (newCampaign.maxNumberOfBoxes * 1000000) / (newCampaign.maxAmountOfToken * duration)
    );
    _campaignStorage[_totalCampaign] = newCampaign;

    emit NewCampaign(newCampaign.startDate, newCampaign.tokenAddress, _totalCampaign);
    _totalCampaign += 1;
    return true;
  }

  // Staking operator withdraw the penalty token
  function withdrawPenaltyToken(uint256 campaignId, address beneficiary)
    external
    onlyAllowSameDomain('StakingOperator')
    returns (bool)
  {
    StakingCampaign memory currentCampaign = _campaignStorage[campaignId];
    uint256 withdrawingAmount = _totalPenalty[currentCampaign.tokenAddress];
    transfer(currentCampaign.tokenAddress, beneficiary, withdrawingAmount);
    emit Withdrawal(beneficiary, withdrawingAmount, campaignId);
    return true;
  }

  /*******************************************************
   * Private section
   *******************************************************/

  // Estimate user reward for a duration
  function estimateUserReward(StakingCampaign memory currentCampaign, UserStakingSlot memory currentUserStakingSlot)
    private
    view
    returns (uint128)
  {
    uint64 currentTimestamp = uint64(block.timestamp);
    if (currentTimestamp > currentCampaign.endDate) {
      currentTimestamp = currentCampaign.endDate;
    }
    uint64 stakingDuration = (currentTimestamp - currentUserStakingSlot.lastStakingDate) / (1 days);

    uint128 remainingReward = uint128(
      currentUserStakingSlot.stakingAmountOfToken * stakingDuration * currentCampaign.returnRate
    );
    return currentUserStakingSlot.stakedAmountOfBoxes + remainingReward;
  }

  // Transfer token to receiver
  function transfer(
    address tokenAddress,
    address receiver,
    uint256 amount
  ) private returns (bool) {
    ERC20 token = ERC20(tokenAddress);

    require(token.balanceOf(address(this)) >= amount && amount > 0, 'DKStaking: Insufficient balance');
    uint256 beforeBalance = token.balanceOf(address(this));
    token.safeTransfer(receiver, amount);
    uint256 afterBalance = token.balanceOf(address(this));
    require(beforeBalance - afterBalance == amount, 'DKStaking: Invalid token transfer');
    return true;
  }

  /*******************************************************
   * View section
   *******************************************************/

  function getUserStakingSlot(uint256 campaignId, address owner) external view returns (UserStakingSlot memory) {
    StakingCampaign memory currentCampaign = _campaignStorage[campaignId];
    UserStakingSlot memory currentUserStakingSlot = _userStakingSlot[campaignId][owner];
    currentUserStakingSlot.stakedAmountOfBoxes = estimateUserReward(currentCampaign, currentUserStakingSlot) / 1000000;
    return currentUserStakingSlot;
  }

  function getBlockTime() external view returns (uint256) {
    return block.timestamp;
  }

  function getTotalPenaltyAmount(address tokenAddress) external view returns (uint256) {
    require(tokenAddress.isContract(), 'DKStaking: Token address is not a smart contract');
    return _totalPenalty[tokenAddress];
  }

  function getCampaignInfo(uint256 campaignId) external view returns (StakingCampaign memory) {
    return _campaignStorage[campaignId];
  }
}
