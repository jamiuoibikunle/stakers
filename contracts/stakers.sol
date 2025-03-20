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

contract EAIStakingRanks {
    address private eaistaking;
    address private tdeai;
    address public owner;

    constructor(address _eaistaking, address _tdeai) {
        owner = msg.sender;
        eaistaking = _eaistaking;
        _tdeai = tdeai;
    }

    function stakers()
        public
        view
        returns (uint256 totalStakers, WalletBalance[] memory wallets)
    {
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
