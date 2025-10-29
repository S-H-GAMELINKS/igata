# frozen_string_literal: true

require 'zip'

class FileProcessor
  CHUNK_SIZE = 1.megabyte

  def process(file)
    validate_file(file)
    compress(file)
  end

  private

  def validate_file(file)
    raise ArgumentError unless file.exist?
  end

  def compress(file)
    Zip::File.open(file.path) do |zipfile|
      zipfile.add(file.name, file.path)
    end
  end
end
