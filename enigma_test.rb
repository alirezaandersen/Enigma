require 'simplecov'
SimpleCov.start
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

require './lib/enigma'

class EnigmaTest < Minitest::Test

  def test_encrypted_message_out_puts_correct_numeric_value_associated_with_charactor
   enc = Encryptor.new(message, "12345", "151215")
   rotation_array = enc.key_rotation("12345")
   assert_equal "12", rotation_array[0]
   assert_equal "23", rotation_array[1]
   assert_equal "34", rotation_array[2]
   assert_equal "45", rotation_array[3]
  end

  def test_encrypts_with_specific_key
    key = '34562'
    enc = Encryptor.new("my_message", key)
    encrypted_message = enc.encrypt
    refute_equal "my_message", encrypted_message
  end

  def test_decryptor_decrypts_encrypted_message_succesfully
    message = "Your my Favorite Instructor ..end.."
    enc = Encryptor.new(message, "12345", "151215")
    encrypted_message = enc.encrypt
    dec = Decryptor.new(encrypted_message, "12345", "151215")
    plaintext = dec.decrypt
    assert_equal message, plaintext
  end

end
