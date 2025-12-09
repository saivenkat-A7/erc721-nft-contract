const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NftCollection", () => {
  let nft, owner, user1, user2;

  beforeEach(async () => {
    [owner, user1, user2] = await ethers.getSigners();

    const NFT = await ethers.getContractFactory("NftCollection");
    nft = await NFT.deploy("SaiNFT", "SNFT", 5); // maxSupply = 5
    await nft.waitForDeployment();
  });

  // -----------------------------
  // 1. Initial configuration
  // -----------------------------
  it("should initialize name, symbol, maxSupply, totalSupply", async () => {
    expect(await nft.name()).to.equal("SaiNFT");
    expect(await nft.symbol()).to.equal("SNFT");
    expect(await nft.maxSupply()).to.equal(5);
    expect(await nft.totalSupply()).to.equal(0);
  });

  // -----------------------------
  // 2. Admin-only mint
  // -----------------------------
  it("should revert when non-admin tries to mint", async () => {
    await expect(
      nft.connect(user1).safeMint(user1.address, 1)
    ).to.be.revertedWith("Not authorized");
  });

  it("should allow admin to mint", async () => {
    await nft.safeMint(user1.address, 1);

    expect(await nft.totalSupply()).to.equal(1);
    expect(await nft.balanceOf(user1.address)).to.equal(1);
    expect(await nft.ownerOf(1)).to.equal(user1.address);
  });

  // -----------------------------
  // 3. Mint beyond max supply
  // -----------------------------
  it("should revert if mint exceeds max supply", async () => {
    await nft.safeMint(user1.address, 1);
    await nft.safeMint(user1.address, 2);
    await nft.safeMint(user1.address, 3);
    await nft.safeMint(user1.address, 4);
    await nft.safeMint(user1.address, 5);

    await expect(
      nft.safeMint(user1.address, 6)
    ).to.be.revertedWith("Max supply reached");
  });

  // -----------------------------
  // 4. Transfers update owners/balances
  // -----------------------------
  it("should transfer a token successfully", async () => {
    await nft.safeMint(user1.address, 10);

    expect(await nft.ownerOf(10)).to.equal(user1.address);

    await nft.connect(user1).transferFrom(user1.address, user2.address, 10);

    expect(await nft.ownerOf(10)).to.equal(user2.address);
    expect(await nft.balanceOf(user1.address)).to.equal(0);
    expect(await nft.balanceOf(user2.address)).to.equal(1);
  });

  // -----------------------------
  // 5. Approvals allow token transfer
  // -----------------------------
  it("should allow approved address to transfer a token", async () => {
    await nft.safeMint(user1.address, 20);

    await nft.connect(user1).approve(user2.address, 20);

    await nft.connect(user2).transferFrom(user1.address, user2.address, 20);

    expect(await nft.ownerOf(20)).to.equal(user2.address);
  });

  // -----------------------------
  // 6. Operator approvals
  // -----------------------------
  it("should allow operator to transfer tokens", async () => {
    await nft.safeMint(user1.address, 30);
    await nft.safeMint(user1.address, 31);

    await nft.connect(user1).setApprovalForAll(user2.address, true);

    await nft.connect(user2).transferFrom(user1.address, user2.address, 30);
    await nft.connect(user2).transferFrom(user1.address, user2.address, 31);

    expect(await nft.balanceOf(user2.address)).to.equal(2);
  });

  // -----------------------------
  // 7. Reverts for non-existent tokens
  // -----------------------------
  it("should revert for non-existent token transfer", async () => {
    await expect(
      nft.transferFrom(user1.address, user2.address, 999)
    ).to.be.revertedWith("Token does not exist");
  });

  // -----------------------------
  // 8. Event emission checks
  // -----------------------------
  it("should emit Transfer event on mint", async () => {
    await expect(nft.safeMint(user1.address, 40))
      .to.emit(nft, "Transfer")
      .withArgs(ethers.ZeroAddress, user1.address, 40);
  });

  it("should emit Approval event on approval", async () => {
    await nft.safeMint(user1.address, 50);

    await expect(nft.connect(user1).approve(user2.address, 50))
      .to.emit(nft, "Approval")
      .withArgs(user1.address, user2.address, 50);
  });

  it("should emit ApprovalForAll event", async () => {
    await expect(
      nft.connect(user1).setApprovalForAll(user2.address, true)
    )
      .to.emit(nft, "ApprovalForAll")
      .withArgs(user1.address, user2.address, true);
  });

  // -----------------------------
  // 9. safeTransferFrom
  // -----------------------------
  it("should perform safeTransferFrom", async () => {
    await nft.safeMint(user1.address, 60);

    await nft
      .connect(user1)
      .safeTransferFrom(user1.address, user2.address, 60);

    expect(await nft.ownerOf(60)).to.equal(user2.address);
  });
});
