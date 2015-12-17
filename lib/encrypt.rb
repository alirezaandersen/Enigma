require_relative 'encryptor'
require_relative 'keygen'
require_relative 'dategen'
require_relative 'constants'
require 'pry'

unless ARGV.length == 2
	puts "Not the right number of arguments."
	puts "Usage: ruby #{__FILE__} message.txt encrypted.txt\n"
	exit
end

def read_file(file_name)
	file = File.open(file_name, "r")
	data = file.read.strip	#strip to remove EOF character
	puts "inside read_file: data = #{data}"
	file.close
	return data
end

def encrypt_file(file_name,data)
	puts "inside encrypte_file: data = #{data}"
	key = Keygen.new.create_new_key
	encryptor = Encryptor.new(data,key,Time.now)
	encryptext = encryptor.encrypt
	File.write(file_name, encryptext)
	puts "Created #{file_name} with the key #{encryptor.key} and date #{encryptor.date}"
end
__FILE__
message_file = ARGV[0]
data = read_file(message_file)

encrypted_file = ARGV[1]
encrypt_file(encrypted_file, data)
