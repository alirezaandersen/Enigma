require_relative 'decryptor'

unless ARGV.length == 4
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

def decrypt_file(file_name,data,key,date)
	puts "inside decrypt_file: data = #{data}"
	decryptor = Decryptor.new(data,key,date)
	plaintext = decryptor.decrypt
	File.write(file_name, plaintext)
	puts "Created #{file_name} with the key #{decryptor.key} and date #{decryptor.date}"
end
__FILE__
encrypted_file = ARGV[0]
data = read_file(encrypted_file)

decrypted_file = ARGV[1]
key = ARGV[2]
date = ARGV[3]
decrypt_file(decrypted_file, data, key, date)
