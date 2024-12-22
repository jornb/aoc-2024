#include <algorithm>
#include <iostream>
#include <limits>
#include <ranges>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>


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

using ShortestPathMap = std::unordered_map<char, std::unordered_map<char, std::vector<std::string>>>;

/// Collection of unique fragments and the number of times they appear
///
/// A fragment is a sequence implicitly starting from 'A' and ends with the letter 'A', e.g. <<^A
using CodeBag = std::unordered_map<std::string, size_t>;

struct CodeBagHash {
    size_t operator()(const CodeBag &bag) const {
        size_t hash = 0;
        for (const auto &entry: bag) {
            hash ^= std::hash<std::string>{}(entry.first) ^ entry.second;
        }
        return hash;
    }
};

struct CodeBagComparator {
    bool operator()(const CodeBag &a, const CodeBag &b) const {
        if (a.size() != b.size()) {
            return false;
        }
        return std::ranges::all_of(a, [&](const auto &entry) {
            return b.find(entry.first) != b.end() && b.at(entry.first) == entry.second;
        });
    }
};

/// Collection of different CodeBags which all produce the same result
using CodeBagOptions = std::unordered_set<CodeBag, CodeBagHash, CodeBagComparator>;

namespace {
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

        auto it_min_path = std::min_element(all_found_paths.begin(), all_found_paths.end(),
                                            [](const auto &a, const auto &b) {
                                                return a.size() < b.size();
                                            });
        auto min_path_size = it_min_path->size();
        std::erase_if(all_found_paths, [&](const auto &path) {
            return path.size() > min_path_size;
        });

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


    CodeBagOptions get_options_for_code(
            const char start_key,
            const char button_to_press,
            const ShortestPathMap &directional_shortest_paths) {
        CodeBagOptions result;

        if (start_key == button_to_press) {
            return {{{"A", 1}}};
        }

        for (const auto &path_A_to_button: directional_shortest_paths.at(start_key).at(button_to_press)) {
            result.insert({{path_A_to_button + 'A', 1}});
        }

        return result;
    }

    /// bag += other
    void code_bag_union(CodeBag &bag, const CodeBag &other) {
        for (const auto &entry: other) {
            bag[entry.first] += entry.second;
        }
    }

    /// Collection of options consisting of "one of a", followed by "one of b"
    CodeBagOptions code_bag_a_then_b(const CodeBagOptions &a, const CodeBagOptions &b) {
        CodeBagOptions result;
        for (const auto &bag_a: a) {
            for (const auto &bag_b: b) {
                CodeBag new_bag = bag_a;
                code_bag_union(new_bag, bag_b);
                result.insert(new_bag);
            }
        }
        return result;
    }

    CodeBagOptions get_options_for_code(
            const std::string &buttons_to_press,
            const ShortestPathMap &directional_shortest_paths) {
        auto heads = get_options_for_code('A', buttons_to_press[0], directional_shortest_paths);

        for (size_t i = 1; i < buttons_to_press.size(); ++i) {
            const auto prev_button = buttons_to_press[i - 1];
            const auto button_to_press = buttons_to_press[i];
            auto next_sequences = get_options_for_code(prev_button, button_to_press, directional_shortest_paths);

            heads = code_bag_a_then_b(heads, next_sequences);

        }
        return heads;
    }


    size_t shortest_recursive_code(const std::string &code,
                                   int num_levels_left,
                                   const ShortestPathMap &directional_shortest_paths) {
        if (num_levels_left == 0) {
            return code.size();
        }

        static std::unordered_map<int, std::unordered_map<std::string, size_t>> cache;
        if (cache[num_levels_left].contains(code)) {
            return cache[num_levels_left][code];
        }

        size_t min_length = std::numeric_limits<size_t>::max();

        for (const auto &bag: get_options_for_code(code, directional_shortest_paths)) {
            size_t length = 0;
            for (const auto &[fragment, fragment_count]: bag) {
                length += fragment_count *
                          shortest_recursive_code(fragment, num_levels_left - 1, directional_shortest_paths);
            }

            if (length < min_length) {
                min_length = length;
            }
        }

        cache[num_levels_left][code] = min_length;
        return min_length;
    }

    size_t shortest_recursive_code_for_option(const CodeBag &bag, const ShortestPathMap &directional_shortest_paths) {
        size_t length = 0;
        for (const auto &[fragment, fragment_count]: bag) {
            length += fragment_count * shortest_recursive_code(fragment, 25, directional_shortest_paths);
        }
        return length;
    }

    size_t shortest_code_among_options(const CodeBagOptions &bags,
                                       const ShortestPathMap &directional_shortest_paths) {
        size_t min_length = std::numeric_limits<size_t>::max();
        for (const auto &bag: bags) {
            auto l = shortest_recursive_code_for_option(bag, directional_shortest_paths);
            if (l < min_length) {
                min_length = l;
            }
        }
        return min_length;
    }
}

int main() {
    auto directional_shortest_paths = get_shortest_paths(directional_neighbors, directional_movement_to_direction);
    auto numerical_shortest_paths = get_shortest_paths(numerical_neighbors, numerical_movement_to_direction);

    size_t answer = 0;
    std::string code;
    while (std::getline(std::cin, code)) {
        std::string numeric_part_of_code_s = code.substr(0, 3);
        size_t numeric_part_of_code = std::atoll(numeric_part_of_code_s.c_str());

        const auto options = get_options_for_code(code, numerical_shortest_paths);
        auto length_of_shortest_sequence = shortest_code_among_options(options, directional_shortest_paths);

        std::cout << code << " => " << length_of_shortest_sequence << " * " << numeric_part_of_code << std::endl;
        answer += length_of_shortest_sequence * numeric_part_of_code;
    }
    std::cout << "The answer is: " << answer << std::endl;

    return 0;
}
