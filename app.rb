require_relative 'input_output.rb'
require_relative 'compressor.rb'

if ARGV.size == 1 
  input_file_name = ARGV[0]
  input_system = Input_Output_system.new
  if input_system.read_data(input_file_name)
    compressor = Compressor.new(input_system.compress, input_system.type, input_system.output_file)
    compressor.compress

    compressed_file = File.new(compressor.output_file, 'r')
    original_files = compressed_file.gets
    decompressed_files = Array.new
    decompressed_files = original_files.split(" ")
    files_amount = 0
    content = ""
    read = false
    while line = compressed_file.gets
      if read && line.chop != "FE"
        content += line
      end
      if line.chop == "F"
        read = true
      end
      if line.chop == "FE"
        read = false
        file_name = input_system.output_file.chop + decompressed_files[files_amount].chomp
        if !Dir.exist?(File.dirname(file_name))
          Dir.mkdir(File.dirname(file_name))
        end
        file = File.open(file_name, 'wb')
        file.write(content)
        file.close
        content = ""
        file = File.open(file_name, 'rb')
        decompressed_content = compressor.decompress(file.read)
        file.close
         file = File.open(file_name, 'wb')
        file.write(decompressed_content)
        file.close
        files_amount += 1
      end
    end
    compressed_file.close
  else
    puts "wrong input"
  end
end
