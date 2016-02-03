require 'minitest'
require 'transaction'
require 'wallet'
require 'block'

class BlockTest < Minitest::Test
  attr_reader :coinbase, :wallet

  def setup
    generate_coinbase
    @wallet = Wallet.new(File.expand_path('support', __dir__))
  end

  def test_hash_single_transaction
    trans = [coinbase]
    b = Block.new(default_parent_hash, trans)

    assert_equal "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654", b.trans_hash
  end

  def test_hash_multiple_transactions
    trans = [coinbase, sample_transaction]
    b = Block.new(default_parent_hash, trans)
    assert_equal "0d8f366c787afdf2e88e496becc97ee7b48ec89f32b53c54f51656b4161206ea", b.trans_hash

    trans = [sample_transaction, coinbase]
    b = Block.new(default_parent_hash, trans)
    assert_equal "c8400b2bad95a4b7283d405347410cf104142c672c605f967f77080ba37eba67", b.trans_hash

    trans = [sample_transaction, coinbase, sample_transaction]
    b = Block.new(default_parent_hash, trans)
    assert_equal "1bdd79ffc027fc6af128c349729f40f0d5765ee09349507d72ca1f0bc8c410a3", b.trans_hash
  end

  def test_hash_the_block
    trans = [coinbase]
    opts = {timestamp: 1450564013.to_s, nonce: 1354641.to_s, target: "0000100000000000000000000000000000000000000000000000000000000000"}
    b = Block.new(default_parent_hash, trans, opts)
    assert_equal "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72", b.block_hash
  end

  def default_parent_hash
    "0000000000000000000000000000000000000000000000000000000000000000"
  end

  def generate_coinbase
    @coinbase = Transaction.new([],[{"amount" => 25, "address" => "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}], wallet, 1450564013887)
    coinbase.hash_transaction
  end

  def sample_transaction
    inputs = [{"source_hash" => "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", "source_index"=> 0}]
    outputs = [{"amount"=> 5, "address"=> "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"}]
    @string_to_hash = "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e0"\
    "5-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
    t = Transaction.new(inputs, outputs, wallet, (Time.new(2016, 02, 01, 8, 0, 0, "-07:00").to_f*1000).to_i)
    t.sign_inputs
    t.hash_transaction
    t
  end
end
