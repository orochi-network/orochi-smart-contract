// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '../libraries/RegistryUser.sol';
import '../interfaces/IDistributor.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * Duelist King Merchant
 * Name: DuelistKingMerchant
 * Doamin: Duelist King
 */
contract DuelistKingMerchant is RegistryUser {
  using SafeERC20 for ERC20;

  // Sale campaign
  struct SaleCampaign {
    uint256 phaseId;
    uint256 totalSale;
    uint256 basePrice;
    uint256 deadline;
  }

  // Stable coin info
  struct Stablecoin {
    address tokenAddress;
    uint256 decimals;
  }

  // Discount are in 10^-6, e.g: 100,000 = 10%
  // = 100,000/10^6 = 0.1 * 100% = 10%
  mapping(bytes32 => uint256) private _discount;

  // Maping sale campaign
  mapping(uint256 => SaleCampaign) private _campaign;

  // Stablecoin information
  mapping(address => Stablecoin) private _stablecoin;

  // Total campaign
  uint256 private _totalCampaign;

  // Discount rate for boxes
  // In 10^-6 it's 2%
  uint256 private _discountRate = 20000;

  // New campaign
  event NewCampaign(uint256 indexed phaseId, uint256 indexed totalSale, uint256 indexed basePrice);

  // A user buy card from merchant
  event Purchase(address indexed owner, uint256 indexed phaseId, uint256 indexed numberOfBoxes, bytes32 code);

  // Update supporting stablecoin
  event UpdateStablecoin(address indexed contractAddress, uint256 indexed decimals, bool isListed);

  // Update new code
  event UpdateDiscountCode(bytes32 indexed code, uint256 indexed discount);

  // Constructor method
  constructor(address registry_, bytes32 domain_) {
    _registryUserInit(registry_, domain_);
  }

  /*******************************************************
   * Sales Agent section
   ********************************************************/

  // Create a new campaign
  function createNewCampaign(SaleCampaign memory newCampaign)
    external
    onlyAllowSameDomain('Sales Agent')
    returns (uint256)
  {
    IDistributor distributor = IDistributor(_getAddressSameDomain('Distributor'));
    require(
      distributor.getRemainingBox(newCampaign.phaseId) > newCampaign.totalSale,
      'ME:Invalid number of selling boxes'
    );
    // We use 10^6 or 6 decimal for fiat value, e.g $4.8 -> 4,800,000
    require(newCampaign.basePrice > 1000000, 'ME:Base price must greater than 1 unit');
    require(newCampaign.deadline > block.timestamp, 'ME:Deadline must be in the future');
    uint256 currentCampaignId = _totalCampaign;
    _campaign[currentCampaignId] = newCampaign;
    _totalCampaign += 1;
    emit NewCampaign(newCampaign.phaseId, newCampaign.totalSale, newCampaign.basePrice);
    return currentCampaignId;
  }

  // Create a new supported stable coin
  function manageStablecoin(
    address tokenAddress,
    uint256 decimals,
    bool isListing
  ) external onlyAllowSameDomain('Sales Agent') returns (bool) {
    if (decimals == 0) {
      decimals = ERC20(tokenAddress).decimals();
    }
    _stablecoin[tokenAddress] = Stablecoin({ tokenAddress: tokenAddress, decimals: decimals });
    emit UpdateStablecoin(tokenAddress, decimals, isListing);
    return true;
  }

  // Set discount code
  function setDiscount(bytes32[] calldata codes, uint256[] calldata discounts)
    external
    onlyAllowSameDomain('Sales Agent')
    returns (bool)
  {
    require(codes.length == discounts.length, 'ME:Data mismatch');
    for (uint256 i = 0; i < codes.length; i += 1) {
      _discount[codes[i]] = discounts[i];
      emit UpdateDiscountCode(codes[i], discounts[i]);
    }
    return true;
  }

  /*******************************************************
   * Public section
   ********************************************************/

  // Anyone could buy NFT from smart contract
  function buy(
    uint256 campaignId,
    uint256 numberOfBoxes,
    address tokenAddress,
    bytes32 code
  ) external returns (bool) {
    require(isSupportedStablecoin(tokenAddress), 'ME:Stablecoin was not supported');
    IDistributor distributor = IDistributor(_getAddressSameDomain('Distributor'));
    SaleCampaign memory currentCampaign = _campaign[campaignId];
    require(block.timestamp < currentCampaign.deadline, 'ME:Sale campaign was ended');
    uint256 priceInToken = tokenAmountAfterDiscount(
      currentCampaign.basePrice,
      numberOfBoxes,
      code,
      _stablecoin[tokenAddress].decimals
    );
    // Calcualate box price

    // Verify payment
    _tokenTransfer(tokenAddress, msg.sender, address(this), priceInToken * numberOfBoxes);
    distributor.mintBoxes(msg.sender, numberOfBoxes, currentCampaign.phaseId);
    emit Purchase(msg.sender, currentCampaign.phaseId, numberOfBoxes, code);
    return true;
  }

  /*******************************************************
   * Private section
   ********************************************************/

  // Calculate price after discount
  function _afterDiscount(uint256 basePrice, uint256 discount) internal pure returns (uint256) {
    return basePrice - ((basePrice * discount) / 1000000);
  }

  // Transfer token to receiver
  function _tokenTransfer(
    address tokenAddress,
    address sender,
    address receiver,
    uint256 amount
  ) private returns (bool) {
    ERC20 token = ERC20(tokenAddress);
    uint256 beforeBalance = token.balanceOf(receiver);
    token.safeTransferFrom(sender, receiver, amount);
    uint256 afterBalance = token.balanceOf(receiver);
    require(afterBalance - beforeBalance == amount, 'ME:Invalid token transfer');
    return true;
  }

  /*******************************************************
   * View section
   ********************************************************/

  // Check a stablecoin is supported or not
  function isSupportedStablecoin(address tokenAddress) public view returns (bool) {
    return _stablecoin[tokenAddress].tokenAddress == tokenAddress;
  }

  // Calculate price after apply discount code
  // discountedPrice = basePrice - (basePrice * discount)/10^6
  // tokenPrice = discountedPrice * 10^decimals
  function tokenAmountAfterDiscount(
    uint256 basePrice,
    uint256 numberOfBoxes,
    bytes32 code,
    uint256 decmials
  ) public view returns (uint256) {
    return
      (_afterDiscount(_afterDiscount(basePrice, boxDiscount(numberOfBoxes)), codeDiscount(code)) * 10**decmials) /
      1000000;
  }

  function codeDiscount(bytes32 code) public view returns (uint256) {
    return _discount[code];
  }

  function boxDiscount(uint256 numberOfBoxes) public view returns (uint256) {
    // Prevent integer underflow
    if (numberOfBoxes <= 10) return 0;
    uint256 discount = ((numberOfBoxes - 10) / 5) * _discountRate;
    if (discount >= 300000) return 300000;
    return discount;
  }

  // Get total campaign
  function getTotalCampaign() external view returns (uint256) {
    return _totalCampaign;
  }

  // Get campaign detail
  function getCampaignDetail(uint256 campaignId) external view returns (SaleCampaign memory) {
    return _campaign[campaignId];
  }
}
