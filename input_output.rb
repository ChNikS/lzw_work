class Input_Output_system
  
  attr_accessor :compress, :output_file, :type

  def initialize()
  end

  def read_compressong_files()
    f = File.new(@compress, 'r')
    line = f.gets
  end
  
  def read_data(input_file_name)
    if File.file?(input_file_name)
      input_file = File.new(input_file_name, 'r')
      @compress = input_file.gets.chomp
      @output_file = input_file.gets.chomp
      input_file.close 
      if File.file?(@compress) then @type = 1 end
      if File.directory?(@compress) then @type = 2 end
      result = (@type == 1|| @type == 2)
    else
      puts "exit. That is not a file"
      result = false
    end
  end
end