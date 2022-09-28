// Root file: contracts/libraries/MultiSignatureStorage.sol

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4 <0.9.0;

/**
 * Orochi Multi Signature Storage
 * Noted: We going to split data and logic, this file shouldn't change
 * Name: N/A
 * Domain: N/A
 */
contract MultiSignatureStorage {
  // Structure of proposal
  struct Proposal {
    int256 vote;
    uint256 expired;
    bool executed;
    uint256 value;
    address target;
    bytes data;
  }

  // Proposal index, begin from 0
  uint256 internal _totalProposal;

  // Proposal storage
  mapping(uint256 => Proposal) internal _proposalStorage;

  // Voted storage
  mapping(uint256 => mapping(address => bool)) internal _votedStorage;

  // Quick transaction nonce
  uint256 internal _nonce = 0;

  // Total number of signer
  uint256 internal _totalSigner = 0;

  // Threshold for a proposal to be passed
  uint256 internal _threshold;

  // Threshold for all participants to be drag a long
  uint256 internal _thresholdDrag;
}
