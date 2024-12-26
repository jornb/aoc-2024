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

$triplets = [];

foreach (array_keys($nodes) as $i) {
    foreach (array_keys($nodes) as $j) {
        if ($j <= $i) {
            continue;
        }

        foreach (array_keys($nodes) as $k) {
            if ($k <= $j) {
                continue;
            }

            $ni = $nodes[$i];
            $nj = $nodes[$j];
            $nk = $nodes[$k];
            if (strpos($ni, 't') !== 0 && strpos($nj, 't') !== 0 && strpos($nk, 't') !== 0) {
                continue;
            }
            
            if (isset($links[$ni]) && isset($links[$nj]) && in_array($nj, $links[$ni]) && in_array($nk, $links[$ni]) && in_array($nk, $links[$nj])) {
                $triplets[] = [$ni, $nj, $nk];
            }
        }
    }
}

echo  "The answer is: " . count($triplets) . PHP_EOL;
?>