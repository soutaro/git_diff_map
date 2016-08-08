#
# Originally from rubocop-definition_validator
#
# Encoding of `line` is changed:
# `line` in added line is the number of line in old file (not changed).
# `line` in deleted line is the number of line in new file (changed).
#
class GitDiffMap
  class Line < GitDiffParser::Line
    attr_reader :content

    # trim `+` or `-` prefix
    def body
      content[1..-1]
    end

    # @return [String] + or -
    def type
      content[0]
    end
  end
end
