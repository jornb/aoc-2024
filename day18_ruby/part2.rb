# frozen_string_literal: true

MAP_SIZE = 71

def is_in_bounds?(x, y)
  x >= 0 && x < MAP_SIZE && y >= 0 && y < MAP_SIZE
end

map = Array.new(MAP_SIZE) { Array.new(MAP_SIZE, '.') }

def heuristic(pos, end_pos)
  (pos[0] - end_pos[0]).abs + (pos[1] - end_pos[1]).abs
end

def exists_path(map, start_pos, end_pos)
  queue = [[start_pos, heuristic(start_pos, end_pos)]]
  visited = [start_pos]
  until queue.empty?
    pos, _ = queue.shift
    x, y = pos

    [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |dx, dy|
      new_x = x + dx
      new_y = y + dy
      new_pos = [new_x, new_y]
      return true if new_pos == end_pos

      next unless is_in_bounds?(new_x, new_y)
      next if map[new_y][new_x] == '#'
      next if visited.include?(new_pos)

      h = heuristic(new_pos, end_pos)
      index = queue.bsearch_index { |_, d| d > h } || queue.size
      queue.insert(index, [new_pos, heuristic(new_pos, end_pos)])
      visited << new_pos
    end
  end

  false
end

ARGF.each_line do |line|
  x, y = line.chomp.split(',').map(&:to_i)
  map[y][x] = '#'
  
  unless exists_path(map, [0, 0], [MAP_SIZE - 1, MAP_SIZE - 1])
    puts map.map { |row| row.join('') }
    puts "The answer is: #{x},#{y}"
    break
  end
end
