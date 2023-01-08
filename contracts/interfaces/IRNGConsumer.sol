// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4 <0.9.0;

interface IRNGConsumer {
  function compute(bytes memory data) external returns (bool);
}
