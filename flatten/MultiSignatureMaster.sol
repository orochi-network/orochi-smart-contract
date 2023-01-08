// Dependency file: @openzeppelin/contracts/utils/Address.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

// pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}


// Dependency file: @openzeppelin/contracts/proxy/Clones.sol

// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

// pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


// Dependency file: contracts/libraries/Verifier.sol

// pragma solidity >=0.8.4 <0.9.0;

library Verifier {
  function verifySerialized(bytes memory message, bytes memory signature) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      // Singature need to be 65 in length
      // if (signature.length !== 65) revert();
      if iszero(eq(mload(signature), 65)) {
        revert(0, 0)
      }
      // r = signature[:32]
      // s = signature[32:64]
      // v = signature[64]
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }
    return verify(message, r, s, v);
  }

  function verify(
    bytes memory message,
    bytes32 r,
    bytes32 s,
    uint8 v
  ) internal pure returns (address) {
    if (v < 27) {
      v += 27;
    }
    // V must be 27 or 28
    require(v == 27 || v == 28, 'Invalid v value');
    // Get hashes of message with Ethereum proof prefix
    bytes32 hashes = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n', uintToStr(message.length), message));

    return ecrecover(hashes, v, r, s);
  }

  function uintToStr(uint256 value) internal pure returns (string memory result) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return '0';
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }
}


// Dependency file: contracts/libraries/Bytes.sol

// pragma solidity >=0.8.4 <0.9.0;

library Bytes {
  // Convert bytes to bytes32[]
  function toBytes32Array(bytes memory input) internal pure returns (bytes32[] memory) {
    require(input.length % 32 == 0, 'Bytes: invalid data length should divied by 32');
    bytes32[] memory result = new bytes32[](input.length / 32);
    assembly {
      // Read length of data from offset
      let length := mload(input)

      // Seek offset to the beginning
      let offset := add(input, 0x20)

      // Next is size of chunk
      let resultOffset := add(result, 0x20)

      for {
        let i := 0
      } lt(i, length) {
        i := add(i, 0x20)
      } {
        mstore(resultOffset, mload(add(offset, i)))
        resultOffset := add(resultOffset, 0x20)
      }
    }
    return result;
  }

  // Read address from input bytes buffer
  function readAddress(bytes memory input, uint256 offset) internal pure returns (address result) {
    require(offset + 20 <= input.length, 'Bytes: Out of range, can not read address from bytes');
    assembly {
      result := shr(96, mload(add(add(input, 0x20), offset)))
    }
  }

  // Read uint256 from input bytes buffer
  function readUint256(bytes memory input, uint256 offset) internal pure returns (uint256 result) {
    require(offset + 32 <= input.length, 'Bytes: Out of range, can not read uint256 from bytes');
    assembly {
      result := mload(add(add(input, 0x20), offset))
    }
  }

  // Read bytes from input bytes buffer
  function readBytes(
    bytes memory input,
    uint256 offset,
    uint256 length
  ) internal pure returns (bytes memory) {
    require(offset + length <= input.length, 'Bytes: Out of range, can not read bytes from bytes');
    bytes memory result = new bytes(length);
    assembly {
      // Seek offset to the beginning
      let seek := add(add(input, 0x20), offset)

      // Next is size of data
      let resultOffset := add(result, 0x20)

      for {
        let i := 0
      } lt(i, length) {
        i := add(i, 0x20)
      } {
        mstore(add(resultOffset, i), mload(add(seek, i)))
      }
    }
    return result;
  }
}


// Dependency file: contracts/libraries/Permissioned.sol

// pragma solidity >=0.8.4 <0.9.0;

contract Permissioned {
  // Permission constants
  uint256 internal constant PERMISSION_NONE = 0;

  // Multi user data
  mapping(address => uint256) private _userRole;

  // Active time of user
  mapping(address => uint256) private _activeTime;

  // Total number of users
  uint256 private _totalUser;

  // Transfer role to new user event
  event TransferRole(address indexed preUser, address indexed newUser, uint256 indexed role);

  // Only allow users who has given role trigger smart contract
  modifier onlyAllow(uint256 permission) {
    require(_userRole[msg.sender] & permission > 0 && block.timestamp > _activeTime[msg.sender], 'P: Access denied');
    _;
  }

  // Only allow listed users to trigger smart contract
  modifier onlyUser() {
    require(
      _userRole[msg.sender] > PERMISSION_NONE && block.timestamp > _activeTime[msg.sender],
      'P: We are only allow user to trigger'
    );
    _;
  }

  /*******************************************************
   * Internal section
   ********************************************************/

  // Init method which can be called once
  function _init(address[] memory users_, uint256[] memory roles_) internal returns (uint256) {
    require(_totalUser == 0, 'P: Only able to be called once');
    require(users_.length == roles_.length, 'P: Length mismatch');
    for (uint256 i = 0; i < users_.length; i += 1) {
      _userRole[users_[i]] = roles_[i];
      emit TransferRole(address(0), users_[i], roles_[i]);
    }
    _totalUser = users_.length;
    return users_.length;
  }

  // Transfer role to new user
  function _transferRole(address newUser, uint256 lockDuration) internal returns (uint256) {
    require(newUser != address(0), 'P: Can not transfer user role');
    uint256 role = _userRole[msg.sender];
    // Remove user
    _userRole[msg.sender] = PERMISSION_NONE;
    // Assign role for new user
    _userRole[newUser] = role;
    _activeTime[newUser] = block.timestamp + lockDuration;
    emit TransferRole(msg.sender, newUser, role);
    return _userRole[newUser];
  }

  /*******************************************************
   * View section
   ********************************************************/

  // Read role of an user
  function getRole(address checkAddress) public view returns (uint256) {
    return _userRole[checkAddress];
  }

  // Get active time of user
  function getActiveTime(address checkAddress) public view returns (uint256) {
    return _activeTime[checkAddress];
  }

  // Is an address a user
  function isUser(address checkAddress) public view returns (bool) {
    return _userRole[checkAddress] > PERMISSION_NONE && block.timestamp > _activeTime[checkAddress];
  }

  // Check a permission is granted to user
  function isPermission(address checkAddress, uint256 checkPermission) public view returns (bool) {
    return isUser(checkAddress) && ((_userRole[checkAddress] & checkPermission) > 0);
  }

  // Get total number of user
  function getTotalUser() public view returns (uint256) {
    return _totalUser;
  }
}


// Dependency file: contracts/interfaces/IMultiSignature.sol

// pragma solidity >=0.8.4 <0.9.0;

interface IMultiSignature {
  function init(
    uint256 chainId_,
    address[] memory users_,
    uint256[] memory roles_,
    uint256 threshold_,
    uint256 thresholdDrag_
  ) external returns (bool);
}


// Root file: contracts/operators/MultiSignatureMaster.sol

pragma solidity >=0.8.4 <0.9.0;

// import '/Users/chiro/GitHub/orochi-smart-contract/node_modules/@openzeppelin/contracts/utils/Address.sol';
// import '/Users/chiro/GitHub/orochi-smart-contract/node_modules/@openzeppelin/contracts/proxy/Clones.sol';
// import 'contracts/libraries/Verifier.sol';
// import 'contracts/libraries/Bytes.sol';
// import 'contracts/libraries/Permissioned.sol';
// import 'contracts/interfaces/IMultiSignature.sol';

/**
 * Orochi Multi Signature Master
 * Name: N/A
 * Domain: N/A
 */
contract MultiSignatureMaster is Permissioned {
  // Allow master to clone other multi signature contract
  using Clones for address;

  // Permission
  uint256 internal constant PERMISSION_TRANSFER = 1;
  uint256 internal constant PERMISSION_OPERATOR = 2;

  // Wallet implementation
  address private _implementation;

  // Price in native token
  uint256 private _walletFee;

  // Chain id
  uint256 private _chainId;

  // Create new wallet
  event CreateNewWallet(
    address indexed creator,
    uint256 indexed salt,
    uint256 indexed threshold,
    uint256 thresholdDrag
  );

  // Upgrade implementation
  event UpgradeImplementation(address indexed oldImplementation, address indexed upgradeImplementation);

  // Request small fee to create new wallet, we prevent people spaming wallet
  modifier requireFee() {
    require(msg.value >= _walletFee, 'M: It need native token to trigger this method');
    _;
  }

  // This contract able to receive fund
  receive() external payable {}

  // Pass parameters to parent contract
  constructor(
    uint256 chainId_,
    address[] memory users_,
    uint256[] memory roles_,
    address implementation_,
    uint256 fee_
  ) {
    _implementation = implementation_;
    _walletFee = fee_;
    // We use input chainId instead of EIP-1344
    _chainId = chainId_;
    _init(users_, roles_);
    emit UpgradeImplementation(address(0), implementation_);
  }

  /*******************************************************
   * User section
   ********************************************************/
  // Transfer existing role to a new user
  function transferRole(address newUser) external onlyUser {
    // New user will be activated after 1 days 1 hours
    _transferRole(newUser, 1 days + 1 hours);
  }

  /*******************************************************
   * Transfer section
   ********************************************************/
  // Withdraw all of the balance to the fee collector
  function withdraw(address payable receiver) external onlyAllow(PERMISSION_TRANSFER) {
    receiver.transfer(address(this).balance);
  }

  /*******************************************************
   * Operator section
   ********************************************************/
  // Upgrade new implementation
  function upgradeImplementation(address newImplementation) external onlyAllow(PERMISSION_OPERATOR) {
    emit UpgradeImplementation(_implementation, newImplementation);
    _implementation = newImplementation;
  }

  /*******************************************************
   * Public section
   ********************************************************/
  // Create new multisig wallet
  function createWallet(
    uint96 salt,
    address[] memory users_,
    uint256[] memory roles_,
    uint256 threshold_,
    uint256 thresholdDrag_
  ) external payable requireFee returns (address) {
    address newWallet = _implementation.cloneDeterministic(_getUniqueSalt(msg.sender, salt));
    emit CreateNewWallet(msg.sender, salt, threshold_, thresholdDrag_);
    require(
      IMultiSignature(newWallet).init(_chainId, users_, roles_, threshold_, thresholdDrag_),
      'M: Can not init multi-sig wallet'
    );
    return newWallet;
  }

  /*******************************************************
   * Private section
   ********************************************************/
  function _getUniqueSalt(address creatorAddress, uint96 salt) private pure returns (bytes32) {
    bytes32 packedSalt;
    assembly {
      packedSalt := xor(shl(96, salt), creatorAddress)
    }
    return packedSalt;
  }

  /*******************************************************
   * View section
   ********************************************************/

  // Get fee to generate a new wallet
  function getFee() external view returns (uint256) {
    return _walletFee;
  }

  // Get implementation address
  function getImplementation() external view returns (address) {
    return _implementation;
  }

  // Calculate deterministic address
  function predictWalletAddress(address creatorAddress, uint96 salt) external view returns (address) {
    return _implementation.predictDeterministicAddress(_getUniqueSalt(creatorAddress, salt));
  }
}
