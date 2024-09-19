pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSwap {
    struct Commit {
        address fromToken;
        address toToken;
        uint256 amount;
        uint256 revealTime;
    }

    mapping(address => Commit) public commitments;
    uint256 public commitRevealDelay = 5 minutes;

    function commitSwap(address fromToken, address toToken, uint256 amount) external {
        commitments[msg.sender] = Commit({
            fromToken: fromToken,
            toToken: toToken,
            amount: amount,
            revealTime: block.timestamp + commitRevealDelay
        });
    }

    function revealSwap() external {
        Commit memory commit = commitments[msg.sender];
        require(block.timestamp >= commit.revealTime, "Reveal time not reached");
        require(commit.fromToken != address(0), "No commitment found");

        IERC20(commit.fromToken).transferFrom(msg.sender, address(this), commit.amount);
        uint256 swapAmount = getSwapAmount(commit.fromToken, commit.toToken, commit.amount);
        IERC20(commit.toToken).transfer(msg.sender, swapAmount);

        delete commitments[msg.sender]; // Clean up after the reveal
    }

    function getSwapAmount(address fromToken, address toToken, uint256 amount) public pure returns (uint256) {
        return amount; // 1:1 ratio for simplicity
    }
    function batchSwap(
    address[] calldata fromTokens,
    address[] calldata toTokens,
    uint256[] calldata amounts,
    uint256[] calldata gasPrices
) external {
    require(fromTokens.length == toTokens.length && toTokens.length == amounts.length && gasPrices.length == amounts.length, "Input arrays must be of equal length");
    
    // Sort transactions by gas price in ascending order
    for (uint256 i = 0; i < fromTokens.length; i++) {
        for (uint256 j = i + 1; j < fromTokens.length; j++) {
            if (gasPrices[i] > gasPrices[j]) {
                // Swap the order of transactions
                (fromTokens[i], fromTokens[j]) = (fromTokens[j], fromTokens[i]);
                (toTokens[i], toTokens[j]) = (toTokens[j], toTokens[i]);
                (amounts[i], amounts[j]) = (amounts[j], amounts[i]);
                (gasPrices[i], gasPrices[j]) = (gasPrices[j], gasPrices[i]);
            }
        }
    }

    // Execute the swaps in the sorted order
    for (uint256 i = 0; i < fromTokens.length; i++) {
        swap(fromTokens[i], toTokens[i], amounts[i]);
    }
}
uint256 public rewardPool;

function swap(address fromToken, address toToken, uint256 amount) public {
    uint256 fee = (amount * 5) / 1000; // 0.5% fee
    uint256 swapAmount = amount - fee;

    IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
    IERC20(toToken).transfer(msg.sender, swapAmount);
    
    // Add fee to the reward pool
    rewardPool += fee;
}

function claimRewards(address validator) external {
    // Logic for validators to claim rewards, based on some participation logic
    uint256 reward = calculateValidatorReward(validator);
    IERC20(token1).transfer(validator, reward); // Reward in token1 for simplicity
}

function calculateValidatorReward(address validator) public view returns (uint256) {
    // Placeholder: In the real world, base this on validator participation in securing the network
    return rewardPool / 10; // Give 10% of the pool as reward
}


}
