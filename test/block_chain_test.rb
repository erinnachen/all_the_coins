require 'minitest'
require 'block_chain'

class BlockChainTest < Minitest::Test
  attr_reader :wallet
  def setup
    @wallet = Wallet.new(File.expand_path('support', __dir__))
  end

  def test_a_block_chain_begins_with_0_height
    bc = BlockChain.new
    assert_equal 0, bc.height
  end

  def test_can_add_a_block_to_empty_chain
    bc = BlockChain.new
    test_block = Block.new(default_parent_hash, [coinbase], nil, {target: easy_easy_target})

    bc.add(test_block)

    assert_equal 1, bc.height
    assert_equal test_block, bc.last

    bc = BlockChain.new
    test_block = Block.new(random_parent_hash, [coinbase], nil, {target: easy_easy_target})

    bc.add(test_block)

    assert_equal 1, bc.height
    assert_equal test_block, bc.last

    bc = BlockChain.new
    test_block = Block.new(default_parent_hash, [coinbase], nil, {target: default_target})

    bc.add(test_block)

    assert_equal 1, bc.height
    assert_equal test_block, bc.last

    bc = BlockChain.new
    test_block = Block.new(default_parent_hash, [coinbase], nil, {target: easy_easy_target})

    bc.add(test_block)

    assert_equal 1, bc.height
    assert_equal test_block, bc.last
  end

  def test_can_add_multiple_coinbase_transactions
    bc = BlockChain.new
    test_block = Block.new(default_parent_hash, [coinbase], nil, {target: easy_easy_target, timestamp:1455122405000})
    assert_equal 1455122405000, test_block.timestamp
    bc.add(test_block)

    assert_equal 1, bc.height
    assert_equal test_block, bc.last

    test_block2 = Block.new("26fd16e1b331709965dd7ba48bc9687f033641ec36dbb465c07ecac5ddd87ccd", [coinbase], nil, {target: easy_easy_target, timestamp:1455122409500})
    bc.add(test_block2)

    assert_equal 2, bc.height
    assert_equal test_block2, bc.last

    test_block3 = Block.new("c0bfd09d36a50024ebd12f2d4d6f91ecca7879691c4565dfa842a72307331390", [coinbase], nil, {target: easy_easy_target})
    bc.add(test_block2)
    assert_equal 3, bc.height
    assert_equal test_block2, bc.last
  end




  def coinbase
    cb = Transaction.new([],[{"amount" => 25, "address" => "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}], wallet, 1450564013887)
    cb.hash_transaction
    cb
  end

  def default_parent_hash
    "0000000000000000000000000000000000000000000000000000000000000000"
  end

  def random_parent_hash
    "bd9ee9d2848decc4f177ba46584653d5581a8a836fe7572c9b18016273c53339"
  end

  def default_target
    "0000100000000000000000000000000000000000000000000000000000000000"
  end

  def easy_easy_target
    "b999999999999999999999999999999999999999999999999999999999999999"
  end
end
