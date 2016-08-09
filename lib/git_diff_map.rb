require 'git_diff_parser'
require 'git_diff_map/line'
require 'git_diff_map/patch'

class GitDiffMap
  attr_reader :patch

  def initialize(patch:)
    @patch = patch
  end

  def translate_new_to_original(new_line)
    translate_new_lines_to_original_lines([new_line]).first
  end

  def translate_new_lines_to_original_lines(lines)
    results = []

    all_changes = patch.changed_lines.dup
    offset = 0

    lines.each do |new_line|
      while true
        if all_changes.empty?
          results << new_line + offset
          break
        else
          change = all_changes.first

          case change.type
          when '-'
            if new_line + offset < change.number
              results << new_line + offset
              break
            end

            offset += 1
          when '+'
            if new_line < change.number
              results << new_line + offset
              break
            end

            if new_line == change.number
              results << nil
              break
            end

            offset -= 1
          end

          all_changes.shift
        end
      end
    end

    results
  end

  def translate_original_to_new(original_line)
    translate_original_lines_to_new_lines([original_line]).first
  end

  def translate_original_lines_to_new_lines(lines)
    results = []

    all_changes = patch.changed_lines.dup
    offset = 0

    lines.each do |original_line|
      while true
        if all_changes.empty?
          results << original_line + offset
          break
        else
          change = all_changes.first

          case change.type
          when '+'
            if original_line + offset < change.number
              results << original_line + offset
              break
            end

            offset += 1
          when '-'
            if original_line < change.number
              results << original_line + offset
              break
            end

            if original_line == change.number
              results << nil
              break
            end

            offset -= 1
          end

          all_changes.shift
        end
      end
    end

    results
  end
end
