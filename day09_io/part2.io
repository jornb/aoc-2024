#!/usr/bin/env io

Block := Object clone
Block id := -1
Block length := 0

// Read stdin
line := File standardInput readLine
line = line strip

blocks := list()

next_id := 0
line foreach(i, v,
    n := v asCharacter asNumber
    id := if (blocks size % 2 == 0, n, -1)

    block := Block clone
    block length = n


    if (blocks size % 2 == 0, 
        block id = next_id
        next_id = next_id + 1
    )

    blocks append(block)
)

findFreeBlockIndex := method(blocks, minSize, maxIndex,
    for (i, 0, blocks size - 1,
        b := blocks at(i)
        if (b id < 0,
            if (b length >= minSize,
                if (i < maxIndex,
                    return i
                )
            )
        )
    )
    return nil
)

printBlock := method(block,
    if (block id < 0,
        for(_, 0, block length - 1, write(".")),
        for(_, 0, block length - 1, write(block id asString))
    )
)

printBlocks := method(blocks,
    blocks foreach(block, printBlock(block))
    write("\n")
)

calculateChecksum := method(blocks,
    index := BigNum clone
    checksum := BigNum clone
    blocks foreach(block,
        for(_, 0, block length - 1,
            if (block id >= 0,
                checksum = checksum + (index * block id)
            )
            index = index + 1
        )
    )
    checksum
)

for (i, 0, blocks size - 1,
    // Get block to move
    i_block_to_move := blocks size - 1 - i
    block_to_move := blocks at(i_block_to_move)
    if (block_to_move id < 0,
        continue
    )

    writeln("Processing " .. i + 1 .. " of " .. blocks size .. " blocks, that's " .. (i + 1)/blocks size * 100 .. "%")

    // Searching from the front, find the best place for the file
    i_free_block := findFreeBlockIndex(blocks, block_to_move length, i_block_to_move)
    if (i_free_block == nil,
        continue
    )
    free_block := blocks at(i_free_block)

    // Move block entirely
    if (free_block length == block_to_move length,
        free_block id = block_to_move id
        block_to_move id = -1
        continue
    )

    // Partially fill block
    new_block := Block clone
    new_block id = block_to_move id
    new_block length = block_to_move length
    blocks atInsert(i_free_block, new_block)
    block_to_move id = -1
    free_block length = free_block length - block_to_move length
)

c := calculateChecksum(blocks)
writeln("The answer is: " .. c)
