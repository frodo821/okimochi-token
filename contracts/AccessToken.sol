// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract AccessToken is ERC721("Okimochi Token Voter Access Token", "OKTC"), Ownable {
    uint256 private _nextTokenId;
    string private _uri = "";

    function _baseURI() internal view override returns (string memory) {
        return _uri;
    }

    function setBaseURI(string calldata _nextURI) external {
        _uri = _nextURI;
    }

    function mint(address _to) external onlyOwner {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _mint(_to, tokenId);
    }

    function deprive(uint256 _tokenId) external onlyOwner {
        _burn(_tokenId);
    }

    function renownce(uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender, "Not a owner of the token.");
        _burn(_tokenId);
    }
}
