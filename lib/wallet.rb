require 'openssl'
require 'pry'

class Wallet
  attr_reader :private_key, :public_key, :wallet_path, :root_path

  def initialize(root_path = ENV['HOME'])
    @wallet_path = File.expand_path('.wallet', root_path)
    @root_path = root_path
    create_wallet unless wallet_exists?
    read_keys
  end

  def wallet_exists?
    File.file?(private_key_file) && File.file?(public_key_file)
  end

  def private_key_file
    File.expand_path("private_key.pem",wallet_path)
  end

  def public_key_file
    File.expand_path("public_key.pem",wallet_path)
  end

  def create_wallet
    create_dirs
    create_keys
    write_keys
  end

  def read_keys
    @public_key = OpenSSL::PKey.read(
      File.read(public_key_file))
    @private_key = OpenSSL::PKey.read(
      File.read(private_key_file))
  end
  #
  def create_dirs
    Dir.mkdir(root_path) unless Dir.exists?(root_path)
    Dir.mkdir(wallet_path) unless Dir.exists?(wallet_path)
  end

  def write_keys
    File.open(private_key_file, "w") do |file|
      file.puts private_key.to_pem
    end
    File.open(public_key_file, "w") do |file|
      file.puts public_key.to_pem
    end
  end

  def create_keys
    @private_key ||= OpenSSL::PKey::RSA.generate(2048)
    @public_key  ||= private_key.public_key
  end

end
