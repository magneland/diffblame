#!/usr/bin/env ruby

if ARGV.size != 2
  warn 'Usage: diffblame.rb <path1> <path2>'
  exit false
end

def blame(path)
  dir = File.dirname(path)
  Dir.chdir(dir) do
    return [''] + `git blame #{path}`.split("\n")
  end
end

def parse_hunk(hunk)
  puts hunk
end

# See https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Normal.html
def parse_diff(blame1, blame2, hunks)
  line1 = line2 = 0
  hunks.each_line do |line|
    case line
    when /^< (.*)/
      unless blame1[line1].end_with?(Regexp.last_match(1))
        warn "diff parse error: #{blame1[line1]} is mismatched with: #{line}"
        exit(1)
      end
      puts "< #{blame1[line1]}"
      line1 += 1
    when /^> (.*)/
      unless blame2[line2].end_with?(Regexp.last_match(1))
        warn "diff parse error: #{blame2[line2]} is mismatched with: #{line}"
        exit(2)
      end
      puts "> #{blame2[line2]}"
      line2 += 1
    when /^---$/
      puts line
    when /^(\d+)a(\d+)$/
      line1 = Regexp.last_match(1).to_i
      line2 = Regexp.last_match(2).to_i
    when /^(\d+)a(\d+),(\d+)$/
      line1 = Regexp.last_match(1).to_i
      line2 = Regexp.last_match(2).to_i
    when /^(\d+)c(\d+)$/
      line1 = Regexp.last_match(1).to_i
      line2 = Regexp.last_match(2).to_i
    when /^(\d+),(\d+)c(\d+)$/
      line1 = Regexp.last_match(1).to_i
      line2 = Regexp.last_match(3).to_i
    when /^(\d+)c(\d+),(\d+)$/
      line1 = Regexp.last_match(1).to_i
      line2 = Regexp.last_match(2).to_i
    when /^(\d+),(\d+)c(\d+),(\d+)$/
      line1 = Regexp.last_match(1).to_i
      line2 = Regexp.last_match(3).to_i
    when /^(\d+)d(\d+)$/
      line1 = Regexp.last_match(1).to_i
      line2 = Regexp.last_match(2).to_i
    when /^(\d+),(\d+)d(\d+)$/
      line1 = Regexp.last_match(1).to_i
      line2 = Regexp.last_match(3).to_i
    else
      warn "diff parse error: #{line}"
      exit(3)
    end
  end
end

def main(path1, path2)
  blame1 = blame(path1)
  blame2 = blame(path2)
  hunks = `diff #{path1} #{path2}`
  parse_diff(blame1, blame2, hunks)
end

main(*ARGV)
