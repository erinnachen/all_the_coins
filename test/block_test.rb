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
    skip
    headers = {
        parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        transactions_hash: "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654",
        target: "0000100000000000000000000000000000000000000000000000000000000000",
        timestamp: 1450564013,
        nonce: 0,
        hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }

    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}]}]

    b = Block.new(headers, transactions)

    assert_equal headers[:parent_hash], b.parent_hash
    assert_equal headers[:transactions_hash], b.transactions_hash
    assert_equal headers[:target], b.target
    assert_equal headers[:timestamp], b.timestamp
    assert_equal headers[:nonce], b.nonce
    assert_equal headers[:hash], b.hash

    assert_equal transactions.first[:inputs], b.transactions.first.inputs
    assert_equal transactions.first[:outputs], b.transactions.first.outputs
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
    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}]}]
    b = Block.new(headers, transactions)

    b.nonce = 50000
    b.hash = "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e"

    assert_equal 50000, b.nonce
    assert_equal "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", b.hash
  end
  meta t: true
  def test_outputs_hashable_string
    skip
    headers = {
        parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        transactions_hash: "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654",
        target: "0000100000000000000000000000000000000000000000000000000000000000",
        timestamp: 1450564013,
        nonce: 0,
        hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }
    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}], timestamp: 1450565806588}]
    b = Block.new(headers, transactions)

    assert_equal "#{headers[:parent_hash]}#{headers[:transactions_hash]}#{headers[:timestamp]}#{headers[:target]}#{headers[:nonce]}", b.hashable_string
  end

  def test_block_can_be_rehashed
    skip
    headers = {
        parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        transactions_hash: "22f9f992b4c4d6dd8ad1375850027156406de7ab9a61ac8ab604a50fd58fed45",
        target: "0000100000000000000000000000000000000000000000000000000000000000",
        timestamp: 1456634914875,
        nonce: 0,
        hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }
    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}], timestamp: 1450565806588, hash: "71c0984f707ca01efc7403e2c434863c9c735cabce82dd6be59f322042e919b8"}]

    b = Block.new(headers, transactions)
    b.rehash_block

    assert_equal "81f6dc21a0b48609a2fa79bcc0d309c58a96d75bb4a798f6bdcd256195ded3c7", b.hash
  end

  # def setup
  #   generate_coinbase
  #   @wallet = Wallet.new(File.expand_path('support', __dir__))
  # end
  #
  # def test_hash_single_transaction
  #   trans = [coinbase]
  #   b = Block.new(default_parent_hash, trans, nil)
  #
  #   assert_equal "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654", b.trans_hash
  # end
  #
  # def test_hash_multiple_transactions
  #   trans = [coinbase, sample_transaction]
  #   b = Block.new(default_parent_hash, trans, nil)
  #   assert_equal "0d8f366c787afdf2e88e496becc97ee7b48ec89f32b53c54f51656b4161206ea", b.trans_hash
  #
  #   trans = [sample_transaction, coinbase]
  #   b = Block.new(default_parent_hash, trans, nil)
  #   assert_equal "c8400b2bad95a4b7283d405347410cf104142c672c605f967f77080ba37eba67", b.trans_hash
  #
  #   trans = [sample_transaction, coinbase, sample_transaction]
  #   b = Block.new(default_parent_hash, trans, nil)
  #   assert_equal "1bdd79ffc027fc6af128c349729f40f0d5765ee09349507d72ca1f0bc8c410a3", b.trans_hash
  # end
  #
  # def test_hash_the_block
  #   trans = [coinbase]
  #   opts = {timestamp: 1450564013, nonce: 1354641, target: "0000100000000000000000000000000000000000000000000000000000000000"}
  #   b = Block.new(default_parent_hash, trans, nil, opts)
  #   assert_equal "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72", b.block_hash
  # end
  #
  # def test_calculate_a_nonce_correctly
  #   trans = [coinbase]
  #   opts = {timestamp: 1450564013, target: "400000000000000000000000000000000000000000000000000000000000"}
  #   b = Block.new(default_parent_hash, trans, nil, opts)
  #   b.work
  #   assert b.target.hex > b.block_hash.hex
  #   assert_equal 180688, b.nonce
  # end
  #
  # def test_outputs_json
  #   trans = [coinbase]
  #   opts = {timestamp: 1450564013, nonce: 1354641, target: "0000100000000000000000000000000000000000000000000000000000000000"}
  #   b = Block.new(default_parent_hash, trans, nil, opts)
  #   assert_equal "{\"header\":{\"parent_hash\":\"0000000000000000000000000000000000000000000000000000000000000000\",\"transactions_hash\":\"203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654\",\"target\":\"0000100000000000000000000000000000000000000000000000000000000000\",\"timestamp\":1450564013,\"nonce\":1354641,\"hash\":\"000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72\"},\"transactions\":[\"{\\\"inputs\\\":[],\\\"outputs\\\":[{\\\"amount\\\":25,\\\"address\\\":\\\"-----BEGIN PUBLIC KEY-----\\\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5/H2MM4lO\\\\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\\\\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\\\\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k/jxa0pUAQNqf11MJSrzF7u/Z+8\\\\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY/R64z\\\\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\\\\nhwIDAQAB\\\\n-----END PUBLIC KEY-----\\\\n\\\"}],\\\"timestamp\\\":1450564013887,\\\"hash\\\":\\\"933de73b476eb420aadc3c0e5959c6b0e3d1a58c4f997bd60bcbdbb5a0beeb90\\\"}\"]}", b.to_json
  # end
  #
  # def test_if_is_block_zero_the_target_is_16_to_the_59th_power
  #   trans = [coinbase]
  #   opts = {timestamp: 1450564013, nonce: 1354641}
  #   b = Block.new(default_parent_hash, trans, nil, opts)
  #   assert_equal 16**59, b.target.to_i(16)
  # end
  #
  # def test_block_one_can_calculate_the_target_off_block_zero
  #   trans = [coinbase]
  #   opts = {timestamp: 1450564013, nonce: 1354641}
  #   b0 = Block.new(default_parent_hash, trans, nil, opts)
  #
  #   opts = {timestamp: 1450564513}
  #   bc = mock('block_chain')
  #   bc.stubs(:last_timestamps).returns([b0.timestamp])
  #   bc.stubs(:find).returns(b0)
  #   b1 = Block.new(b0.block_hash, trans, bc, opts)
  #   assert_equal "0000100000000000000000000000000000000000000000000000000000000000", b1.target
  # end
  #
  # def test_block_can_calculate_the_target_off_two_blocks_in_chain
  #   opts = {target: "0000100000000000000000000000000000000000000000000000000000000000"}
  #   b1 = Block.new('mock_hash', [], nil, opts)
  #
  #   bc2 = mock('block_chain')
  #   bc2.stubs(:last_timestamps).returns([1450564013, 1450564513])
  #   bc2.stubs(:find).returns(b1)
  #   b2 = Block.new('mock_hash',[], bc2)
  #
  #   assert_equal "000042aaaaaaaaaaadf6a6c5db88301d375a80fadcb6cbd82e00000000000000", b2.target
  # end
  #
  # def test_the_target_can_calculate_a_target_from_the_last_ten_transactions
  #   opts = {target: "000042aaaaaaaaaaadf6a6c5db88301d375a80fadcb6cbd82e00000000000000", timestamp: 1450565255}
  #   b1 = Block.new('mock_hash', [], nil, opts)
  #
  #   bc2 = mock('block_chain')
  #   bc2.stubs(:last_timestamps).returns([1450564570,
  #     1450564662, 1450564674, 1450564747, 1450564866, 1450565013,
  #     1450565023, 1450565059, 1450565170, b1.timestamp])
  #   bc2.stubs(:find).returns(b1)
  #   b2 = Block.new('mock_hash',[], bc2)
  #
  #   assert_equal "00002a48b0fcd6e9e408caf4bfe486cffb3cdfecfcb3effc5200000000000000", b2.target
  #   assert b1.target > b2.target
  # end
  #
  # def default_parent_hash
  #   "0000000000000000000000000000000000000000000000000000000000000000"
  # end
  #
  # def generate_coinbase
  #   @coinbase = Transaction.new([],[{"amount" => 25, "address" => "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}], wallet, 1450564013887)
  #   coinbase.hash_transaction
  # end
  #
  # def sample_transaction
  #   inputs = [{"source_hash" => "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", "source_index"=> 0}]
  #   outputs = [{"amount"=> 5, "address"=> "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"}]
  #   @string_to_hash = "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e0"\
  #   "5-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
  #   t = Transaction.new(inputs, outputs, wallet, (Time.new(2016, 02, 01, 8, 0, 0, "-07:00").to_f*1000).to_i)
  #   t.sign_inputs
  #   t.hash_transaction
  #   t
  # end
end
