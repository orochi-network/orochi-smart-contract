// Dependency file: @openzeppelin/contracts/utils/Address.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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


// Dependency file: contracts/libraries/MultiSignatureStorage.sol

// pragma solidity >=0.8.4 <0.9.0;

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

  // Threshold for a proposal to be passed, it' usual 50%
  int256 internal _threshold;

  // Threshold for all participants to be drag a long, it's usual 70%
  int256 internal _thresholdDrag;
}


// Root file: contracts/operators/MultiSignatureV1.sol

pragma solidity >=0.8.4 <0.9.0;

// import '/Users/chiro/GitHub/infrastructure/node_modules/@openzeppelin/contracts/utils/Address.sol';
// import 'contracts/libraries/Verifier.sol';
// import 'contracts/libraries/Bytes.sol';
// import 'contracts/libraries/Permissioned.sol';
// import 'contracts/libraries/MultiSignatureStorage.sol';

/**
 * Orochi Multi Signature Wallet
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
    int256 threshold_,
    int256 thresholdDrag_
  ) external {
    require(_init(users_, roles_) > 0, 'S: Unable to init contract');
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
    // And vote again
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
    require(_calculatePercent(int256(totalSigned)) >= _thresholdDrag, 'S: Drag threshold was not passed');
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
    int256 voting = _calculatePercent(currentProposal.vote);
    // If positiveVoted < 70%, It need to pass 50% and expired
    if (voting < int256(_thresholdDrag)) {
      require(block.timestamp > _proposalStorage[proposalId].expired, "S: Voting period wasn't over");
      require(voting >= 50, 'S: Vote was not pass 50%');
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

  function _calculatePercent(int256 votedUsers) private view returns (int256) {
    return (votedUsers * 10000) / int256(_totalSigner * 100);
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
