// Root file: contracts/libraries/Permissioned.sol

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4 <0.9.0;

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
