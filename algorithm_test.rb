require_relative 'input_output.rb'
require_relative 'compressor.rb'
describe Compressor do
  it "should compress" do
    input_file_name = "./good_input.txt"
    input_system = Input_Output_system.new
    input_system.read_data(input_file_name)
    compressor = Compressor.new(input_system.compress, input_system.type, input_system.output_file)
    compressor.compress
    expect(File.size?("/home/nik/Documents/mstu/algoritms_and_data_structures/test/new_dir/archive.txt")).to be <= File.size?("/home/nik/Documents/mstu/algoritms_and_data_structures/test/test_directory/a.txt")
  end
end