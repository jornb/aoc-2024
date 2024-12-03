sum = 0

while line = gets
    line.as(String).scan(/mul\((\d+),(\d+)\)/) do |match|
        a = match[1].to_i
        b = match[2].to_i
        sum += a * b
    end
end

puts "The answer is: #{sum}"
