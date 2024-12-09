#!/usr/bin/env io

Block := Object clone
Block id := -1
Block length := 0

// Read stdin
line := File standardInput readLine
line = line strip

// Parse line
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

// Remove empty block from end of list
popFreeSpace := method(blocks,
    N := blocks size
    block := blocks at(N - 1)
    if (block id < 0,
        blocks removeAt(N - 1)
        true,
        false
    )
)

hasFreeBlock := method(blocks,
    blocks detect(block, block id < 0) != nil
)

findFreeBlockIndex := method(blocks,
    for (i, 0, blocks size - 1,
        if (blocks at(i) id < 0,
            return i
        )
    )
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

while (hasFreeBlock(blocks),
    if (popFreeSpace(blocks),
        continue
    )

    i_free_block := findFreeBlockIndex(blocks)
    free_block := blocks at(i_free_block)

    writeln("Processing " .. i_free_block .. " of " .. blocks size .. " blocks, that's " .. i_free_block/blocks size * 100 .. "%")

    i_block_to_move := blocks size - 1
    block_to_move := blocks at(i_block_to_move)

    // Move block entirely
    if (free_block length == block_to_move length,
        free_block id = block_to_move id
        block_to_move id = -1
        blocks removeAt(i_block_to_move)
        continue
    )

    // Block too big, fill entire free space
    if (free_block length < block_to_move length,
        free_block id = block_to_move id
        block_to_move length = block_to_move length - free_block length
        # Last block remains
        continue
    )

    // Partially fill block
    blocks atInsert(i_free_block, block_to_move)
    blocks pop() // Last block is now empty
    free_block length = free_block length - block_to_move length
)

c := calculateChecksum(blocks)
writeln("The answer is: " .. c)
