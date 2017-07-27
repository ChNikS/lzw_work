require_relative 'input_output.rb'

describe Input_Output_system do
  it "checks input params" do
    @ioput = Input_Output_system.new
    expect(@ioput.read_data("./wrong_input.txt")).to eq false
    expect(@ioput.read_data("./good_input.txt")).to eq true
  end
end