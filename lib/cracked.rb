require_relative 'dategen'
require_relative 'constants'
require_relative 'decryptor'
require 'pry'


class Crack

  attr_accessor :crack_key, :date

  def initialize(message, date = nil)
    if message.nil?
      raise ArgumentError, "Invalid message, message was nil"
    end
    @message = message
    @crack_key = " "
    @date =  Dategen.new(date).key
    @char_set = Constants::CHARSET.split(//)
    @num_digits = Constants::CHARSET.split(//).length.to_s.length
    @offset_array = process_date(@date)
    # puts "@offset_array = " + @offset_array.inspect
  end

  def crackle
    rotation_array = []
    #rotation_array = (current_position - original_position - current_date_offset)

    #(@amessage.length-1) %4 => indicies for respective positions in date offset and rotation array
    last_dot_offset = @offset_array[(@message.length-1) % 4]
    second_to_last_dot_offset = @offset_array[(@message.length-2) % 4]
    d_rotation_offset = @offset_array[(@message.length-3) % 4]
    n_rotation_offset = @offset_array[(@message.length-4) % 4]

    #positions in the charset of original unencrypted characters
    dot_position = @char_set.index('.')
    d_position = @char_set.index('d')
    n_position = @char_set.index('n')

    encrypted_last_character = @char_set.index(@message[-1])
    encrypted_second_to_last_character = @char_set.index(@message[-2])
    encrypted_third_to_last_character = @char_set.index(@message[-3])
    encrypted_fourth_to_last_character = @char_set.index(@message[-4])

    rotation_array[(@message.length-1) % 4] = (encrypted_last_character - dot_position -last_dot_offset) % @char_set.length
    rotation_array[(@message.length-2) % 4] =  (encrypted_second_to_last_character - dot_position - second_to_last_dot_offset) % @char_set.length
    rotation_array[(@message.length-3) % 4] = (encrypted_third_to_last_character - d_position - d_rotation_offset) % @char_set.length
    rotation_array[(@message.length-4) % 4] = (encrypted_fourth_to_last_character - n_position - n_rotation_offset) % @char_set.length
    #  puts "rotation_array = " + rotation_array.inspect

    increment = @char_set.length
    a_rot = generate_increments(rotation_array[0], increment).map { |val| "%02d" % val.to_s }
    b_rot = generate_increments(rotation_array[1], increment).map { |val| "%02d" % val.to_s }
    c_rot = generate_increments(rotation_array[2], increment).map { |val| "%02d" % val.to_s }
    d_rot = generate_increments(rotation_array[3], increment).map { |val| "%02d" % val.to_s }

    crack(rotation_array)
  end  #% @char_set.lengthend


  def process_date(date)
    date_squared = date.to_i ** 2
    #puts "date_squared = " + date_squared.to_s
    off_sets = date_squared.to_s.split("")[-4..-1].join
    #puts "off_sets = " + off_sets.to_s
    a_date_gen = off_sets[-4].to_i
    b_date_gen = off_sets[-3].to_i
    c_date_gen = off_sets[-2].to_i
    d_date_gen = off_sets[-1].to_i
    [a_date_gen, b_date_gen, c_date_gen, d_date_gen]
  end

  #generate all the possible iterations of rotation values
  def generate_increments(rotation_value,increment)
    increments_array = []

    i=1
    loop do
      increments_array << (rotation_value - (increment*i)) % @num_digits
      if (rotation_value - (increment*i)) < 0
        break
      end
      i += 1
    end

    increments_array << rotation_value

    i = 1
    loop do
      if rotation_value + (increment*i) >= (10 ** @num_digits)
        break
      end
      increments_array << rotation_value + (increment*i)
      i += 1
    end
    increments_array
  end

  def crack(rotation_array)
    a_rot_val = b_rot_val = c_rot_val = d_rot_val = ''

    increment = @char_set.length
    a_rot = generate_increments(rotation_array[0].to_i, increment).map { |val| "%02d" % val.to_s }
    b_rot = generate_increments(rotation_array[1].to_i, increment).map { |val| "%02d" % val.to_s }
    c_rot = generate_increments(rotation_array[2].to_i, increment).map { |val| "%02d" % val.to_s }
    d_rot = generate_increments(rotation_array[3].to_i, increment).map { |val| "%02d" % val.to_s }

    a_rot.each do |a_value|
      b_rot.each do |b_value|
        c_rot.each do |c_value|
          d_rot.each do |d_value|
            if (a_value[1] == b_value[0]) && (b_value[1] == c_value[0]) && (c_value[1] == d_value[0])
              a_rot_val = a_value
              b_rot_val = b_value
              c_rot_val = c_value
              d_rot_val = d_value
            end
          end
        end
      end
    end
=begin
    # puts a_rot.inspect
    # puts b_rot.inspect
    # puts c_rot.inspect
    # puts d_rot.inspect
    # puts "a_rot_val.inspect = " + a_rot_val.inspect
    # puts "b_rot_val.inspect = " + b_rot_val.inspect
    # puts "c_rot_val.inspect = " + c_rot_val.inspect
    # puts "d_rot_val.inspect = " + d_rot_val.inspect
=end

    if a_rot_val[0].nil? || a_rot_val[1].nil? || b_rot_val[1].nil? || c_rot_val[1].nil? || d_rot_val[1].nil?
      raise ArgumentError, "encrypted message: '#{@message}' seems to be missing ..end.."
    end

    @crack_key = a_rot_val[0] + a_rot_val[1] + b_rot_val[1] + c_rot_val[1] + d_rot_val[1]

    #   puts key
    decryptor = Decryptor.new(@message,@crack_key,@date)
    decryptor.decrypt
 end
end
