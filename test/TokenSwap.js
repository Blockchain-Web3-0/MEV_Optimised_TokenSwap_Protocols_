const { expect } = require("chai");

describe("TokenSwap", function() {
    it("Should perform a token swap", async function() {
        const Token = await ethers.getContractFactory("Token");
        const token1 = await Token.deploy();
        const token2 = await Token.deploy();

        const TokenSwap = await ethers.getContractFactory("TokenSwap");
        const swap = await TokenSwap.deploy(token1.address, token2.address);

        await token1.approve(swap.address, 100);
        await token2.approve(swap.address, 100);
        await swap.swap(token1.address, token2.address, 50);

        expect(await token1.balanceOf(swap.address)).to.equal(50);
        expect(await token2.balanceOf(swap.address)).to.equal(50);
    });
});