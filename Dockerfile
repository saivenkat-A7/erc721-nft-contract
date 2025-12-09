# ----------------------------------------------------
# Base image: Lightweight Node 18 environment
# ----------------------------------------------------
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# ----------------------------------------------------
# Copy package.json + package-lock.json first
# (This allows Docker caching to speed up builds)
# ----------------------------------------------------
COPY package*.json ./

# Install all dependencies (Hardhat, Chai, Ethers, etc.)
RUN npm install

# ----------------------------------------------------
# Copy entire project (contracts, tests, config, scripts)
# ----------------------------------------------------
COPY . .

# ----------------------------------------------------
# Compile the smart contracts
# ----------------------------------------------------
RUN npx hardhat compile

# ----------------------------------------------------
# Default command: run full test suite
# When you run `docker run nft-contract`, tests run automatically
# ----------------------------------------------------
CMD ["npx", "hardhat", "test"]
