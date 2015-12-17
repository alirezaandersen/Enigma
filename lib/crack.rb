require_relative 'cracked'

unless ARGV.length == 6
  puts "Not the right number of arguments."
	puts "Usage: ruby #{__FILE__} encrypted.txt decrypted.txt <key> <ddmmyy>\n"
	exit
end

  def read_file(file_name)
    file = File.open(file_name, "r")
    data = file.read.strip
    puts "inside read_file: data = #{data}"
    file.close
    return data
  end

def cracked_file(file_name, data, date)
  file = File.open(file_name, "r")
  puts "inside cracked_file: data = #{data}"
  crackle = Crack.new(data)
  plaintext = crack.crack
  File.write(file_name, plaintext)
  puts "Created #{file_name} with the date #{cracked.date}"
end

__FILE__

encrypted_file = ARGV[0]
data = read_file(encrypted_file)

cracked_file = ARGV[1]
date = ARGV[2]
crack_file(cracked_file, data, date)
