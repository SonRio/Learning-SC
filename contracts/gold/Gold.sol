// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Pausable
// Pause contract

// AccessControl
// Phân quyền sử dụng fun trong SC
contract Gold is ERC20, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    mapping(address => bool) private _blacklist;
    event BlackListAdded(address _account);
    event BlackListRemoved(address _account);

    constructor() ERC20("GOLD", "GLD") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(_blacklist[from] == false, "Gold: Account was on BLACKLIST");
        require(_blacklist[to] == false, "Gold: Account was on BLACKLIST");
        super._beforeTokenTransfer(from, to, amount);
    }

    // Black-list
    function addToBlacklist(
        address _account
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _account != msg.sender,
            "Gold: can not add sender to black list"
        );
        require(_blacklist[_account] == false, "Gold: Account was exited");
        _blacklist[_account] = true;
        emit BlackListAdded(_account);
    }

    function removeFromBlacklist(
        address _account
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_blacklist[_account] == true, "Gold: Account is not exited");
        _blacklist[_account] = false;
        emit BlackListRemoved(_account);
    }
}
