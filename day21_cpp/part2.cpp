#include <iostream>
#include <unordered_map>
#include <unordered_set>
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


/// A fragment is a sequence implicitly starting from 'A' and ends with the letter 'A', e.g. <<^A

/// Collection of unique fragments and the number of times they appear
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

        for (const auto &entry: a) {
            if (b.find(entry.first) == b.end() || b.at(entry.first) != entry.second) {
                return false;
            }
        }

        return true;
    }
};

/// Collection of different CodeBags which all produce the same result
using CodeBagOptions = std::unordered_set<CodeBag, CodeBagHash, CodeBagComparator>;

size_t BUCKET_COUNT = 100;

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


    CodeBagOptions get_control_candidate_bag(
            const char start_key,
            const char button_to_press,
            const ShortestPathMap &directional_shortest_paths) {
        CodeBagOptions result{BUCKET_COUNT};

        if (start_key == button_to_press) {
            return {{{"A", 1}}};
        }

        for (const auto &path_A_to_button: directional_shortest_paths.at(start_key).at(button_to_press)) {
            result.insert({{path_A_to_button + 'A', 1}});
        }

        return result;
    }

    // bag[i] += other[i] * n
    void code_bag_union(CodeBag &bag, const CodeBag &other, const size_t n = 1) {
        for (const auto &entry: other) {
            bag[entry.first] += entry.second * n;
        }
    }

    /// Collection of options consisting of "one of a", followed by "N of b"
    CodeBagOptions code_bag_a_then_b(const CodeBagOptions &a, const CodeBagOptions &b, const size_t n = 1) {
        CodeBagOptions result{BUCKET_COUNT};
        for (const auto &bag_a: a) {
            for (const auto &bag_b: b) {
                CodeBag new_bag = bag_a;
                code_bag_union(new_bag, bag_b, n);
                result.insert(new_bag);
            }
        }
        return result;
    }

    size_t num_button_presses(const CodeBag &bag) {
        size_t total = 0;
        for (const auto &[code, num]: bag) {
            total += code.size() * num;
        }
        return total;
    }

    size_t num_button_presses(const CodeBagOptions &bag) {
        auto it = std::min_element(bag.begin(), bag.end(), [](const auto &a, const auto &b) {
            return num_button_presses(a) < num_button_presses(b);
        });
        return num_button_presses(*it);
    }

    void keep_only_shortest(CodeBagOptions &options) {
        auto it_min_path = std::min_element(options.begin(), options.end(),
                                            [](const auto &a, const auto &b) {
                                                return num_button_presses(a) < num_button_presses(b);
                                            });
        auto max_presses = num_button_presses(*it_min_path);
        std::erase_if(options, [&](const auto &code) {
            return num_button_presses(code) > max_presses;
        });
    }

    void print_code_bag(const CodeBag &bag) {
        for (const auto &entry: bag) {
            std::cout << entry.first << ": " << entry.second << std::endl;
        }
    }

    CodeBagOptions get_control_candidate_bag(
            const std::string &buttons_to_press,
            const ShortestPathMap &directional_shortest_paths) {

        static std::unordered_map<std::string, CodeBagOptions> cache;
        bool cache_enabled = directional_shortest_paths.size() == 5;
        if (cache_enabled && cache.contains(buttons_to_press)) {
            return cache.at(buttons_to_press);
        }


        auto heads = get_control_candidate_bag('A', buttons_to_press[0], directional_shortest_paths);

        for (size_t i = 1; i < buttons_to_press.size(); ++i) {
            const auto prev_button = buttons_to_press[i - 1];
            const auto button_to_press = buttons_to_press[i];
            auto next_sequences = get_control_candidate_bag(prev_button, button_to_press,
                                                            directional_shortest_paths);

            heads = code_bag_a_then_b(heads, next_sequences);

        }

//        keep_only_shortest(heads);

        if (cache_enabled) {
            cache[buttons_to_press] = heads;
        }
        return heads;
    }

    CodeBagOptions get_control_candidate_bag(
            const CodeBag &buttons_to_press,
            const ShortestPathMap &directional_shortest_paths) {

        CodeBagOptions heads;

        for (const auto &[fragment, fragment_count]: buttons_to_press) {
            auto bags_for_fragment = get_control_candidate_bag(fragment, directional_shortest_paths);

            if (heads.empty()) {
                heads = bags_for_fragment;
            } else {
                heads = code_bag_a_then_b(heads, bags_for_fragment, fragment_count);
            }
        }

        keep_only_shortest(heads);

        return heads;
    }


    CodeBagOptions get_control_candidate_bag(
            const CodeBagOptions &options_for_buttons_to_press,
            const ShortestPathMap &directional_shortest_paths) {

        CodeBagOptions heads;

        for (const auto &buttons_to_press: options_for_buttons_to_press) {
            for (const auto &option: get_control_candidate_bag(buttons_to_press, directional_shortest_paths)) {
                heads.insert(option);
            }
        }

        keep_only_shortest(heads);

        return heads;
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
            const std::string &buttons_to_press,
            const ShortestPathMap &directional_shortest_paths) {
        auto heads = get_control_candidate_sequence('A', buttons_to_press[0], directional_shortest_paths);

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

            for (const auto &x: get_control_candidate_sequence(control_sequence, directional_shortest_paths)) {
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
        for (const auto &s1: get_control_candidate_sequence(code, numerical_shortest_paths)) {
//        std::cout << s1 << std::endl;
            for (const auto &s2: get_control_candidate_sequence(s1, directional_shortest_paths)) {
//            std::cout << "\t" << s2 << std::endl;
                for (const auto &s3: get_control_candidate_sequence(s2, directional_shortest_paths)) {
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

//    size_t i = 0;
//    std::string best_i;
//    for (const auto &s1: get_control_candidate_sequence("029A", numerical_shortest_paths)) {
//        for (const auto &s2: get_control_candidate_sequence(s1, directional_shortest_paths)) {
//            for (const auto &s3: get_control_candidate_sequence(s2, directional_shortest_paths)) {
//                ++i;
//
//                if (best_i.empty() || s3.size() < best_i.size()) {
//                    best_i = s3;
//                }
//            }
//        }
//    }

//    std::cout << "directional_shortest_paths.size() " << directional_shortest_paths.size() << std::endl;


    // bag1
    auto options = get_control_candidate_bag("029A", numerical_shortest_paths);
    std::cout << options.size() << std::endl;

    // bag2
    options = get_control_candidate_bag(options, directional_shortest_paths);
    std::cout << options.size() << std::endl;

    // bag3
    options = get_control_candidate_bag(options, directional_shortest_paths);
    std::cout << options.size() << std::endl;

    // bag4
    options = get_control_candidate_bag(options, directional_shortest_paths);
    std::cout << options.size() << std::endl;
//
//    size_t j = 0;
//    CodeBag best_j;
//    for (const auto &bag1: get_control_candidate_bag("029A", numerical_shortest_paths)) {
//        for (const auto &bag2: get_control_candidate_bag(bag1, directional_shortest_paths)) {
//            for (const auto &bag3: get_control_candidate_bag(bag2, directional_shortest_paths)) {
//                for (const auto &bag4: get_control_candidate_bag(bag3, directional_shortest_paths)) {
//
//                    /*print_code_bag(bag2);
//                    std::cout << std::endl;*/
//                    ++j;
//
//                    if (best_j.empty() || num_button_presses(bag4) < num_button_presses(best_j)) {
//                        best_j = bag4;
//                    }
//                }
//
//            }
//        }
//    }

//    std::cout << i << " vs " << j << std::endl;
//    std::cout << best_i.size() << " vs " << num_button_presses(best_j) << std::endl;

    std::cout << "# button presses " << num_button_presses(options) << std::endl;



//    size_t answer = 0;
//
//    // Read each line from stdin
//    std::string code;
//    while (std::getline(std::cin, code)) {
//        std::string numeric_part_of_code_s = code.substr(0, 3);
//        size_t numeric_part_of_code = std::atoll(numeric_part_of_code_s.c_str());
//        size_t length_of_shortest_sequence = solve(code, directional_shortest_paths, numerical_shortest_paths);
//
//        std::cout << code << " => " << length_of_shortest_sequence << " * " << numeric_part_of_code << std::endl;
//        answer += length_of_shortest_sequence * numeric_part_of_code;
//    }
//    std::cout << "The answer is: " << answer << std::endl;

    return 0;
}
