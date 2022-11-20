pragma solidity 0.8;
//SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract decorationStake is Context, Ownable {
    struct editedSlots {
        uint256 pigId;
        uint256[] slot;
    }
    event stake(address _address, uint256 _pigId, uint256 _slot, uint256 _decorationId);
    event unstake(address _address, uint256 _pigId, uint256 _slot, uint256 _decorationId);
    IERC1155 decorations;
    IERC721 cryptoPigs;
    address tamagotchiRegisterer;
    //address => pigId => slot => decoration ID
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) pig;
    mapping(address => editedSlots[]) editedPigs;
    mapping(address => mapping(uint256 => uint256)) unlockTime;
    
    constructor(address _decorations, address _cryptoPigs) {
        decorations = IERC1155(_decorations);
        cryptoPigs = IERC721(_cryptoPigs);
    }

    function emergencyWithdraw(uint256[] memory _tokenIds, uint256[] memory _amounts) public onlyOwner {
        decorations.safeBatchTransferFrom(address(this), _msgSender(), _tokenIds, _amounts, "");
    }

    modifier isApproved {
        require(_msgSender() == tamagotchiRegisterer, 'Caller not approved');
        _;
    }
    function setApproved(address _address) public onlyOwner {
        tamagotchiRegisterer = _address;
    }

    function stakeIn(uint256 _pigId, uint256 _slot, uint256 _decorationId) public {
        //require(cryptoPigs.ownerOf(_pigId) == _msgSender(), 'Not owner of pig');
        require(pig[_msgSender()][_pigId][_slot] == 0, 'Slot already taken');
        decorations.safeTransferFrom(_msgSender(), address(this), _decorationId, 1, "");
        pig[_msgSender()][_pigId][_slot] = _decorationId;
        emit stake(_msgSender(), _pigId, _slot, _decorationId);

        bool found;
        bool pigIdFound;
        for(uint i; i < editedPigs[_msgSender()].length; i++) {
            if (editedPigs[_msgSender()][i].pigId == _pigId) {
                pigIdFound = true;
                for(uint j; j < editedPigs[_msgSender()][i].slot.length; j++) {
                    if(editedPigs[_msgSender()][i].slot[j] == _slot){
                        found = true;
                        break;
                    }
                }
                if(!found) {
                    editedPigs[_msgSender()][i].slot.push(_slot); //NEEDS CHANGING
                }
                break;
            }
        }
        if (!found && !pigIdFound) {
            editedPigs[_msgSender()].push(editedSlots(_pigId, new uint256[](0)));
            editedPigs[_msgSender()][editedPigs[_msgSender()].length - 1].slot.push(_slot);
        }
    }
    function stakeOut(uint256 _pigId, uint256 _slot) public {
        require(block.timestamp >= unlockTime[_msgSender()][_slot], 'Asset locked');
        require(pig[_msgSender()][_pigId][_slot] != 0, 'Token not staked');
        uint256 decorationId = pig[_msgSender()][_pigId][_slot];
        pig[_msgSender()][_pigId][_slot] = 0;
        decorations.safeTransferFrom(address(this), _msgSender(), decorationId, 1, "");
        emit unstake(_msgSender(), _pigId, _slot, decorationId);
    }

    function getPigDecorations(address _address, uint256 _pigId, uint256 _slot) public view returns(uint256) {
        return pig[_address][_pigId][_slot];
    }

    function retrieveAssets() public { //Probs needs to be edited to make more readable
        for(uint i; i < editedPigs[_msgSender()].length; i++) {
            if(cryptoPigs.ownerOf(editedPigs[_msgSender()][i].pigId) == _msgSender()) {
                for(uint j; j < editedPigs[_msgSender()][i].slot.length; j++) {
                    if((pig[_msgSender()][editedPigs[_msgSender()][i].pigId][editedPigs[_msgSender()][i].slot[j]] != 0) && (block.timestamp >= unlockTime[_msgSender()][editedPigs[_msgSender()][i].slot[j]])) {
                        stakeOut(editedPigs[_msgSender()][i].pigId, editedPigs[_msgSender()][i].slot[j]);
                    }
                }
            }
        } 
    }

    function getAllEditedAssets(address _user) public view returns(editedSlots[] memory) {
        return editedPigs[_user];
    }
}
