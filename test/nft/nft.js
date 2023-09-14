const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Petty NFT", function () {
  let [accountA, accountB, accountC] = [];
  let petty;
  let address0 = "0x0000000000000000000000000000000000000000";
  let uri = "sampleuri.com/";
  beforeEach(async () => {
    [accountA, accountB, accountC] = await ethers.getSigners();
    const Petty = await ethers.getContractFactory("Petty");
    petty = await Petty.deploy();
  });

  describe("mint", function () {
    it("Should revert if mint to zero address", async function () {
      await expect(petty.mint(address0)).to.be.revertedWith(
        "ERC721: mint to the zero address"
      );
    });
    it("Should mint token correctly", async function () {
      const mintTx = await petty.mint(accountA.address);
      await expect(mintTx)
        .to.be.emit(petty, "Transfer")
        .withArgs(address0, accountA.address, 1);
      // balanceOf trả về value of account
      expect(await petty.balanceOf(accountA.address)).to.be.equal(1);
      // ownerOf trả về address of account theo tokenID
      expect(await petty.ownerOf(1)).to.be.equal(accountA.address);
    });
  });

  describe("updateBaseTokenURI", function () {
    it("Should update Base Token URI correctly", async function () {
      // Thực hiện mint trước để có uri rồi mới update
      await petty.mint(accountA.address);
      await petty.updateBaseTokenURI(uri);
      expect(await petty.tokenURI(1)).to.be.equal(uri + "1");
    });
  });
});
