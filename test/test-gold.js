const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GOLD", function () {
  let [accountA, accountB, accountC] = [];
  let token;
  let amount = ethers.utils.parseUnits("100", "ether");
  let address0 = "0x0000000000000000000000000000000000000000";
  let totalSupply = ethers.utils.parseUnits("100000000", "ether");
  beforeEach(async () => {
    [accountA, accountB, accountC] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("Gold");
    token = await Token.deploy();
  });

  // Test common
  describe("common", function () {
    it("total supply should return right value", async function () {
      expect(await token.totalSupply()).to.be.equal(totalSupply);
    });
    it("balance of account A should return right value", async function () {
      expect(await token.balanceOf(accountA.address)).to.be.equal(totalSupply);
    });
    it("balance of account B should return right value", async function () {
      expect(await token.balanceOf(accountB.address)).to.be.equal(0);
    });
    it("allowance of account A should return right value", async function () {
      expect(
        await token.allowance(accountA.address, accountB.address)
      ).to.be.equal(0);
    });
  });

  describe("pause", function () {
    // 1 - Phai co PAUSER_ROLE
    it("Should reverted when has not PAUSER_ROLE", async function () {
      await expect(token.connect(accountB).pause()).to.be.reverted;
    });
    // 2 - SC chua thuc hien func pause()
    // it("Should reverted when has been PAUSED", async function () {
    //   await token.pause();
    //   await expect(token.pause()).to.be.rejectedWith("Pausable: paused");
    // });
    // 3 - Thuc hien dung
    it("should pause contract correctly", async function () {
      const pauseTX = await token.pause();
      await expect(pauseTX)
        .to.be.emit(token, "Paused")
        .withArgs(accountA.address);
      await expect(token.transfer(accountB.address, amount)).to.be.revertedWith(
        "Pausable: paused"
      );
    });
  });

  describe("unpause", function () {
    beforeEach(async () => {
      token.pause();
    });
    // 1 - Phai co PAUSER_ROLE
    it("Should reverted when has not PAUSER_ROLE", async function () {
      await expect(token.connect(accountB).unpause()).to.be.reverted;
    });
    // 2 - SC chua thuc hien func unpause()
    // it("Should reverted when has been unpause", async function () {
    //   await token.unpause();
    //   await expect(token.unpause()).to.be.rejectedWith("Pausable: not paused");
    // });
    // 3 - Thuc hien dung
    it("Should unpause contract correctly", async function () {
      const unpauseTX = await token.unpause();
      await expect(unpauseTX)
        .to.be.emit(token, "Unpaused")
        .withArgs(accountA.address);
      const transferTx = await token.transfer(accountB.address, amount);
      await expect(transferTx)
        .to.emit(token, "Transfer")
        .withArgs(accountA.address, accountB.address, amount);
    });
  });

  describe("addToBlacklist", async function () {
    // 1 - Co trong blacklist
    it("Should reverted if it was on blacklist", async function () {
      await token.addToBlacklist(accountB.address);
      await expect(token.addToBlacklist(accountB.address)).to.be.revertedWith(
        "Gold: Account was exited"
      );
    });
    // 2 - Khong tu them chinh minh vao blacklist
    it("Should reverted in case add sender to blacklist", async function () {
      await expect(token.addToBlacklist(accountA.address)).to.be.revertedWith(
        "Gold: can not add sender to black list"
      );
    });
    // 3 - Phai la Admin
    // it("Should reverted if it is not admin role", async function () {
    //   await expect(
    //     token.connect(accountB.address).addToBlacklist(accountC.address)
    //   ).to.be.revertedWith("Gold: MUST Admin");
    // });
    // 4 - Thuc hien dung
    it("Should add to blacklist correctly", async function () {
      await token.transfer(accountB.address, amount);
      await token.transfer(accountC.address, amount);
      await token.addToBlacklist(accountB.address);
      await expect(
        token.connect(accountB).transfer(accountC.address, amount)
      ).to.be.revertedWith("Gold: Account was on BLACKLIST");
      await expect(
        token.connect(accountC).transfer(accountB.address, amount)
      ).to.be.revertedWith("Gold: Account was on BLACKLIST");
    });
  });

  describe("removeFromBlacklist", async function () {
    beforeEach(async () => {
      await token.transfer(accountB.address, amount);
      await token.transfer(accountC.address, amount);
      await token.addToBlacklist(accountB.address);
    });
    // 1 -Khong Co trong blacklist
    it("Should reverted if it was not on blacklist", async function () {
      await token.removeFromBlacklist(accountB.address);
      await expect(
        token.removeFromBlacklist(accountB.address)
      ).to.be.revertedWith("Gold: Account is not exited");
    });
    // 2 - Phai la Admin
    // it("should revert if not admin role", async function () {
    //   await expect(
    //     token.connect(accountB.address).removeFromBlacklist(accountC.address)
    //   ).to.be.reverted;
    // });
    // 3 - Thuc hien dung
    it("Should remove from blacklist correctly", async function () {
      await token.removeFromBlacklist(accountB.address);
      let transferTx = await token.transfer(accountB.address, amount);
      await expect(transferTx)
        .to.emit(token, "Transfer")
        .withArgs(accountA.address, accountB.address, amount);
    });
  });
});
