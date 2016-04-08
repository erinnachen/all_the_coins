require_relative 'test_helper'
require 'block_chain'

class BlockChainTest < Minitest::Test
  include TestHelpers
  def test_can_create_a_chain_from_json
    json_chain =  File.read(File.expand_path('support/small_sample_blocks.txt', __dir__))
    bc = BlockChain.from_json(json_chain)
    assert_equal 10, bc.height
    assert_equal "00000ba50a43011e1a556e52f7eb30850bb4af40b773719e6de93dae4fe24c6a", bc.first.hash
    assert_equal "0000036dcbdd3db35334e217e6d0191a942ad377e09f5173c9731a25f88f31df", bc.last.hash
  end

  def test_begins_with_0_height
    bc = BlockChain.new
    assert_equal 0, bc.height
  end

  def test_can_add_a_block_to_empty_chain
    bc = BlockChain.new
    test_block = sample_block

    bc.add(test_block)

    assert_equal 1, bc.height
    assert_equal test_block, bc.last
  end

  def test_can_output_valid_JSON
    json_chain =  File.read(File.expand_path('support/small_sample_blocks.txt', __dir__))
    bc = BlockChain.from_json(json_chain)
    bc_json = bc.to_json
    new_block_chain = BlockChain.from_json(bc_json)

    assert_equal "00000ba50a43011e1a556e52f7eb30850bb4af40b773719e6de93dae4fe24c6a", new_block_chain.first.hash
    assert_equal "0000036dcbdd3db35334e217e6d0191a942ad377e09f5173c9731a25f88f31df", new_block_chain.last.hash
  end
end
