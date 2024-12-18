# frozen_string_literal: true


MAP_SIZE = 71
BLOCKERS = 1024

map = Array.new(MAP_SIZE) { Array.new(MAP_SIZE, '.') }

i = 0
ARGF.each_line do |line|
  x, y = line.chomp.split(',').map(&:to_i)
  map[y][x] = '#'
  i += 1
  break if i == BLOCKERS
end

def is_in_bounds?(x, y)
  x >= 0 && x < MAP_SIZE && y >= 0 && y < MAP_SIZE
end

# Function to evaluate the shortest path through the map
# from the start to the end
def shortest_path(map, start_pos, end_pos)
  queue = [[start_pos, 0]]
  shortest_known_paths = {}
  until queue.empty?
    pos, dist = queue.shift
    x, y = pos

    [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |dx, dy|
      new_x = x + dx
      new_y = y + dy
      new_pos = [new_x, new_y]
      new_dist = dist + 1

      next unless is_in_bounds?(new_x, new_y)
      next if shortest_known_paths.key?(new_pos) && shortest_known_paths[new_pos] <= new_dist
      next if map[new_y][new_x] == '#'

      shortest_known_paths[new_pos] = new_dist
      queue << [new_pos, new_dist]
    end
  end

  shortest_known_paths[end_pos]
end

start_pos = [0, 0]
end_pos = [MAP_SIZE - 1, MAP_SIZE - 1]
puts "The answer is: #{shortest_path(map, start_pos, end_pos)}"
