require 'test_helper'
require 'miner'

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
    miner = Miner.new
    json_chain =  File.read(File.expand_path('support/small_sample_blocks.txt', __dir__))

    miner.read_block_chain(json_chain)

    assert_equal 10, miner.chain_height
    assert_equal "0000036dcbdd3db35334e217e6d0191a942ad377e09f5173c9731a25f88f31df", miner.latest_block_hash
  end

  def test_miner_can_create_a_default_coinbase_transaction
    miner = Miner.new(wallet: wallet)

    miner.mine
    block = miner.block_chain.latest
    timestamp = (Time.now.to_f* 1000).to_i

    assert_equal 1, miner.chain_height

    assert_equal "d5a8ad8149c6e557c94f3cd49c1d13ad4f2c473aea6f97d730283dd1ac1d99c4", block.parent_hash
    assert_equal "0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", block.target
    # assert_equal [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwhmq0j/Vv1Gm9a3Sc07y\nnjIPAIEnKAHs0RvSWAfqBiHN+iMPyAaVxbd0ouQJFtNDBZkK+cL+Et5xaOg5QjBY\nH8hESS0qvqRFMp4RknkeZUw3z572scYu7/gw3LM6LD5j/gicIlagsWdJFTvbFqmy\n0LvikxxtWlVVfzt8FD/pcsesdxlqJClNmh5Vjwk6+nGgr6SZecZKB4ANGwb9kDS9\nxKQJ0A+vXRxdJtjkJ8Zw7zz4ngm5awsv884FEoLXtMaJnm4TGPKYWIlVDXdzhM6N\n1FKzt6wzqR6KS6ONCTTj2jR3C+3fkqvBZJIvijF5b+GRuop5OQMcCfFi75mHewJA\nqwIDAQAB\n-----END PUBLIC KEY-----\n"}], timestamp: 1450565806588}],
    binding.pry
    assert_equal [], block.transactions.first.inputs
    assert_equal [{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwhmq0j/Vv1Gm9a3Sc07y\nnjIPAIEnKAHs0RvSWAfqBiHN+iMPyAaVxbd0ouQJFtNDBZkK+cL+Et5xaOg5QjBY\nH8hESS0qvqRFMp4RknkeZUw3z572scYu7/gw3LM6LD5j/gicIlagsWdJFTvbFqmy\n0LvikxxtWlVVfzt8FD/pcsesdxlqJClNmh5Vjwk6+nGgr6SZecZKB4ANGwb9kDS9\nxKQJ0A+vXRxdJtjkJ8Zw7zz4ngm5awsv884FEoLXtMaJnm4TGPKYWIlVDXdzhM6N\n1FKzt6wzqR6KS6ONCTTj2jR3C+3fkqvBZJIvijF5b+GRuop5OQMcCfFi75mHewJA\nqwIDAQAB\n-----END PUBLIC KEY-----\n"}], block.transactions.first.outputs
    assert_equal 1450565806588, block.transactions.first.timestamp
    assert_equal "c95e1cb4192f67f8c0fe20b755e1143b66d6d7e2c08f3c6480d1425708d97f86", block.transactions.first.hash

    assert timestamp >= block.timestamp
    assert block.target > block.hash
  end

  def wallet
    Wallet.new(File.expand_path('support', __dir__))
  end

end
