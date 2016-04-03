require 'test_helper'
require 'block_validator'

class BlockValidatorTest < Minitest::Test
  def test_can_validate_a_coinbase_transaction
    skip
    block_chain = BlockChain.new
    headers = {
        parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        transactions_hash: "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654",
        target: "0000100000000000000000000000000000000000000000000000000000000000",
        timestamp: 1450564013,
        nonce: 0,
        hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }

    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n", timestamp: 1450565806588}]}]

    block = Block.new(headers, transactions)
    validator = BlockValidator.new(block, block_chain)
    assert validator.block_valid?
  end
end
