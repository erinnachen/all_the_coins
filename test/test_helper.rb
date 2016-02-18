$LOAD_PATH.unshift(File.expand_path('../lib',__dir__))

require 'minitest'
require 'simplecov'
SimpleCov.start

module TestHelpers
  def setup
    @wallet = Wallet.new(File.expand_path('support', __dir__))
    super
  end

  def wallet
    @wallet
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

  def coinbase
    cb = Transaction.new([],[{"amount" => 25, "address" => "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"}], wallet, 1450564013887)
    cb.hash_transaction
    cb
  end
end
