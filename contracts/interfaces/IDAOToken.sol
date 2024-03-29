// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

interface IDAOToken {
  function init(string memory name, string memory symbol, address genesis, uint256 supply) external returns (bool);

  function totalSupply() external view returns (uint256);

  function calculatePower(address owner) external view returns (uint256);
}
