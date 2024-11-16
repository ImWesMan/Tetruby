require 'openssl'
require 'base64'
require 'securerandom'

class User
  attr_reader :username, :password_hash, :salt, :data

  def initialize(username, password)
    @username = username
    @salt = SecureRandom.hex(16)  
    @password_hash = hash_password(password)
    @data = {}  
  end

  def hash_password(password)
    OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, @salt, 10000, 64)
  end

  def encrypt_data(data)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.key = @password_hash
    cipher.iv = iv = cipher.random_iv
    encrypted_data = cipher.update(data.to_json) + cipher.final
    { encrypted_data: Base64.encode64(encrypted_data), iv: Base64.encode64(iv) }
  end

  def decrypt_data(encrypted_data, iv)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.decrypt
    cipher.key = @password_hash
    cipher.iv = Base64.decode64(iv)
    decrypted_data = cipher.update(Base64.decode64(encrypted_data)) + cipher.final
    JSON.parse(decrypted_data)
  end

  def save_highscore(score)
    encrypted_data = encrypt_data({ highscore: score })
    # Store the encrypted data securely, for example in a file
    File.write("#{username}_data.enc", Marshal.dump(encrypted_data))
  end

  def load_data
    return nil unless File.exist?("#{username}_data.enc")
    encrypted_data = Marshal.load(File.read("#{username}_data.enc"))
    decrypt_data(encrypted_data[:encrypted_data], encrypted_data[:iv])
  end
end
