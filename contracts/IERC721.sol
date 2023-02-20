//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IERC721 {
    function safeTransferFrom(
        address sender,
        address nft,
        uint nftId
    ) external;
        
    function transferFrom(
        address,
        address,
        uint 
    ) external;
}