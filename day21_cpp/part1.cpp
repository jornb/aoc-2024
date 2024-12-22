#include <algorithm>
#include <iostream>
#include <unordered_map>
#include <limits>
#include <string>
#include <vector>
#include <ranges>

using ShortestPathMap = std::unordered_map<char, std::unordered_map<char, std::vector<std::string>>>;

static const std::unordered_map<char, std::string> directional_neighbors = {
        {'^', {"Av"}},
        {'A', {"^>"}},
        {'<', {"v"}},
        {'v', {"<^>"}},
        {'>', {"vA"}},
};

static const std::unordered_map<char, std::string> numerical_neighbors = {
        {'7', "84"},
        {'8', "759"},
        {'9', "86"},
        {'4', "751"},
        {'5', "8642"},
        {'6', "953"},
        {'1', "42"},
        {'2', "5310"},
        {'3', "62A"},
        {'0', "2A"},
        {'A', "30"},
};

static const std::unordered_map<char, std::unordered_map<char, char>> numerical_movement_to_direction = {
        {'9', {{'8', '<'}, {'6', 'v'}}},
        {'8', {{'9', '>'}, {'7', '<'}, {'5', 'v'}}},
        {'7', {{'8', '>'}, {'4', 'v'}}},
        {'6', {{'5', '<'}, {'3', 'v'}, {'9', '^'}}},
        {'5', {{'6', '>'}, {'4', '<'}, {'2', 'v'}, {'8', '^'}}},
        {'4', {{'5', '>'}, {'1', 'v'}, {'7', '^'}}},
        {'3', {{'2', '<'}, {'6', '^'}, {'A', 'v'}}},
        {'2', {{'3', '>'}, {'1', '<'}, {'0', 'v'}, {'5', '^'}}},
        {'1', {{'2', '>'}, {'4', '^'}}},
        {'0', {{'A', '>'}, {'2', '^'}}},
        {'A', {{'0', '<'}, {'3', '^'}}},
};

static const std::unordered_map<char, std::unordered_map<char, char>> directional_movement_to_direction = {
        {'<', {{'v', '>'}}},
        {'^', {{'A', '>'}, {'v', 'v'}}},
        {'v', {{'>', '>'}, {'^', '^'}, {'<', '<'}}},
        {'A', {{'^', '<'}, {'>', 'v'}}},
        {'>', {{'v', '<'}, {'A', '^'}}},
};

namespace {
    void keep_only_shortest(std::vector<std::string> &paths) {
        auto it_min_path = std::min_element(paths.begin(), paths.end(),
                                            [](const auto &a, const auto &b) {
                                                return a.size() < b.size();
                                            });
        auto max_path_size = it_min_path->size();
        std::erase_if(paths, [&](const auto &path) {
            return path.size() > max_path_size;
        });
    }

    std::vector<std::string> get_shortest_paths(
            char key_from,
            char key_to,
            const std::unordered_map<char, std::string> &key_to_neighbors,
            const std::unordered_map<char, std::unordered_map<char, char>> &movement_to_direction) {

        if (key_to_neighbors.at(key_from).find(key_to) != std::string::npos) {
            return {std::string(1, movement_to_direction.at(key_from).at(key_to))};
        }

        std::vector<std::string> all_found_paths;
        std::vector<std::string> heads;

        for (const char &neighbor: key_to_neighbors.at(key_from)) {
            heads.emplace_back(1, neighbor);
        }

        while (!heads.empty()) {
            auto path = heads.back();
            heads.pop_back();

            for (const char &neighbor: key_to_neighbors.at(path.back())) {
                // Don't revisit nodes
                if (path.find(neighbor) != std::string::npos || neighbor == key_from) {
                    continue;
                }

                if (neighbor == key_to) {
                    all_found_paths.push_back(path + neighbor);
                } else {
                    heads.push_back(path + neighbor);
                }
            }
        }

        keep_only_shortest(all_found_paths);

        std::vector<std::string> result;
        for (const auto &path: all_found_paths) {
            std::string path_directions;
            for (size_t i = 0; i < path.size(); ++i) {
                const char prev_key = i == 0 ? key_from : path[i - 1];
                const char next_key = path[i];
                path_directions.push_back(movement_to_direction.at(prev_key).at(next_key));
            }
            result.push_back(path_directions);
        }
        return result;
    }

    ShortestPathMap get_shortest_paths(
            const std::unordered_map<char, std::string> &key_to_neighbors,
            const std::unordered_map<char, std::unordered_map<char, char>> &movement_to_direction) {
        ShortestPathMap result;

        for (const auto key_from: key_to_neighbors | std::views::keys) {
            for (const auto key_to: key_to_neighbors | std::views::keys) {
                if (key_from != key_to) {
                    result[key_from][key_to] = get_shortest_paths(key_from, key_to, key_to_neighbors,
                                                                  movement_to_direction);
                } else {
                    result[key_from][key_to] = {};
                }
            }
        }

        return result;
    }


    std::vector<std::string> get_control_candidate_sequence(
            const char start_key,
            const char button_to_press,
            const ShortestPathMap &directional_shortest_paths) {
        std::vector<std::string> result;

        if (start_key == button_to_press) {
            return {"A"};
        }

        for (const auto &path_A_to_button: directional_shortest_paths.at(start_key).at(button_to_press)) {
            result.push_back(path_A_to_button + 'A');
        }

        return result;
    }

    std::vector<std::string> get_control_candidate_sequence(
            const char start_key,
            const std::string &buttons_to_press,
            const ShortestPathMap &directional_shortest_paths) {
        auto heads = get_control_candidate_sequence(start_key, buttons_to_press[0], directional_shortest_paths);

        for (size_t i = 1; i < buttons_to_press.size(); ++i) {
            const auto prev_button = buttons_to_press[i - 1];
            const auto button_to_press = buttons_to_press[i];
            std::vector<std::string> new_heads;
            for (auto &head: heads) {
                const auto next_sequences = get_control_candidate_sequence(prev_button, button_to_press,
                                                                           directional_shortest_paths);
                for (const auto &next_sequence: next_sequences) {
                    new_heads.push_back(head + next_sequence);
                }
            }
            heads = new_heads;
        }

        return heads;
    }


    // Creates control sequence to move the robot from A to target, back to A
    std::vector<std::string> get_control_candidate_sequence(
            const char robot_start_key,
            const char robot_target_key,
            const ShortestPathMap &robot_shortest_paths,
            const ShortestPathMap &directional_shortest_paths) {

        if (robot_start_key == robot_target_key) {
            return {"A"};
        }

        std::vector<std::string> result;

        for (const auto &control_sequence: robot_shortest_paths.at(robot_start_key).at(robot_target_key)) {
            std::vector<std::string> return_paths = directional_shortest_paths.at(control_sequence.back()).at('A');

            for (const auto &x: get_control_candidate_sequence('A', control_sequence, directional_shortest_paths)) {
                for (const auto &y: return_paths) {
                    result.push_back(x + y + 'A');
                }
            }
        }

        keep_only_shortest(result);

        return result;
    }


    size_t solve(const std::string &code, const ShortestPathMap &directional_shortest_paths,
                 const ShortestPathMap &numerical_shortest_paths) {
        size_t min_length = std::numeric_limits<size_t>::max();
        for (const auto &s1: get_control_candidate_sequence('A', code, numerical_shortest_paths)) {
//        std::cout << s1 << std::endl;
            for (const auto &s2: get_control_candidate_sequence('A', s1, directional_shortest_paths)) {
//            std::cout << "\t" << s2 << std::endl;
                for (const auto &s3: get_control_candidate_sequence('A', s2, directional_shortest_paths)) {
//                if (min_length != std::numeric_limits<size_t>::max() && s3.size() < min_length) {
//                    std::cout << "Reduced from " << min_length << " to " << s3.size() << std::endl;
//                }
                    if (s3.size() < min_length) {
                        min_length = s3.size();
                    }
                }
            }
        }
        return min_length;
    }
}

int main() {
    auto directional_shortest_paths = get_shortest_paths(directional_neighbors, directional_movement_to_direction);
    auto numerical_shortest_paths = get_shortest_paths(numerical_neighbors, numerical_movement_to_direction);

    size_t answer = 0;

    // Read each line from stdin
    std::string code;
    while (std::getline(std::cin, code)) {
        std::string numeric_part_of_code_s = code.substr(0, 3);
        size_t numeric_part_of_code = std::atoll(numeric_part_of_code_s.c_str());
        size_t length_of_shortest_sequence = solve(code, directional_shortest_paths, numerical_shortest_paths);

        std::cout << code << " => " << length_of_shortest_sequence << " * " << numeric_part_of_code << std::endl;
        answer += length_of_shortest_sequence * numeric_part_of_code;
    }
    std::cout << "The answer is: " << answer << std::endl;

    return 0;
}
