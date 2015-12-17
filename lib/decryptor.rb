require_relative 'keygen'
require_relative 'dategen'
require_relative 'constants'
require 'pry'

class Decryptor

  attr_reader :key, :date

  def initialize(message, key, date)
    if message.nil?
      raise ArgumentError, "Invalid message, message was nil"
    end
    @encrypted_message = message
    @key = Keygen.new(key).key
    @date = Dategen.new(date).key
    @char_set = Constants::CHARSET.split(//)
    @num_digits = Constants::CHARSET.split(//).length.to_s.length
    #to determine the number of digits we are working with for each character
    #for example: when length of charset reaches 100, we need to make sure '5'
    # gets padded like '005'
    @rotation_array = key_rotation(@key)
    @offset_array = process_date(@date)
    @total_offset = [@offset_array,@rotation_array].transpose.map{|arr|
      arr.map!{ |x| x.to_i }
      arr.reduce(:+)}
    end

    def decrypt
      plaintext = ""
      @encrypted_message.split(//).each_with_index do |char, num|
        current_position = @char_set.index(char)
        current_offset = @total_offset[num % 4]

        segment = (current_position.to_i - current_offset.to_i) % @char_set.length
        plaintext << @char_set[segment]
      end
      plaintext
    end

    def key_rotation(key) #creates 2 digit custom code for ABCD
      a_key_rotation = key[0..1]
      b_key_rotation = key[1..2]
      c_key_rotation = key[2..3]
      d_key_rotation = key[3..4]

      [a_key_rotation, b_key_rotation, c_key_rotation, d_key_rotation]
    end

    def process_date(date)
      date_squared = date.to_i ** 2
      #puts "date_squared = " + date_squared.to_s
      off_sets = date_squared.to_s.split("")[-4..-1].join
      a_date_gen = off_sets[-4].to_i
      b_date_gen = off_sets[-3].to_i
      c_date_gen = off_sets[-2].to_i
      d_date_gen = off_sets[-1].to_i
      [a_date_gen, b_date_gen, c_date_gen, d_date_gen]
    end
  end
