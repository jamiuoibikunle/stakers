pragma solidity ^0.8.20;

// SPDX-License-Identifier: MIT

interface IEAIStaking {
    function stakers(uint256) external view returns (address);
}

interface ITokenVestingPlans {
    function lockedBalances(address, address) external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}

struct WalletBalance {
    address user;
    uint256 balance;
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}

contract EAIUtilities is Ownable {
    address private eai = 0x6797B6244fA75F2e78cDFfC3a4eb169332b730cc;
    address private staking = 0x18f8D9193af3bbE7f79100DafC0aa40421f8036E;
    address private tdeai = 0x4342f4BC5375eCaF56fDf8b5294dE5DbC0fBe889;
    address private hedgey = 0x2CDE9919e81b20B4B33DD562a48a84b54C48F00C;
    string public name = "EAIUtilities";

    /**
    @dev this function updates contract addresses for eai, staking and tdeai. Only the owner is allowed and all addresses have to be provided
    */
    function updateContractAddresses(
        address _eai,
        address _staking,
        address _tdeai
    ) public onlyOwner {
        eai = _eai;
        tdeai = _tdeai;
        staking = _staking;
    }

    /**
     * @dev Get a list of all stakers and checks how much tdEAI each wallet holds. Returns an unsorted list
     */
    function getStakers()
        public
        view
        returns (uint256 totalStakers, WalletBalance[] memory wallets)
    {
        uint16 count = 0;
        uint16 max = 2000;

        WalletBalance[] memory addresses = new WalletBalance[](max);

        while (count < max) {
            try IEAIStaking(staking).stakers(count) returns (address user) {
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
            string memory tier,
            uint256 unstaked_balance,
            uint256 staked_balance,
            uint256 vested_balance,
            uint256 total_balance
        )
    {
        uint256 unstaked = IERC20(eai).balanceOf(wallet);
        uint256 staked = IERC20(tdeai).balanceOf(wallet);
        uint256 vested = ITokenVestingPlans(hedgey).lockedBalances(wallet, eai);

        uint256 total = unstaked + staked + vested;

        string memory holding;

        if (total >= 25000 * 10**18) holding = "platinum";
        else if (total >= 5000 * 10**18) holding = "gold";
        else if (total >= 2500 * 10**18) holding = "silver";
        else if (total >= 1250 * 10**18) holding = "bronze";
        else holding = "none";

        return (holding, unstaked, staked, vested, total);
    }
}
