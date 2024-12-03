sum = 0
enabled = true

while line = gets
    line.as(String).scan(/(mul\((\d+),(\d+)\))|do\(\)|don't\(\)/) do |match|
        if match[0] == "do()"
            enabled = true
        elsif match[0] == "don't()"
            enabled = false
        elsif enabled
            a = match[2].to_i
            b = match[3].to_i
            sum += a * b
        end
    end
end

puts "The answer is: #{sum}"
