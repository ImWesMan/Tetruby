require 'openssl'
require 'base64'
require 'securerandom'

class User
  attr_reader :username, :password_hash, :salt, :data

  def initialize(username, password, salt=nil)
    @username = username
    @salt = salt || SecureRandom.hex(16) 
    @password_hash = hash_password(password) 
  end

  def hash_password(password)
    OpenSSL::PKCS5.pbkdf2_hmac(password, @salt, 10000, 32, 'sha256') 
  end

  def encrypt_data(data)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.key = @password_hash
    cipher.iv = iv = cipher.random_iv
    encrypted_data = cipher.update(data.to_json) + cipher.final
    { encrypted_data: Base64.strict_encode64(encrypted_data), iv: Base64.strict_encode64(iv) }
  end

  def decrypt_data(encrypted_data, iv, password)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.decrypt
    cipher.key = hash_password(password)
    cipher.iv = Base64.strict_decode64(iv)
  
    begin
      decrypted_data = cipher.update(Base64.strict_decode64(encrypted_data)) + cipher.final
      decrypted_data = JSON.parse(decrypted_data)
    rescue OpenSSL::Cipher::CipherError => e
      raise WrongPasswordError, "Incorrect password or data corruption."
    rescue JSON::ParserError => e
      raise "Error parsing decrypted data: #{e.message}"
    end
  
    decrypted_data
  end

  def save_highscore(score)
    encrypted_data = encrypt_data({ highscore: score })
    user_data = { salt: @salt, encrypted_data: encrypted_data } 
    File.write("#{username}_data.enc", Marshal.dump(user_data)) 
    puts "Highscore saved: #{score}"
  end

  def load_data(password)
    return nil unless File.exist?("#{username}_data.enc") 
    user_data = Marshal.load(File.read("#{username}_data.enc")) 

    @salt = user_data[:salt]
    encrypted_data = user_data[:encrypted_data]

    decrypt_data(encrypted_data[:encrypted_data], encrypted_data[:iv], password)  # Decrypt using provided password
  end
end

class WrongPasswordError < StandardError; end
