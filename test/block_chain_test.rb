require_relative 'test_helper'
require 'block_chain'

class BasicBlockChainTest < Minitest::Test
  def test_can_create_a_chain_from_json
    skip
    json_chain =  File.read(File.expand_path('support/small_sample_blocks.txt', __dir__))
    bc = BlockChain.from_json(json_chain)
    assert_equal 10, bc.height
    assert_equal "00000ba50a43011e1a556e52f7eb30850bb4af40b773719e6de93dae4fe24c6a", bc.last.hash
    assert_equal "0000036dcbdd3db35334e217e6d0191a942ad377e09f5173c9731a25f88f31df", bc.latest.hash
  end

end


class BlockChainTest < Minitest::Test
  include TestHelpers

  def test_a_block_chain_begins_with_0_height
    bc = BlockChain.new
    assert_equal 0, bc.height
  end

  def test_can_add_a_block_to_empty_chain
    skip
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


  # def test_can_add_multiple_coinbase_transactions
  #   bc = BlockChain.new
  #   test_block = Block.new(default_parent_hash, [coinbase], nil, {target: easy_easy_target, timestamp:1455122405000})
  #   assert_equal 1455122405000, test_block.timestamp
  #   bc.add(test_block)
  #
  #   assert_equal 1, bc.height
  #   assert_equal test_block, bc.last
  #
  #   test_block2 = Block.new("26fd16e1b331709965dd7ba48bc9687f033641ec36dbb465c07ecac5ddd87ccd", [coinbase], nil, {target: easy_easy_target, timestamp:1455122409500})
  #   bc.add(test_block2)
  #
  #   assert_equal 2, bc.height
  #   assert_equal test_block2, bc.last
  #
  #   test_block3 = Block.new("c0bfd09d36a50024ebd12f2d4d6f91ecca7879691c4565dfa842a72307331390", [coinbase], nil, {target: easy_easy_target})
  #   bc.add(test_block2)
  #   assert_equal 3, bc.height
  #   assert_equal test_block2, bc.last
  # end

end
