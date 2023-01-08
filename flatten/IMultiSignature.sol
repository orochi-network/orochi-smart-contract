// Root file: contracts/interfaces/IMultiSignature.sol

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4 <0.9.0;

interface IMultiSignature {
  function init(
    uint256 chainId_,
    address[] memory users_,
    uint256[] memory roles_,
    uint256 threshold_,
    uint256 thresholdDrag_
  ) external returns (bool);
}
