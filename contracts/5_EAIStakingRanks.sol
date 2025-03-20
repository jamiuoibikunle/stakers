// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEAIStaking {
    function stakers(uint256) external view returns (address);
}

interface ITdEAI {
    function balanceOf(address) external view returns (uint256);
}

struct WalletBalance {
    address user;
    uint256 balance;
}

contract Ranks {
    address private eaistaking = 0xDa41c4Ff79C9809c8EE7B5A00Cb28C34049d3404;
    address private tdeai = 0x55eE7ea10fd88DC9fa7Bb1fb541083A6d5bCacd2;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function stakers() public view returns (uint256, WalletBalance[] memory) {
        uint16 count = 0;
        uint16 max = 500;

        WalletBalance[] memory addresses = new WalletBalance[](max);

        while (count < max) {
            try IEAIStaking(eaistaking).stakers(count) returns (address user) {
                uint256 balance = ITdEAI(tdeai).balanceOf(user);

                addresses[count] = WalletBalance(user, balance);
                count++;
            } catch {
                break;
            }
        }

        WalletBalance[] memory result = new WalletBalance[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = addresses[i];
        }

        return (count, result);
    }
}
