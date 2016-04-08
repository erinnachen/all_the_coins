$LOAD_PATH.unshift(File.expand_path('../lib',__dir__))

require 'simplecov'
SimpleCov.start
require 'minitest'
require 'pry'

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

  def sample_block
    headers = {
        parent_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        transactions_hash: "22f9f992b4c4d6dd8ad1375850027156406de7ab9a61ac8ab604a50fd58fed45",
        target: "0000100000000000000000000000000000000000000000000000000000000000",
        timestamp: 1456634914875,
        nonce: 0,
        hash: "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    }
    transactions = [{inputs:[], outputs:[{amount: 25, address: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn04rVGD\/selxmPcYRmjc\nHE19e5XQOueBekYEdQHD5q06mzuLQqErjJDANt80JjF6Y69dOU23cqlZ1B\/2Pj48\nK+OROFBlrT5usrAJa6we0Ku33w6avl47PXanhcfi39GKNr8RadCKHoG1klvKqVEm\nuhJO\/2foXAb6LATB0YoQuH8sDvUmLHSSPTTCBO2YGtsCvlMBNxdnvGVyZA5iIPwu\nw7DN00jG8RJn0KQRDgTM+nFNxcw9bIOrfSxOmNTDo1y8EFwFiYZ6rORLN+cNL50T\nU1Kl\/ShX0dfvXauSjliVSl3sll1brVC500HYlAK61ox5BakdZG6R+3tJKe1RAs3P\nNQIDAQAB\n-----END PUBLIC KEY-----\n"}], timestamp: 1450565806588, hash: "71c0984f707ca01efc7403e2c434863c9c735cabce82dd6be59f322042e919b8"}].map { |txn|
      Transaction.new(txn[:inputs], txn[:outputs], txn[:timestamp], txn[:hash])
    }

    Block.new(headers, transactions)
  end
end
