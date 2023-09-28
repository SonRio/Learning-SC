// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//Library sup approve payment for all token use ERC20
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Marketplace is Ownable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    // Khai báo các trường cần thiết cho 1 order
    struct Order {
        address seller;
        address buyer;
        uint256 tokenId;
        address paymentToken;
        uint256 price;
    }
    Counters.Counter private _orderIdCounter;
    // immutable gíup nftContract trở thành 1 biến readOnly
    // TODO
    IERC721 public immutable nftContract;
    mapping(uint256 => Order) orders;
    uint256 public feeDecimal; //Phi giao dich
    uint256 public feeRate; //Phí giá trị số nguyên
    address public feeRecipient; // Địa chỉ ví
    // approve payment for all token use ERC20
    EnumerableSet.AddressSet private _supportedPaymentTokens;

    // indexed có thể filter theo biến nào có đặt indexed
    event OrderAdded(
        uint256 indexed orderId,
        address indexed seller,
        uint256 indexed tokenId,
        address paymentToken,
        uint256 price
    );

    event OrderCancelled(uint256 indexed orderId);

    event OrderMatched(
        uint256 indexed orderId,
        address indexed seller,
        address indexed buyer,
        uint256 tokenId,
        address paymentToken,
        uint256 price
    );

    event FeeRateUpdated(uint256 feeDecimal, uint256 feeRate);

    constructor(
        address nftAddress_,
        uint256 feeDecimal_,
        uint256 feeRate_,
        address feeRecipient_
    ) {
        require(
            nftAddress_ != address(0),
            "NFTMarketplace: nftAddress_ is zero address"
        );

        nftContract = IERC721(nftAddress_);
        _updateFeeRecipient(feeRecipient_);
        _updateFeeRate(feeDecimal_, feeRate_);
        _orderIdCounter.increment();
    }

    function _updateFeeRecipient(address feeRecipient_) internal {
        require(
            feeRecipient_ != address(0),
            "NFTMarketplace: feeRecipient_ is zero address"
        );
        feeRecipient = feeRecipient_;
    }

    function updateFeeRecipient(address feeRecipient_) external onlyOwner {
        _updateFeeRecipient(feeRecipient_);
    }

    function _updateFeeRate(uint256 feeDecimal_, uint256 feeRate_) internal {
        // Phần trăm feeRate bắt buộc phải nhỏ hơn 100%
        require(
            feeRate_ < 10 ** (feeDecimal_ + 2),
            "NFTMarketplace: bad fee rate"
        );
        feeDecimal = feeDecimal_;
        feeRate = feeRate_;
        emit FeeRateUpdated(feeDecimal_, feeRate_);
    }

    function updateFeeRate(
        uint256 feeDecimal_,
        uint256 feeRate_
    ) external onlyOwner {
        _updateFeeRate(feeDecimal_, feeRate_);
    }

    function _calculateFee(uint256 orderId_) private view returns (uint256) {
        // Lấy order
        Order storage _order = orders[orderId_];
        if (feeRate == 0) {
            return 0;
        }
        return (feeRate * _order.price) / 10 ** (feeDecimal + 2);
    }

    function isSeller(
        uint256 orderId_,
        address seller_
    ) public view returns (bool) {
        return orders[orderId_].seller == seller_;
    }

    function addPaymentToken(address paymentToken_) external onlyOwner {
        require(
            paymentToken_ != address(0),
            "NFTMarketplace: feeRecipient is zero address"
        );

        require(
            _supportedPaymentTokens.add(paymentToken_),
            "NFTMarketplace: already supported"
        );
    }

    // Check xem token đã được add vào payment token hay chưa?
    function isPaymentTokenSupported(
        address paymentToken_
    ) public view returns (bool) {
        return _supportedPaymentTokens.contains(paymentToken_);
    }

    modifier onlySupportedPaymentToken(address paymentToken_) {
        require(
            isPaymentTokenSupported(paymentToken_),
            "NFTMarketplace: unsupport payment token"
        );
        _;
    }

    function addOrder(
        uint256 tokenId_,
        address paymentToken_,
        uint256 price_
    ) public onlySupportedPaymentToken(paymentToken_) {
        require(
            nftContract.ownerOf(tokenId_) == _msgSender(),
            "NFTMarketplace: sender is not owner of token"
        );
        require(
            nftContract.getApproved(tokenId_) == address(this) ||
                nftContract.isApprovedForAll(_msgSender(), address(this)),
            "NFTMarketplace: The contract is unauthorized to manage this token"
        );
        require(price_ > 0, "NFTMarketplace: price must be greater than 0");
        uint256 _orderId = _orderIdCounter.current();
        orders[_orderId] = Order(
            _msgSender(),
            address(0),
            tokenId_,
            paymentToken_,
            price_
        );
        _orderIdCounter.increment();
        nftContract.transferFrom(_msgSender(), address(this), tokenId_);
        emit OrderAdded(
            _orderId,
            _msgSender(),
            tokenId_,
            paymentToken_,
            price_
        );
    }

    function cancelOrder(uint256 orderId_) external {
        Order storage _order = orders[orderId_];
        require(
            _order.buyer == address(0),
            "NFTMarketplace: buyer must be zero"
        );
        require(_order.seller == _msgSender(), "NFTMarketplace: must be owner");
        uint256 _tokenId = _order.tokenId;
        delete orders[orderId_];
        nftContract.transferFrom(address(this), _msgSender(), _tokenId);
        emit OrderCancelled(orderId_);
    }

    function executeOrder(uint256 orderId_) external {
        Order storage _order = orders[orderId_];
        require(_order.price > 0, "NFTMarketplace: order has been canceled");
        require(
            !isSeller(orderId_, _msgSender()),
            "NFTMarketplace: buyer must be different from seller"
        );
        require(
            _order.buyer == address(0),
            "NFTMarketplace: buyer must be zero"
        );
        _order.buyer = _msgSender();
        uint256 _feeAmount = _calculateFee(orderId_);

        // Người mua phải chuyển số tiền băng vs giá của NFT
        if (_feeAmount > 0) {
            // _order.paymentToken: địa chỉ của token thanh toán
            // Chuyển phí tới ví nhận
            IERC20(_order.paymentToken).transferFrom(
                _msgSender(), // Nguoi mua
                feeRecipient, // Địa chỉ nhận phí
                _feeAmount
            );
        }
        // chuyển tiền tới người bán
        IERC20(_order.paymentToken).transferFrom(
            _msgSender(), // Người mua
            _order.seller, // Người bán
            _order.price - _feeAmount
        );
        // Người bán phải chuyển NFT cho người mua
        nftContract.transferFrom(address(this), _msgSender(), _order.tokenId);
        emit OrderMatched(
            orderId_,
            _order.seller,
            _order.buyer,
            _order.tokenId,
            _order.paymentToken,
            _order.price
        );
    }
}
