pragma solidity ^0.8.20;

// SPDX-License-Identifier: MIT

interface IEAIStaking {
    function stakers(uint256) external view returns (address);
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}

struct WalletBalance {
    address user;
    uint256 balance;
}

contract EAIUtilities {
    address private eai = 0x6797B6244fA75F2e78cDFfC3a4eb169332b730cc;
    address private eaistaking = 0x18f8D9193af3bbE7f79100DafC0aa40421f8036E;
    address private tdeai = 0x4342f4BC5375eCaF56fDf8b5294dE5DbC0fBe889;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Get a list of all stakers and checks how much tdEAI each wallet holds
     */
    function stakers()
        public
        view
        returns (uint256 totalStakers, WalletBalance[] memory wallets)
    {
        uint16 count = 0;
        uint16 max = 2000;

        WalletBalance[] memory addresses = new WalletBalance[](max);

        while (count < max) {
            try IEAIStaking(eaistaking).stakers(count) returns (address user) {
                uint256 balance = IERC20(tdeai).balanceOf(user);

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

    /**
     * @dev Checks the EAI and tdEAI holding of a wallet and returns the balance as well as tier wallet falls
     */
    function getTier(address wallet)
        public
        view
        returns (
            string memory,
            uint256,
            uint256
        )
    {
        uint256 eaiBalance = IERC20(eai).balanceOf(wallet);
        uint256 tdeaiBalance = IERC20(tdeai).balanceOf(wallet);

        uint256 total = eaiBalance + tdeaiBalance;

        string memory tier;

        if (total >= 25000 * 10**18) tier = "platinum";
        else if (total >= 5000 * 10**18) tier = "gold";
        else if (total >= 2500 * 10**18) tier = "silver";
        else if (total >= 1250 * 10**18) tier = "bronze";
        else tier = "none";

        return (tier, eaiBalance, total);
    }
}
