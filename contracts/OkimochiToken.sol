// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./Queue.sol";

struct Deposit {
    uint256 value;
    uint256 expiration;
    address from;
}

contract OkimochiToken is IERC20, Pausable, ReentrancyGuard, Ownable {
    using QueueLib for QueueLib.Queue;

    mapping(address => QueueLib.Queue) private _depositIds;
    mapping(uint256 => Deposit) private _deposits;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 _numDeposits;
    uint256 private _supply;

    function revertWithMessage(string memory reason) private pure {
        assembly {
            revert(add(32, reason), mload(reason))
        }
    }

    function name() public pure returns (string memory) {
        return "Okimochi";
    }

    function symbol() public pure returns (string memory) {
        return "OKT";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _supply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        QueueLib.Queue storage que = _depositIds[_owner];
        balance = 0;
        for (uint256 i = 0; i < que.size; i++) {
            uint256 index;
            unchecked {
                index = que.front + i;
            }
            Deposit memory dep = _deposits[que.data[index]];

            if (dep.expiration > block.timestamp) {
                balance += dep.value;
            }
        }
    }

    function transfer(address _to, uint256 _value)
        public
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        return transferFrom(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        nonReentrant
        whenNotPaused
        returns (bool success)
    {
        require(msg.sender == _from || allowance(_from, _to) >= _value, "Not enough allowance.");

        QueueLib.Queue storage que = _depositIds[_from];
        uint256 remain = _value;
        Deposit memory dep;

        while (remain > 0) {
            dep = _deposits[que.frontValue()];

            if (dep.expiration < block.timestamp) {
                que.deque();
                continue;
            }

            if (dep.value > remain) {
                dep.value -= remain;
                break;
            }

            remain -= dep.value;

            if (que.size < 2) {
                revertWithMessage("Not enough balance.");
            }

            que.deque();
        }

        dep.expiration = block.timestamp + 60 * 60 * 24 * 14;
        dep.value = _value;
        _deposits[_numDeposits] = dep;
        _depositIds[_to].enque(_numDeposits);
        _numDeposits++;

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _allowances[msg.sender][_spender] += _value;
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        remaining = _allowances[_owner][_spender];
    }

    function _mint(uint256 _value, address _to) public whenNotPaused onlyOwner {
        Deposit memory dep;
        dep.expiration = block.timestamp + 60 * 60 * 24 * 14;
        dep.value = _value;
        _deposits[_numDeposits] = dep;
        _depositIds[_to].enque(_numDeposits);
        _numDeposits++;
        _supply += _value;
    }
}
