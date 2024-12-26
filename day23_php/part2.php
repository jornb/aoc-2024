<?php
$file = fopen('php://stdin', 'r');

$nodes = [];


while($line = fgets($file)) {
    $line = trim($line);
    $names = explode('-', $line);
    if ($names[0] > $names[1]) {
        $tmp = $names[0];
        $names[0] = $names[1];
        $names[1] = $tmp;
    }

    // Add to links
    if (!isset($links[$names[0]])) {
        $links[$names[0]] = [];
    }
    $links[$names[0]][] = $names[1];

    // Add to nodes
    if (!in_array($names[0], $nodes)) {
        $nodes[] = $names[0];
    }
    if (!in_array($names[1], $nodes)) {
        $nodes[] = $names[1];
    }
}

fclose($file);

$nodes = array_unique($nodes);
sort($nodes);

$max_clique = [];

function has_link($a, $b) {
    global $links;
    if ($a > $b) {
        $tmp = $a;
        $a = $b;
        $b = $tmp;
    }
    return isset($links[$a]) && in_array($b, $links[$a]);
}

function is_in_clique($c, $n) {
    foreach ($c as $node) {
        if (!has_link($node, $n)) {
            return false;
        }
    }
    return true;
}

function clique($current_clique, $remaining_nodes, $verbose = false) {
    global $max_clique;
    global $nodes;
    global $links;

    if (count($current_clique) > count($max_clique)) {
        $max_clique = $current_clique;
    }

    if (count($current_clique) + count($remaining_nodes) <= count($max_clique)) {
        return;
    }

    foreach (array_keys($remaining_nodes) as $i) {
        if ($verbose) {
            echo "Processing " . $i . " of " . count($remaining_nodes) . ", that's " . 100.0*$i/count($remaining_nodes) . " %\n";
        }
        if (is_in_clique($current_clique, $remaining_nodes[$i])) {
            $new_clique = array_slice($current_clique, 0);
            $new_clique[] = $remaining_nodes[$i];
            $new_remaining_nodes = array_slice($remaining_nodes, 0, $i) + array_slice($remaining_nodes, $i + 1);
            clique($new_clique, $new_remaining_nodes);
        }
    }
}

clique([], $nodes, true);

sort($max_clique);

echo "The answer is: " . implode(',', $max_clique) . PHP_EOL;
?>