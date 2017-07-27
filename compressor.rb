class Compressor
  attr_accessor :files_to_compress, :output_file
  
  @@IDX_BITS = 16
  @@CLEAR = 256

  def initialize(for_compression, mode, outfile)
    @output_file = outfile
    @mode = mode
    @parent_directory = for_compression
    @files_to_compress = Array.new
    if mode == 2
      @files_to_compress = check_compressing_directory(for_compression)
    else
      @files_to_compress.push(for_compression)
    end
  end

  def check_compressing_directory(file_name)
    file_array = Array.new
    file_name += "*"
    Dir["#{file_name}"].each  do |f|
      if File.file?(f)
        file_array.push(f)
      else
        if File.directory?(f)
          file_array += check_further_compressing_directory(f)
        end
      end
    end
    file_array  
  end

  def check_further_compressing_directory(file_name)
    file_array = Array.new
    file_name += "/*"
    Dir["#{file_name}"].each  do |f|
      if File.file?(f)
        file_array.push(f)
      else
        if File.directory?(f)
          file_array.push(check_further_compressing_directory(f))
        end
      end
    end 
    file_array
  end

  def prepare_new_file_names
    if @mode == 2
      @files_to_compress.each do |file|
        file = file.slice!(0, @parent_directory.size()-1)
      end
    else
      dir = @files_to_compress[0].slice!(0, File.dirname(@files_to_compress[0]).size())
      @files_to_compress[0] = @files_to_compress[0].slice!(0,dir.size)
    end
  end

  def compress
    result = ""
    files = ""
    @files_to_compress.each do |file|
      file_to_compress = File.open(file, 'rb')
      file_stream = file_to_compress.read
      file_to_compress.close
      result += "F\n"
      result +=compress_file(file_stream)
      result += "\nFE\n"
    end
    prepare_new_file_names()
    @files_to_compress.each do |file|
      files += "#{file} "
    end
    files += "\n"
    if !Dir.exist?(@output_file)
      Dir.mkdir(@output_file)
    end
    @output_file += "archive.txt"
    archive = File.open(@output_file, 'wb')
    archive.write(files+result)
    archive.close
  end

  def compress_file(data_stream)
    result = []
    dict, hash = build_dict()
    w = nil
    idx = 0
    
    data_stream.each_byte do |byte|
      k = byte.chr
      wk = "#{w}#{k}"
      if hash[wk].nil? ==false
        w = wk
      else
        hash[wk] = dict.size
        dict << wk
        result << hash[w]
        w = k

        if dict.length >= (1 << @@IDX_BITS)
          result << k.ord
          dict, hash = build_dict()
          result << @@CLEAR
          w = nil
        end
      end

      idx += 1
    end

    result << w.ord if w
    pack(result)
  end

  def decompress(stream)
    result = ''
    dict, hash = build_dict
    array = unpack(stream)
    result << array[0].chr
      w = array[0].chr
      array[1..-1].each do |byte|
        next if byte == 0
        if w.nil?
          result << byte.chr
          w = byte.chr
          next
        end
        if byte == @@CLEAR
          dict, hash = build_dict
          w = nil
          next
        end
      entry = dict[byte]
      entry ||= w + w[0] # Welch correction
      dict << "#{w}#{entry[0]}"
      result << entry
      w = entry
    end
    result
  end

  def build_dict()
    dict = (0..255).to_a.map { |c| c.chr }
    dict[@@CLEAR] = -1
    hash = {}
    dict.each_index { |idx| hash[dict[idx]] = idx }
    return dict, hash
  end

  def pack (array)
    fmt = "%0#{@@IDX_BITS}b"
    t = array.map { |n| fmt % n }.join('')
    result = t.scan(/\d{8}/).map { |n| n.to_i(2).chr }.join('')
    result += t[(t.length/8)*8..-1].to_i(2).chr if t.length % 8
    result
  end

  def unpack (stream)
    regex = /\d{#{@@IDX_BITS}}/
    t = stream.each_byte.to_a.select.map { |n| '%08b' % n}.join('')
    result = t.scan(regex).map { |n| n.to_i(2) }
    result << t[(t.length/@@IDX_BITS)*@@IDX_BITS..-1].to_i(2) if t.length % @@IDX_BITS
    result
  end
end