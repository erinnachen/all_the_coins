require './test/test_helper'
require './lib/miner'
require "minitest/autorun"
require "./lib/wallet"

class BasicMinerTest < Minitest::Test
  def test_miner_has_a_zero_height_block_chain_by_default
    miner = Miner.new
    assert_equal 0, miner.chain_height
  end

  def test_miner_has_a_valid_public_key_by_default
    miner = Miner.new
    assert OpenSSL::PKey.read(miner.public_key_pem)
  end

  def test_miner_can_be_created_with_a_wallet
    miner = Miner.new(wallet: wallet)

    assert_equal "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwhmq0j/Vv1Gm9a3Sc07y\nnjIPAIEnKAHs0RvSWAfqBiHN+iMPyAaVxbd0ouQJFtNDBZkK+cL+Et5xaOg5QjBY\nH8hESS0qvqRFMp4RknkeZUw3z572scYu7/gw3LM6LD5j/gicIlagsWdJFTvbFqmy\n0LvikxxtWlVVfzt8FD/pcsesdxlqJClNmh5Vjwk6+nGgr6SZecZKB4ANGwb9kDS9\nxKQJ0A+vXRxdJtjkJ8Zw7zz4ngm5awsv884FEoLXtMaJnm4TGPKYWIlVDXdzhM6N\n1FKzt6wzqR6KS6ONCTTj2jR3C+3fkqvBZJIvijF5b+GRuop5OQMcCfFi75mHewJA\nqwIDAQAB\n-----END PUBLIC KEY-----\n", miner.public_key_pem
  end

  def test_miner_can_read_a_block_chain_from_json
    skip
    miner = Miner.new
    json_chain =  File.read(File.expand_path('support/small_sample_blocks.txt', __dir__))

    miner.read_block_chain(json_chain)

    assert_equal 10, miner.chain_height
    assert_equal "0000036dcbdd3db35334e217e6d0191a942ad377e09f5173c9731a25f88f31df", miner.latest_block_hash
  end

  def test_miner_can_create_a_default_coinbase_transaction
    miner = Miner.new(wallet: wallet)

    miner.mine
    block = miner.block_chain.last
    timestamp = (Time.now.to_f* 1000).to_i

    assert_equal 1, miner.chain_height

    assert_equal "0000000000000000000000000000000000000000000000000000000000000000", block.parent_hash
    assert_equal "0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", block.target
    assert_equal [], block.transactions.first.inputs
    assert_equal [{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwhmq0j/Vv1Gm9a3Sc07y\nnjIPAIEnKAHs0RvSWAfqBiHN+iMPyAaVxbd0ouQJFtNDBZkK+cL+Et5xaOg5QjBY\nH8hESS0qvqRFMp4RknkeZUw3z572scYu7/gw3LM6LD5j/gicIlagsWdJFTvbFqmy\n0LvikxxtWlVVfzt8FD/pcsesdxlqJClNmh5Vjwk6+nGgr6SZecZKB4ANGwb9kDS9\nxKQJ0A+vXRxdJtjkJ8Zw7zz4ngm5awsv884FEoLXtMaJnm4TGPKYWIlVDXdzhM6N\n1FKzt6wzqR6KS6ONCTTj2jR3C+3fkqvBZJIvijF5b+GRuop5OQMcCfFi75mHewJA\nqwIDAQAB\n-----END PUBLIC KEY-----\n"}], block.transactions.first.outputs
    assert timestamp >= block.timestamp
    assert block.target.hex > block.hash.hex
    assert block.transactions_hash
  end

  def test_can_mine_two_connected_blocks_in_a_row
    miner = Miner.new(wallet: wallet)

    miner.mine
    miner.mine
    b1 = miner.block_chain.first
    b2 = miner.block_chain.last

    assert_equal 2, miner.chain_height
    assert_equal b1.hash, b2.parent_hash
  end

  def test_can_find_balance_for_the_mining_key
    miner = Miner.new(wallet: wallet)
    3.times { miner.mine }

    assert_equal 75, miner.get_balance(wallet.public_key.to_pem)
  end

  def test_can_generate_transaction_to_pay_from_miner_key_to_other_key_single_input_to_single_output
    miner = Miner.new(wallet: wallet)
    path = File.expand_path( "support/new#{Time.now.strftime("%H%M%S")}", __dir__)
    wallet_path = path+'/.wallet'
    wallet2 = Wallet.new(File.expand_path(path, __dir__))
    3.times do
      miner.mine
      sleep(1)
    end

    inputs = miner.transfer(25, miner.public_key_pem)
    assert_equal 1, inputs.length
    input = inputs.first
    source_transaction = miner.block_chain.find_transaction(input[:source_hash])
    assert_equal 25, source_transaction.outputs[input[:source_index]][:amount]
    outputs = [{amount: 25, address: wallet2.public_key.to_pem}]
    inputs, outputs = TransactionSigner.sign_transactions(inputs, outputs, wallet2.private_key)
    miner.transactions << Transaction.new(inputs, outputs)
    miner.mine
    assert_equal 4, miner.chain_height

    last = miner.block_chain.last
    assert_equal 2, last.transactions.count
    assert_equal 25, miner.get_balance(wallet2.public_key.to_pem)
    assert_equal 75, miner.get_balance(miner.public_key_pem)
  end

  def test_can_generate_transaction_to_pay_from_miner_key_to_other_key_multi_input_to_single_output
    miner = Miner.new(wallet: wallet)
    path = File.expand_path( "support/new#{Time.now.strftime("%H%M%S")}", __dir__)
    wallet_path = path+'/.wallet'
    wallet2 = Wallet.new(File.expand_path(path, __dir__))
    2.times do
      miner.mine
      sleep(1)
    end

    inputs = miner.transfer(50, miner.public_key_pem)
    assert_equal 2, inputs.length
    assert_equal miner.block_chain.first.transactions.first.hash, inputs.first[:source_hash]
    assert_equal miner.block_chain.last.transactions.first.hash, inputs.last[:source_hash]

    outputs = [{amount: 50, address: wallet2.public_key.to_pem}]
    inputs, outputs = TransactionSigner.sign_transactions(inputs, outputs, wallet2.private_key)
    miner.transactions << Transaction.new(inputs, outputs)
    miner.mine
    assert_equal 3, miner.chain_height

    last = miner.block_chain.last
    assert_equal 2, last.transactions.count
    assert_equal 50, miner.get_balance(wallet2.public_key.to_pem)
    assert_equal 25, miner.get_balance(miner.public_key_pem)
  end

  def test_can_generate_transaction_to_pay_from_miner_key_to_other_key_single_input_to_multiple_output
    miner = Miner.new(wallet: wallet)
    path = File.expand_path( "support/new#{Time.now.strftime("%H%M%S")}", __dir__)
    wallet_path = path+'/.wallet'
    wallet2 = Wallet.new(File.expand_path(path, __dir__))
    miner.mine

    inputs = miner.transfer(16, miner.public_key_pem)
    outputs = [{amount: 16, address: wallet2.public_key.to_pem}, {amount: 9, address: miner.public_key_pem}]
    inputs, outputs = TransactionSigner.sign_transactions(inputs, outputs, wallet2.private_key)
    miner.transactions << Transaction.new(inputs, outputs)
    miner.mine

    assert_equal 2, miner.chain_height
    assert_equal 16, miner.get_balance(wallet2.public_key.to_pem)
    assert_equal 34, miner.get_balance(miner.public_key_pem)
  end

  def test_can_generate_transaction_to_pay_from_miner_key_to_other_key_multiple_input_to_multiple_output
    miner = Miner.new(wallet: wallet)
    path = File.expand_path( "support/new#{Time.now.strftime("%H%M%S")}", __dir__)
    wallet_path = path+'/.wallet'
    wallet2 = Wallet.new(File.expand_path(path, __dir__))
    2.times do
      miner.mine
      sleep(1)
    end

    inputs = miner.transfer(42, miner.public_key_pem)
    outputs = [{amount: 42, address: wallet2.public_key.to_pem}, {amount: 8, address: miner.public_key_pem}]
    inputs, outputs = TransactionSigner.sign_transactions(inputs, outputs, wallet2.private_key)
    miner.transactions << Transaction.new(inputs, outputs)
    miner.mine

    assert_equal 3, miner.chain_height
    assert_equal 42, miner.get_balance(wallet2.public_key.to_pem)
    assert_equal 33, miner.get_balance(miner.public_key_pem)
  end

  # cannot transfer money when balance is less than actual amount
  # multi input to single output (pay 50)
  # single input multi output (pay 16)
  # multi input multi output (pay 60)
  # then look at adding these transactions into the chain via mining
  # then check balance for key a and key b

  def wallet
    Wallet.new(File.expand_path('support', __dir__))
  end

end
