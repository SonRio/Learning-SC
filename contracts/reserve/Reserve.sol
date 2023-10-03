// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Reserve is Ownable {
    IERC20 public immutable token;
    uint256 public unlockTime; // Thời gian unlock

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
        unlockTime = block.timestamp + 24 weeks; // 6 tháng
    }

    modifier checkTimestamp() {
        // Thời gian lúc hàm thực thi phải lớn hơn unlockTime
        // => Thực hiện sau khi block này đc deploy 6 tháng
        require(block.timestamp > unlockTime, "Reserve: Can Not Trade");
        _;
    }

    // Rút tiền đến 1 tài khoản _to với value
    function withdrawTo(
        address _to,
        uint256 _value
    ) public onlyOwner checkTimestamp {
        require(_to != address(0), "Reserve: transfer to zero address");
        require(
            token.balanceOf(address(this)) >= _value,
            "Reserve: exceeds contract balance"
        );
        token.transfer(_to, _value);
    }
}
