require 'minitest'
require 'wallet'

class WalletTest < Minitest::Test
  def setup
    delete_temp_files
  end

  def fixed_pub_key
    OpenSSL::PKey.read("-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwhmq0j/Vv1Gm9a3Sc07y\nnjIPAIEnKAHs0RvSWAfqBiHN+iMPyAaVxbd0ouQJFtNDBZkK+cL+Et5xaOg5QjBY\nH8hESS0qvqRFMp4RknkeZUw3z572scYu7/gw3LM6LD5j/gicIlagsWdJFTvbFqmy\n0LvikxxtWlVVfzt8FD/pcsesdxlqJClNmh5Vjwk6+nGgr6SZecZKB4ANGwb9kDS9\nxKQJ0A+vXRxdJtjkJ8Zw7zz4ngm5awsv884FEoLXtMaJnm4TGPKYWIlVDXdzhM6N\n1FKzt6wzqR6KS6ONCTTj2jR3C+3fkqvBZJIvijF5b+GRuop5OQMcCfFi75mHewJA\nqwIDAQAB\n-----END PUBLIC KEY-----")
  end

  def test_can_create_a_wallet
    w = Wallet.new
    assert_kind_of Wallet, w
  end

  def test_can_read_keys_from_existing_files
    w = Wallet.new(File.expand_path('support', __dir__))
    assert_equal fixed_pub_key.to_pem, w.public_key.to_pem
  end

  def test_generates_a_new_wallet_dir_and_files_if_they_do_not_exist
    path = File.expand_path( "support/new#{Time.now.strftime("%H%M%S")}", __dir__)
    wallet_path = path+'/.wallet'
    refute File.file?(File.expand_path("private_key.pem",wallet_path))
    refute File.file?(File.expand_path("public_key.pem",wallet_path))

    w = Wallet.new(File.expand_path(path, __dir__))

    assert File.file?(File.expand_path("private_key.pem",wallet_path))
    assert File.file?(File.expand_path("public_key.pem",wallet_path))

    assert_kind_of OpenSSL::PKey::RSA, w.public_key
    assert_kind_of OpenSSL::PKey::RSA, w.private_key
    refute_equal fixed_pub_key.to_pem, w.public_key.to_pem
  end

  def delete_temp_files
    temp_files = Dir.entries('test/support' ).find_all {|path| path.include?("new")}
    temp_files.each do |file|
      FileUtils.remove_dir(File.expand_path("support/#{file}", __dir__))
    end
  end

end
