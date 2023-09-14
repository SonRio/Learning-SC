const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

// describe("Hello World", function () {
//   const message = "Hello World !!!";
//   const newMessage = "Bye World !!!";
//   it("Should return incorrected", async function () {
//     const HelloWorld = await ethers.getContractFactory("HelloWorld");
//     const helloWorld = await HelloWorld.deploy(message);
//     expect(await helloWorld.printHelloWorld()).to.be.equal(message);
//     await helloWorld.updateHelloWorld(newMessage);
//     expect(await helloWorld.printHelloWorld()).to.be.equal(newMessage);
//   });
// });
