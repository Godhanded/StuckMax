// SPDX-License-Identifier: SEE LICENSE IN LICENSE
/** 
 ██████╗  ██████╗ ██████╗  █████╗ ███╗   ██╗██████╗ 
██╔════╝ ██╔═══██╗██╔══██╗██╔══██╗████╗  ██║██╔══██╗
██║  ███╗██║   ██║██║  ██║███████║██╔██╗ ██║██║  ██║
██║   ██║██║   ██║██║  ██║██╔══██║██║╚██╗██║██║  ██║
╚██████╔╝╚██████╔╝██████╔╝██║  ██║██║ ╚████║██████╔╝
 ╚═════╝  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ 
*/

// solhint-disable-next-line
pragma solidity ^0.8.7;

import "./Isubscription.sol";
import "./IERC721.sol";

error invalidAmount();
error invalidUser();
error only_factory();
error failed();

contract MetastuckMoviesChild {
    uint256 public moviePrice;
    uint256 public netValue;
    uint256 public comunityFunds;
    uint256 public modFunds;
    uint256 public valuebackpercent;
    uint256 public fees;
    uint256 public constant RATE = 1000;

    address public moderator;
    address public dev;
    address public factory;
    address public sub;

    struct Stake {
        uint128 total;
        uint128 lastClaimed;
    }

    IERC721 public nft;

    mapping(address => uint256) private deadline;
    mapping(address => Stake) private stakers;
    mapping(uint256 => address) private owners;

    modifier onlyFactory() {
        if (msg.sender == factory) {
            _;
        } else {
            revert only_factory();
        }
    }

    modifier noContracts() {
        if (tx.origin != msg.sender) revert failed();
        _;
    }

    constructor() {
        factory = msg.sender;
    }

    receive() external payable noContracts
    {
        uint256 amount = msg.value;
        if (
            (amount == moviePrice) && (block.timestamp > deadline[msg.sender])
        ) {
            uint256 stuckFee = (amount * 5) / 100;
            amount -= stuckFee;
            netValue += amount;
            comunityFunds += amount * (valuebackpercent / 100);
            modFunds += (amount - comunityFunds);
            fees += stuckFee;
            deadline[msg.sender] = block.timestamp + 1 days;
        } else {
            revert invalidAmount();
        }
    }

    function pullfunds() external noContracts
    {
        if (msg.sender == moderator) {
            uint256 fee = fees;
            uint256 moderatorValue = modFunds;
            fees -= fee;
            modFunds -= moderatorValue;
            netValue -= (moderatorValue);
            (bool sentMod, ) = payable(moderator).call{value: moderatorValue}(
                ""
            );
            (bool sentStuck, ) = payable(dev).call{value: fee}("");
            if (!(sentMod && sentStuck)) revert failed();
            //require((sentmod && sentStuck),"transaction failed");
        } else {
            revert invalidUser();
        }
    }

    function stake(uint256[] calldata tokenIds) external noContracts
    {
        claimReward(msg.sender);
        for (uint256 i; i < tokenIds.length; ) {
            nft.transferFrom(msg.sender, address(this), tokenIds[i]);

            owners[tokenIds[i]] = msg.sender;
            unchecked {
                ++i;
            }
        }
        stakers[msg.sender].total += uint128(tokenIds.length);
    }

    function unStake(uint256[] calldata tokenIds) external noContracts
    {
        claimReward(msg.sender);
        for (uint256 i; i < tokenIds.length; ) {
            address owner = owners[tokenIds[i]];
            if (owner != msg.sender) revert invalidUser();
            delete owners[tokenIds[i]];
            nft.transferFrom(address(this), owner, tokenIds[i]);

            unchecked {
                ++i;
            }
        }
        stakers[msg.sender].total -= uint128(tokenIds.length);
    }

    function claimReward(address _msgSender) internal 
    {
        uint256 reward = pendingR(_msgSender);
        if (reward>comunityFunds) revert failed();
        stakers[_msgSender].lastClaimed = uint128(block.timestamp);
        comunityFunds-=reward;

        payable(_msgSender).transfer(reward);
    }

    function pendingR(address _addr) internal view returns (uint256) 
    {
        return ((stakers[_addr].total *
            RATE *
            (block.timestamp - stakers[_addr].lastClaimed)) / 1 days);
    }

    function hasAccess(address _addr) external view returns (bool) 
    {
        if (
            (deadline[_addr] >= block.timestamp) ||
            (Isubscription(sub).validTill(_addr) >= block.timestamp)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function getTimeLeft(address addr) external view returns (uint256) 
    {
        return deadline[addr];
    }

    function modBal()external view returns(uint256){
        return modFunds;
    }
    
    function communityBal()external view returns(uint256){
        return comunityFunds;
    }

    function totalStaked() external view returns (uint256) 
    {
        return stakers[msg.sender].total;
    }

    function initialize(
        uint256 _price,
        uint256 _valueBack,
        address _mod,
        address _dev,
        address _sub,
        address _nft
    ) external onlyFactory {
        moviePrice = _price;
        valuebackpercent = _valueBack;
        moderator = _mod;
        dev = _dev;
        sub = _sub;
        nft = IERC721(_nft);
    }
}
