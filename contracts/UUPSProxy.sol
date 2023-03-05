// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UUPSUpgradeProxy is ERC1967Proxy {
    constructor(address _logic, bytes memory _data) ERC1967Proxy(_logic, _data) payable {}
}
