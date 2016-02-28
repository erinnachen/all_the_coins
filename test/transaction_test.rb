require_relative 'test_helper'
require 'transaction'

class TransactionTest < Minitest::Test

  def test_converts_timestamp_correctly
    t = Transaction.new([],[],Time.new(2016, 02, 01, 8, 0, 0, "-07:00"))
    assert_equal 1454338800000, t.timestamp
  end

  def test_can_hash_coinbase_transaction
    coinbase = Transaction.new([],[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}], 1450565806588)

    assert_equal "789509258c985783a0c6f99a29725a797bcdcaf3a94c17b077a228fd2a572fa9", coinbase.hash
  end

  def test_can_hash_transaction_with_single_input_multiple_outputs
    inputs = [{source_hash: "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", source_index: 0}]
    outputs = [{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}, {amount: 10, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}]
    inputs, outputs = TransactionSigner.sign_transactions(inputs, outputs, private_key)
    txn = Transaction.new(inputs, outputs, 1450565806588)

    assert_equal "c780b46a085bcbb14394b55eb379c058cf78010e2c30b7b6027c7ff6f9c81ce7", txn.hash
  end

  def test_transaction_is_coinbase
    coinbase = Transaction.new([],[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}], 1450565806588)
    inputs = [{source_hash: "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", source_index: 0}]
    outputs = [{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}, {amount: 10, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}]
    inputs, outputs = TransactionSigner.sign_transactions(inputs, outputs, private_key)
    txn = Transaction.new(inputs, outputs, 1450565806588)

    assert coinbase.coinbase?
    refute txn.coinbase?
  end

  private

  def private_key
    Wallet.new(File.expand_path('support', __dir__)).private_key
  end

  def public_key
    Wallet.new(File.expand_path('support', __dir__)).public_key
  end

end

class TransactionSignerTest < Minitest::Test
  def test_does_not_sign_a_coinbase_transaction
    outputs = [{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}]

    sins, souts = TransactionSigner.sign_transactions([], outputs, private_key)
    assert_equal [], sins
    assert_equal outputs, souts
  end

  def test_can_sign_a_single_input_transaction
    inputs = [{source_hash: "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", source_index: 0}]
    outputs = [{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}, {amount: 10, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}]
    sins, souts = TransactionSigner.sign_transactions(inputs, outputs, private_key)
    signed_inputs = [{source_hash: "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", source_index: 0, signature: "BTypNu4NT5eDFtHDDyQNP1+i3lQi6qRJTve8DsxxebDuc6FkwyqVb56zsEih\nUyFsMbherEUR3mno+WUhlzK0cbmk86066smqw2qEbZqJuZL+RlFUwGAGyEEu\nBW2yFwHNEa5tWWkhwl9+1EmVQQGjneB+/SHh4WTY/opcNdkNTAQwZdcZVbJJ\n6d7Ve95HA6fs6lgz/qCy8xVEm8T8/JjWCgZX89TsiezsHMvOpqKiBrOsjeco\n0yc0Fn3vfVaCh1kZR0eAf0t3FRUBdaMOEpAoVeRzNx5fOzKqWuBCN/tPJvs+\n2z4/jr5x8Q3k/VEWaoVdnvD8pDgi0r4++hxLjW9Wwg==\n"}]

    assert_equal outputs, souts
    assert_equal signed_inputs, sins
  end

  private

  def private_key
    Wallet.new(File.expand_path('support', __dir__)).private_key
  end

end

# class TransactionTest < Minitest::Test
#   attr_reader :wallet, :t, :string_to_hash
#
#   def setup
#     @wallet = Wallet.new(File.expand_path('support', __dir__))
#     inputs = [{"source_hash" => "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", "source_index"=> 0}]
#     outputs = [{"amount"=> 5, "address"=> "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"}]
#     @string_to_hash = "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e0"\
#     "5-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
#     @t = Transaction.new(inputs, outputs, wallet, (Time.new(2016, 02, 01, 8, 0, 0, "-07:00").to_f*1000).to_i)
#   end
#
#   def test_converts_timestamp_correctly
#     assert_equal 1454338800000, t.timestamp
#   end
#
#   def test_calculates_signatures
#     assert_equal example_signature, t.input_signature
#   end
#
#   def test_signature_can_be_verified
#     assert wallet.public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(t.input_signature), string_to_hash)
#   end
#
#   def test_inputs_have_signatures_after_signing
#     t.sign_inputs
#     assert_equal example_signature, t.inputs[0]["signature"]
#   end
#
#   def test_coinbase_transaction
#     trans = Transaction.new([],[{"amount" => 25, "address" => "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}], wallet, 1450565806588)
#     trans.sign_inputs
#     trans.hash_transaction
#     assert trans.coinbase?
#     assert_equal "789509258c985783a0c6f99a29725a797bcdcaf3a94c17b077a228fd2a572fa9", trans.txn_hash
#   end
#
#   def test_hash_entire_transaction
#     t.sign_inputs
#     t.hash_transaction
#     assert_equal "3202333c82270d197d560bcd8ef25504da0b9ea3e0a5d8dae232d27b3f72103c", t.txn_hash
#   end
#
#   def test_json_output
#     assert_equal "{\"inputs\":[{\"source_hash\":\"9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e\",\"source_index\":0,\"signature\":\"bZFyvfQoEla4dWdGkt8pyVYnmGbgl/1bKKjTHQ5VYrVvt/wNMFx2W25WUAcT\\n0wUrhj6LsIR1wcnxahvwKfxZ/UXSrCvh/d9rwmXdI4TjWqaxpP4PLuSd3Urc\\nADLnW9ccR8D4fjFOXxDyQMDo7oZDESsM+EOgpcfRVv7MfCUnyILeOS30GZww\\nLrRtutKLO1lOTiJ6RHRufMpaUuXNevk+dRu2w8T0NRp4XTCGwh8gi684/Nzj\\ndj+2v6kVS24zP4/uLBqWPupFqt9PJl7OlEDrrsgXqmrhtPM7W3mBg/J05BrI\\n4yt1B9rMaUfuv8Aun0Rj6m3qvg5ASl3OahBFiSdPCA==\\n\"}],\"outputs\":[{\"amount\":5,\"address\":\"-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\\nPsn/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe/Mnyr\\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\\nuwIDAQAB\\n-----END PUBLIC KEY-----\\n\"}],\"timestamp\":1454338800000,\"hash\":\"3202333c82270d197d560bcd8ef25504da0b9ea3e0a5d8dae232d27b3f72103c\"}", t.to_json
#   end
#
#   def example_signature
#     "bZFyvfQoEla4dWdGkt8pyVYnmGbgl/1bKKjTHQ5VYrVvt/wNMFx2W25WUAcT\n0wUrhj6LsIR1wcnxahvwKfxZ/UXSrCvh/d9rwmXdI4TjWqaxpP4PLuSd3Urc\nADLnW9ccR8D4fjFOXxDyQMDo7oZDESsM+EOgpcfRVv7MfCUnyILeOS30GZww\nLrRtutKLO1lOTiJ6RHRufMpaUuXNevk+dRu2w8T0NRp4XTCGwh8gi684/Nzj\ndj+2v6kVS24zP4/uLBqWPupFqt9PJl7OlEDrrsgXqmrhtPM7W3mBg/J05BrI\n4yt1B9rMaUfuv8Aun0Rj6m3qvg5ASl3OahBFiSdPCA==\n"
#   end
# end
