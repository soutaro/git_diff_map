#
# Originally from rubocop-definition_validator
#
# This class override `changed_lines` method.
# The original method retuns only added lines.
# However we want added and removed lines.
#

class GitDiffMap
  class Patch < GitDiffParser::Patch
    RANGE_INFORMATION_LINE = /^@@ -(?<original_base_line>\d+),\d+ \+(?<new_base_line>\d+),/
    ADDED_LINE   = -> (line) { line.start_with?('+') && line !~ /^\+\+\+/ }
    REMOVED_LINE = -> (line) { line.start_with?('-') && line !~ /^\-\-\-/ }

    def initialize(original_patch)
      @body = original_patch.body
      @file = original_patch.file
      @secure_hash = original_patch.secure_hash
    end

    # @return [Array<Line>] changed lines
    def changed_lines
      original_line = 0
      new_line = 0

      lines.each_with_index.inject([]) do |lines, (content, patch_position)|
        case content
        when RANGE_INFORMATION_LINE
          original_line = Regexp.last_match[:original_base_line].to_i
          new_line = Regexp.last_match[:new_base_line].to_i
        when ADDED_LINE
          line = Line.new(
            content: content,
            number: new_line,
            patch_position: patch_position
          )
          lines << line
          new_line += 1
        when REMOVED_LINE
          line = Line.new(
            content: content,
            number: original_line,
            patch_position: patch_position
          )
          lines << line
          original_line += 1
        when NOT_REMOVED_LINE
          original_line += 1
          new_line += 1
        end

        lines
      end
    end

    def changed_methods
      lines = changed_lines
      lines
        .group_by{|l| l.number}
        .select{|_, v| v.size == 2}
        .select{|_, v| t = v.map(&:type); t.include?('-') && t.include?('+')}
        .select{|_, v| v.all?{|x| x.content =~ /def\s+\w+/}}
        .map{|line, v|
        sorted = v.sort_by(&:type)
        begin
          ChangedMethod.new(sorted.first, sorted.last, line, @file)
        rescue Method::InvalidAST => ex
          warn "Warning: #{ex}\n#{ex.backtrace.join("\n")}"if RuboCop::ConfigLoader.debug
        end
      }
        .compact
    end
  end
end
