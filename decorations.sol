pragma solidity 0.8;
//SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract decorations is Context, Ownable, ERC1155 {

    string private _uri;
    mapping(uint256 => string) private _batchUri;

    constructor() ERC1155("Piggiesss!!!") {

    }
    function mint(address _to, uint256 _id, uint256 _amount) public onlyOwner {
        _mint(_to, _id, _amount, "");
    }
    function mintBatch(address _to, uint256[] memory _ids, uint256[] memory _amounts) public onlyOwner {
        _mintBatch(_to, _ids, _amounts, "");
    }


    function setURI(string memory _newUri) public onlyOwner {
        _uri = _newUri;
    }
    function setURI(uint256 _tokenIdFrom, uint256 _tokenIdTo, string memory _newUri) public onlyOwner {
        for(uint256 i = _tokenIdFrom; i <= _tokenIdTo; i++) {
            _batchUri[i] = _newUri;
        }
    }
    function uri(uint256 _tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(_uri, _batchUri[_tokenId], "/", Strings.toString(_tokenId)));
    }
    function name() public pure returns (string memory) {
        return "Decorations";
    }

}