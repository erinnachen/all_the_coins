require 'minitest'

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
