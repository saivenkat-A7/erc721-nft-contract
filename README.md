# ERC-721 NFT Smart Contract

This project implements an ERC-721–compatible NFT Collection with admin-only minting, safe transfers, approvals, operator approvals, and max supply restriction.  
The project is fully tested using Hardhat and supports automated execution using Docker.

---

## 🚀 Features

- Fully ERC-721 compliant  
- Admin-only safe minting (`safeMint`)  
- Max supply protection  
- `transferFrom` and `safeTransferFrom` supported  
- Token-level `approve` and operator-level approvals  
- Event emission: `Transfer`, `Approval`, `ApprovalForAll`  
- Complete automated test suite  
- Docker support (no need to install Node.js / Hardhat locally)

---




---

# 🛠 Running the Project

You can run this project in **two ways**:

---

#  1. Run Locally (Without Docker)

### Install Dependencies

npm install

npx hardhat compile

npx hardhat test

# 2. Run Using Docker (Recommended)
## Build Docker Image
docker build -t nft-contract .

## Run Tests
 docker run --rm nft-contract

## 🧪 Test Coverage

The test suite verifies:

- Contract initialization
- Admin-only mint restrictions
- Successful minting and balance updates
- Max supply limit enforcement
- Transfers (`transferFrom`, `safeTransferFrom`)
- Approvals and operator approvals
- Reverts for invalid actions
- Proper event emission (`Transfer`, `Approval`, `ApprovalForAll`)
- Safe transfers

---

## 🔧 Tools & Versions

- Solidity: 0.8.20
- Hardhat
- Mocha & Chai
- Node.js (inside Docker)
- Docker / Docker Desktop
