require 'minitest/autorun'
require 'pathname'
require 'git_diff_parser'

$LOAD_PATH << Pathname(__dir__).parent + "lib"

require 'git_diff_map'
