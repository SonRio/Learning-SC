// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./IERC20.sol";

contract SampleToken is IERC20 {
    constructor() {
        _totalSupply = 1000000;
        _balance[msg.sender] = 1000000;
    }

    // Trả về tổng lượng token có trong contract (_totalSupply)
    uint256 private _totalSupply;
    // mapping là dạng trả về
    // address là địa chỉ của người gửi token
    // Trả về số lượng token dựa theo giá trị đưa vào
    //mapping[address] => balance
    mapping(address => uint256) private _balance;
    // Lưu trữ giá trị đã approved
    // _allowances truy xuất từ sender, spender
    //_allowances[sender][spender] => _allowances
    mapping(address => mapping(address => uint256)) private _allowances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balance[_owner];
    }

    // Chuyển token từ owner đến spender
    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_balance[msg.sender] >= _value);
        _balance[msg.sender] -= _value;
        _balance[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Chuyển token từ owner đến spender cố định
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_balance[_from] >= _value);
        // Người gửi phải uỷ quyện 1 lượng value lớn hơn hoặc bằng _value
        require(_allowances[_from][msg.sender] >= _value);
        _balance[_from] -= _value;
        _balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // owner sẻ uỷ quyền cho spender 1 lượng token
    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Trả về số lượng token mà owner đã uỷ quyền cho spender
    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        return _allowances[_owner][_spender];
    }
}
