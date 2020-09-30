# Bifrost
Cross-Chain Wrapped Tokens. The Einstein-Rosen Blockchain Bridge.

# Inspiration
We want XTZ holders to be able to fully participate in defi lending while still earning staking rewards.
Stake on Tezos and lend on Ethereum for double passive income!

# What it does
The app has 2 main functions: Mint and Burn. Mint Tezos users deposit XTZ into a smart contract that acts as a vault to hold and stake funds. It also whitelists an Ethereum address that is allowed to mint bXTZ tokens representing the users share in that vault. The tokens are minted on Ethereum and can be freely traded and used to make lending or market maker fees on platforms like Uniswap or Aave.

Burn To withdraw XTZ a user burns bXTZ tokens on Ethereum and whitelists a Tezos account. From the Tezos account the user withdraws.

# How it is built
Tezos smart contract acting as the vault was written in smartpy. The Tezos chainlink oracle contract was built off of the examples from the cryptonomic team. When the user wants to withdraw, a request is sent to the oracle, which uses web3 to search for burn events matching the users tezos address in the bXTZ token contact on ethereum.

On the Ethereum side, the bXTZ contract is a mintable, burnable, chainlinked erc20 token. When tokens are burned, the contract emits a Burn event with the amount of burned tokens and a whitelisted Tezos account, allowed to withdraw XTZ.

The ethereum chainlink oracle is used to determine the amount of XTZ deposited on Tezos before minting bXTZ on ethereum. It does so by calling the TzStats api.

Needs Metamask and Thanos wallets. Ethereum wrapped token is deployed on Kovan test.

Tezos = Vault Chainlink = Bridge Ethereum = Wrapped Token

# Prerequisites before testing
Metamask with Ether (kovan testnet)
Thanos wallet with Tezos on Carthage Testnet
