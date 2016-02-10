# Some protocols

### Block 0
1. How do we know we've reached the end of the block chain?
  * Either the parent_hash = "000.....0000"
  * or maybe there doesn't exist a block in the block chain with that hash

2. What is the target?
  * Doesn't matter: Make sure your block hash is less than your target

### What makes a block valid? Add those blocks to the chain.
1. Timestamp later than last block in the chain
2. Target is valid: Talk about this later (frequency and truncation value)
3. Coinbase transaction amount is not more than allowed amount
4. Parent hash of the block is the last block on the block chain
5. Not more than one coinbase transaction
6. First transaction is a coinbase(?)
7. Transactions all valid...they will verify, and have enough money.
8. Block will hash correctly.
9. Something about timestamps on transactions

### The Miner
1. I have a block chain. who validates everything? Do I validate before I can add?
* Validate on the chain now...
* What does it mean to validate a transaction?
2. I have a wallet. I have a public key that I when I mine, I can send coins to.
3. I can take transaction sent via JSON, and create a legit block from them

### Wallet Client


### Other thoughts
1. Valid blocks:
2. Invalid blocks:
3. Interface to sign transactions
4. Parse Jason into a block
5. Parse JSON into transaction?
6. Block parser
7. Block generator (miner)

"0a7ebfdbf0375be81641dbaf6ac9f862ba4f0d5e1cab600c8ce79248dfb9a653"
