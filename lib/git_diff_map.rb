require 'git_diff_parser'
require 'git_diff_map/line'
require 'git_diff_map/patch'

class GitDiffMap
  DiffRange = Struct.new(:range, :type) do
    def size
      range.end - range.begin
    end

    def offset
      case type
      when :+
        size
      when :-
        -size
      end
    end
  end

  attr_reader :patch
  attr_reader :ranges

  def initialize(patch:)
    @patch = patch
    @ranges = []
  end

  def translate_new_to_original(new_line)
    offset = 0

    patch.changed_lines.each do |line|
      case line.type
      when '-'
        break if new_line + offset < line.number
        offset += 1
      when '+'
        break if new_line < line.number
        return nil if new_line == line.number
        offset -= 1
      end
    end

    new_line + offset
  end

  def translate_original_to_new(original_line)
    offset = 0

    patch.changed_lines.each do |line|
      case line.type
      when '+'
        break if original_line + offset < line.number
        offset += 1
      when '-'
        break if original_line < line.number
        return nil if original_line == line.number
        offset -= 1
      end
    end

    original_line + offset
  end
end
