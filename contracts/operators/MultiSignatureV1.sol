// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/utils/Address.sol';
import '../libraries/Verifier.sol';
import '../libraries/Bytes.sol';
import '../libraries/Permissioned.sol';
import '../libraries/MultiSignatureStorage.sol';

/**
 * Orochi Multi Signature Wallet V1
 * Name: N/A
 * Domain: N/A
 */
contract MultiSignatureV1 is Permissioned, MultiSignatureStorage {
  // Address lib providing safe {call} and {delegatecall}
  using Address for address;

  // Byte manipulation
  using Bytes for bytes;

  // Verifiy digital signature
  using Verifier for bytes;

  // Permission constants
  // Create a new proposal and do qick transfer
  uint256 private constant PERMISSION_CREATE = 1;
  // Allowed to sign quick transfer message and vote a proposal
  uint256 private constant PERMISSION_VOTE = 2;
  // Permission to execute the proposal
  uint256 private constant PERMISSION_EXECUTE = 4;
  // View permission only
  uint256 private constant PERMISSION_OBSERVER = 4294967296;

  // Create a new proposal
  event NewProposal(address creator, uint256 indexed proposalId, uint256 indexed expired);

  // Execute proposal
  event ExecuteProposal(uint256 indexed proposalId, address indexed trigger, int256 indexed vote);

  // Positive vote
  event PositiveVote(uint256 indexed proposalId, address indexed owner);

  // Negative vote
  event NegativeVote(uint256 indexed proposalId, address indexed owner);

  // Receive payment
  event InternalTransaction(address indexed from, address indexed to, uint256 indexed value);

  // Qick transfer event
  event QuickTranfser(address indexed target, uint256 indexed value, bytes indexed data);

  // This contract able to receive fund
  receive() external payable {
    if (msg.value > 0) emit InternalTransaction(msg.sender, address(this), msg.value);
  }

  // Init method which can be called once
  function init(
    address[] memory users_,
    uint256[] memory roles_,
    uint256 threshold_,
    uint256 thresholdDrag_
  ) external {
    require(_init(users_, roles_) > 0, 'S: Unable to init contract');
    require(thresholdDrag_ <= users_.length, 'S: Drag threshold is too big');
    require(threshold_ <= thresholdDrag_, 'S: Threshold is bigger than drag threshold');
    uint256 totalSinger = 0;
    for (uint256 i = 0; i < users_.length; i += 1) {
      if (roles_[i] & PERMISSION_VOTE > 0) {
        totalSinger += 1;
      }
    }
    // These values can be set once
    _threshold = threshold_;
    _thresholdDrag = thresholdDrag_;
    _totalSigner = totalSinger;
  }

  /*******************************************************
   * User section
   ********************************************************/
  // Transfer role to new user
  function transferRole(address newUser) external onlyUser {
    // New user will be activated after 7 days
    // We prevent them to vote and transfer permission to the other
    // and vote again
    _transferRole(newUser, 7 days);
  }

  /*******************************************************
   * Creator section
   ********************************************************/
  // Transfer with signed proofs instead of on-chain voting
  function quickTransfer(bytes[] memory signatures, bytes memory txData)
    external
    onlyAllow(PERMISSION_CREATE)
    returns (bool)
  {
    uint256 totalSigned = 0;
    address[] memory signedAddresses = new address[](signatures.length);
    for (uint256 i = 0; i < signatures.length; i += 1) {
      address signer = txData.verifySerialized(signatures[i]);
      // Each signer only able to be counted once
      if (isPermission(signer, PERMISSION_VOTE) && _isNotInclude(signedAddresses, signer)) {
        signedAddresses[totalSigned] = signer;
        totalSigned += 1;
      }
    }
    require(totalSigned >= _thresholdDrag, 'S: Drag threshold was not passed');
    uint256 packagedNonce = txData.readUint256(0);
    address target = txData.readAddress(32);
    uint256 value = txData.readUint256(52);
    bytes memory data = txData.readBytes(84, txData.length - 84);
    uint256 nonce = packagedNonce & 0xffffffffffffffffffffffffffffffff;
    uint256 votingTime = packagedNonce >> 128;
    require(nonce - _nonce == 1, 'S: Invalid nonce value');
    require(votingTime > block.timestamp && votingTime < block.timestamp + 3 days, 'S: Proof expired');
    _nonce = nonce;
    if (target.isContract()) {
      target.functionCallWithValue(data, value);
    } else {
      payable(address(target)).transfer(value);
    }
    emit QuickTranfser(target, value, data);
    return true;
  }

  // Create a new proposal
  function createProposal(
    address target_,
    uint256 value_,
    uint256 expired_,
    bytes memory data_
  ) external onlyAllow(PERMISSION_CREATE) returns (uint256) {
    // Minimum expire time is 1 day
    uint256 expired = expired_ > block.timestamp + 1 days ? expired_ : block.timestamp + 1 days;
    uint256 proposalIndex = _totalProposal;
    _proposalStorage[proposalIndex] = Proposal({
      target: target_,
      value: value_,
      data: data_,
      expired: expired,
      vote: 0,
      executed: false
    });
    emit NewProposal(msg.sender, proposalIndex, expired);
    _totalProposal = proposalIndex + 1;
    return proposalIndex;
  }

  /*******************************************************
   * Vote permission section
   ********************************************************/
  // Positive vote
  function votePositive(uint256 proposalId) external onlyAllow(PERMISSION_VOTE) returns (bool) {
    return _voteProposal(proposalId, true);
  }

  // Negative vote
  function voteNegative(uint256 proposalId) external onlyAllow(PERMISSION_VOTE) returns (bool) {
    return _voteProposal(proposalId, false);
  }

  /*******************************************************
   * Execute permission section
   ********************************************************/
  // Execute a voted proposal
  function execute(uint256 proposalId) external onlyAllow(PERMISSION_EXECUTE) returns (bool) {
    Proposal memory currentProposal = _proposalStorage[proposalId];
    require(currentProposal.executed == false, 'S: Proposal was executed');
    // If positiveVoted < drag threshold, It need to pass minimal threshold and expired
    if (currentProposal.vote < int256(_thresholdDrag)) {
      require(block.timestamp > _proposalStorage[proposalId].expired, "S: Voting period wasn't over");
      require(currentProposal.vote >= int256(_threshold), 'S: Vote was not pass threshold');
    }

    if (currentProposal.target.isContract()) {
      currentProposal.target.functionCallWithValue(currentProposal.data, currentProposal.value);
    } else {
      payable(address(currentProposal.target)).transfer(currentProposal.value);
    }
    currentProposal.executed = true;
    _proposalStorage[proposalId] = currentProposal;
    emit ExecuteProposal(proposalId, msg.sender, currentProposal.vote);
    return true;
  }

  /*******************************************************
   * Private section
   ********************************************************/
  // Vote a proposal
  function _voteProposal(uint256 proposalId, bool positive) private returns (bool) {
    require(block.timestamp < _proposalStorage[proposalId].expired, 'S: Voting period was over');
    require(_votedStorage[proposalId][msg.sender] == false, 'S: You had voted this proposal');
    if (positive) {
      _proposalStorage[proposalId].vote += 1;
      emit PositiveVote(proposalId, msg.sender);
    } else {
      _proposalStorage[proposalId].vote -= 1;
      emit NegativeVote(proposalId, msg.sender);
    }
    _votedStorage[proposalId][msg.sender] = true;
    return true;
  }

  /*******************************************************
   * Pure section
   ********************************************************/

  function _isNotInclude(address[] memory addressList, address checkAddress) private pure returns (bool) {
    for (uint256 i = 0; i < addressList.length; i += 1) {
      if (addressList[i] == checkAddress) {
        return false;
      }
    }
    return true;
  }

  /*******************************************************
   * View section
   ********************************************************/

  function getPackedTransaction(
    address target,
    uint256 value,
    bytes memory data
  ) external view returns (bytes memory) {
    return abi.encodePacked(uint128(block.timestamp + 1 hours), uint128(_nonce + 1), target, value, data);
  }

  function getTotalProposal() external view returns (uint256) {
    return _totalProposal;
  }

  function proposalDetail(uint256 index) external view returns (Proposal memory) {
    return _proposalStorage[index];
  }

  function isVoted(uint256 proposalId, address owner) external view returns (bool) {
    return _votedStorage[proposalId][owner];
  }

  function getNextValidNonce() external view returns (uint256) {
    return _nonce + 1;
  }

  function getTotalSigner() external view returns (uint256) {
    return _totalSigner;
  }
}
