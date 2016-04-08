require 'test_helper'
require 'block'

class BlockTest < Minitest::Test
  def test_can_create_a_block_from_JSON_input
    json_block = File.read(File.expand_path('support/sample_block.txt', __dir__))
    block = Block.from_json(json_block)
    txn = block.transactions.first

    assert_equal "00000018d48278c3c5bca65b181c4af323b929d8fe0cb60324026abedd281c68", block.hash
    assert_equal "00000036964228a8c06f858a6e03367db795aa25a543343ac8951e4c58674f41", block.parent_hash
    assert_equal 1450592320, block.timestamp
    assert_equal "0000006a16d4b074bf923154046e2d7ef213cc668fadc5bf0fc0000000000000", block.target
    assert_equal 104414872, block.nonce
    assert_equal "688d3e8a61ea1b77dbcca2f8fea73e47cf11f74beecd4f635f23333d25333a23", block.transactions_hash

    assert_equal 1, block.transactions.count
    assert_kind_of Transaction, txn
    assert_equal 1450592320607, txn.timestamp
    assert_equal "6124f26a956f6ee9e967b99edadca850079f3d4007b4e9a2c831ad73c5590a7b", txn.hash
    assert_equal [], txn.inputs
    assert_equal 1, txn.outputs.length
    c = {amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}
    assert_equal c, txn.outputs.first
  end

  def test_can_create_a_block_from_headers_and_transactions
    headers = {
        parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        transactions_hash: "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654",
        target: "0000100000000000000000000000000000000000000000000000000000000000",
        timestamp: 1450564013,
        nonce: 0,
        hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }

    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}]}].map { |txn|
      Transaction.new(txn[:inputs], txn[:outputs])
    }

    b = Block.new(headers, transactions)

    assert_equal headers[:parent_hash], b.parent_hash
    assert_equal headers[:transactions_hash], b.transactions_hash
    assert_equal headers[:target], b.target
    assert_equal headers[:timestamp], b.timestamp
    assert_equal headers[:nonce], b.nonce
    assert_equal headers[:hash], b.hash

    assert_equal [], b.transactions.first.inputs
    assert_equal [{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}], b.transactions.first.outputs
  end

  def test_can_change_nonce_and_hash
    headers = {
      parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
      transactions_hash: "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654",
      target: "0000100000000000000000000000000000000000000000000000000000000000",
      timestamp: 1450564013,
      nonce: 0,
      hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }
    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}]}].map { |txn|
      Transaction.new(txn[:inputs], txn[:outputs])
    }

    b = Block.new(headers, transactions)

    b.increment_nonce
    assert_equal 1, b.nonce
  end

  def test_outputs_hashable_string
    headers = {
      parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
      transactions_hash: "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654",
      target: "0000100000000000000000000000000000000000000000000000000000000000",
      timestamp: 1450564013,
      nonce: 0,
      hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }
    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}], timestamp: 1450565806588}].map { |txn|
      Transaction.new(txn[:inputs], txn[:outputs])
    }

    b = Block.new(headers, transactions)

    assert_equal "#{headers[:parent_hash]}#{headers[:transactions_hash]}#{headers[:timestamp]}#{headers[:target]}#{headers[:nonce]}", b.hashable_string
  end

  def test_block_can_be_rehashed
    headers = {
        parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        transactions_hash: "22f9f992b4c4d6dd8ad1375850027156406de7ab9a61ac8ab604a50fd58fed45",
        target: "0000100000000000000000000000000000000000000000000000000000000000",
        timestamp: 1456634914875,
        nonce: 0,
        hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }
    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}], timestamp: 1450565806588, hash: "71c0984f707ca01efc7403e2c434863c9c735cabce82dd6be59f322042e919b8"}].map { |txn|
      Transaction.new(txn[:inputs], txn[:outputs], txn[:timestamp], txn[:hash])
    }

    b = Block.new(headers, transactions)
    b.increment_nonce
    b.hash_block

    assert_equal "eab232fa58d7fbb1594e20ac0600f089742adb1b89ed8994544cce559efc45b8", b.hash
  end

  def test_can_output_valid_JSON
    headers = {
        parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        transactions_hash: "22f9f992b4c4d6dd8ad1375850027156406de7ab9a61ac8ab604a50fd58fed45",
        target: "0000100000000000000000000000000000000000000000000000000000000000",
        timestamp: 1456634914875,
        nonce: 0,
        hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }
    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}], timestamp: 1450565806588, hash: "71c0984f707ca01efc7403e2c434863c9c735cabce82dd6be59f322042e919b8"}].map { |txn|
      Transaction.new(txn[:inputs], txn[:outputs], txn[:timestamp], txn[:hash])
    }

    b = Block.new(headers, transactions)
    json_block = b.to_json
    new_block = Block.from_json(json_block)
    txn = new_block.transactions.first

    assert_equal new_block.parent_hash, "0000000000000000000000000000000000000000000000000000000000000000"
    assert_equal new_block.transactions_hash,  "22f9f992b4c4d6dd8ad1375850027156406de7ab9a61ac8ab604a50fd58fed45"
    assert_equal new_block.target, "0000100000000000000000000000000000000000000000000000000000000000"
    assert_equal new_block.timestamp, 1456634914875
    assert_equal new_block.nonce, 0
    assert_equal new_block.hash,  "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"

    assert_equal new_block.transactions.count, 1

    assert_equal txn.inputs, []
    assert_equal txn.outputs, [{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}]
    assert_equal txn.timestamp, 1450565806588
    assert_equal txn.hash, "71c0984f707ca01efc7403e2c434863c9c735cabce82dd6be59f322042e919b8"
  end
end
