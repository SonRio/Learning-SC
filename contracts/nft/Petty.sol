// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Petty is ERC721, Ownable {
    // Sử dụng Counter Contract để khởi tạo tokenID
    using Counters for Counters.Counter;

    // Khai báo token counter
    Counters.Counter private _tokenCounter;
    string private _baseTokenURL;

    constructor() ERC721("Petty", "PET") {}

    // Tạo ra NFT mới
    function mint(address to) public onlyOwner returns (uint256) {
        // Thực hiện increment
        _tokenCounter.increment();
        // lấy giá trị hiện tại để tạo ra tokenId
        uint256 _tokenId = _tokenCounter.current();
        _mint(to, _tokenId);
        return _tokenId;
    }

    // View token
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURL;
    }

    // update baseTokenURL - JUST ONLY FOR OWNER
    function updateBaseTokenURI(string memory baseTokenURI_) public onlyOwner {
        _baseTokenURL = baseTokenURI_;
    }
}
