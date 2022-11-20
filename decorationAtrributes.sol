pragma solidity 0.8;
//SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract decorationAttributes is Context, Ownable {
    mapping(uint256 => mapping(string => string)) data;

    function setAttributes(uint256[] calldata _decorationIds, string[][] calldata _attributeName, string[][] calldata _attributeValue ) public onlyOwner {
         for(uint i; i < _decorationIds.length; i++) {
             for(uint j; j < _attributeName[i].length; j++) {
                 data[_decorationIds[i]][_attributeName[i][j]] = _attributeValue[i][j];
             }
         }
    }

    function getAttribute(uint256 _decorationId, string calldata _attributeName) public view returns(string memory) {
        return data[_decorationId][_attributeName];
    }
}