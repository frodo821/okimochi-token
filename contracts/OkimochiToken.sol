// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./lib/Queue.sol";

struct Deposit {
    uint256 value;
    uint256 expiration;
    address from;
}

struct Expiration {
    uint256 value;
    uint256 expiration;
}

contract OkimochiToken is IERC20, ReentrancyGuard, Ownable {
    using QueueLib for QueueLib.Queue;

    mapping(address => QueueLib.Queue) private _depositIds;
    mapping(uint256 => Deposit) private _deposits;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 _numDeposits;
    uint256 private _lastExpired;

    function revertWithMessage(string memory reason) private pure {
        assembly {
            revert(add(32, reason), mload(reason))
        }
    }

    function name() external pure returns (string memory) {
        return "Okimochi";
    }

    function symbol() external pure returns (string memory) {
        return "OKT";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256 supply) {
        supply = 0;

        for (uint256 i = _lastExpired; i < _numDeposits; i++) {
            if (_deposits[i].expiration < block.timestamp) {
                continue;
            }

            supply += _deposits[i].value;
        }
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        QueueLib.Queue storage que = _depositIds[_owner];
        balance = 0;
        for (uint256 i = 0; i < que.size; i++) {
            uint256 index;
            unchecked {
                index = que.front + i;
            }
            Deposit memory dep = _deposits[que.data[index]];

            if (dep.expiration >= block.timestamp) {
                balance += dep.value;
            }
        }
    }

    function transfer(address _to, uint256 _value)
        external
        nonReentrant
        returns (bool)
    {
        return transferFrom(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        nonReentrant
        returns (bool success)
    {
        require(msg.sender == _from || allowance(_from, _to) >= _value, "Not enough allowance.");

        QueueLib.Queue storage que = _depositIds[_from];
        uint256 remain = _value;
        Deposit memory dep;

        while (remain > 0) {
            uint256 index = que.frontValue();
            dep = _deposits[index];

            if (dep.expiration < block.timestamp) {
                _lastExpired = que.frontValue();
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
        dep.from = _from;
        _deposits[_numDeposits] = dep;
        _depositIds[_to].enque(_numDeposits);
        _numDeposits++;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool success) {
        _allowances[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        remaining = _allowances[_owner][_spender];
    }

    function _mint(uint256 _value, address _to) external onlyOwner {
        Deposit memory dep;
        dep.expiration = block.timestamp + 60 * 60 * 24 * 14;
        dep.value = _value;
        dep.from = address(0);

        emit Transfer(address(0), _to, _value);

        _deposits[_numDeposits] = dep;
        _depositIds[_to].enque(_numDeposits);
        _numDeposits++;
    }

    function expirations(address _owner)
        external
        view
        returns (Expiration[] memory result)
    {
        QueueLib.Queue storage que = _depositIds[_owner];
        Expiration[] memory exps = new Expiration[](que.size);
        uint256 nonZero = 0;

        for (uint256 i = 0; i < que.size; i++) {
            Expiration memory exp;
            Deposit storage dep = _deposits[que.data[i + que.front]];

            if (dep.expiration < block.timestamp || dep.value == 0) {
                continue;
            }

            nonZero++;
            exp.value = dep.value;
            exp.expiration = dep.expiration;

            exps[i] = exp;
        }

        result = new Expiration[](nonZero);
        uint256 j = 0;

        for (uint256 i = 0; i < que.size; i++) {
            if (exps[i].expiration < block.timestamp || exps[i].value == 0) {
                continue;
            }

            result[j] = exps[i];
            j++;
        }
    }
}
