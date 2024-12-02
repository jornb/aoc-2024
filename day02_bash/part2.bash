check_line() {
    is_safe=1
    is_increasing=
    prev_num=
    for num in $1; do
        # First number
        if [ -z "$prev_num" ]; then
            prev_num=$num
            continue
        fi

        # Figure out if list is increasing or decreasing
        if [ -z "$is_increasing" ]; then
            if [ "$num" -lt "$prev_num" ]; then
                is_increasing=0
            else
                is_increasing=1
            fi
        fi

        # If list is increasing, check if the numbers are safe        
        if [ $is_increasing -eq 1 ]; then
            if [ "$num" -le "$prev_num" ]; then
                # Return early if the list is not safe
                is_safe=0
                break
            fi

            if [ $((num - prev_num)) -gt 3 ]; then
                is_safe=0
                break
            fi
        else
            if [ "$num" -ge "$prev_num" ]; then
                # Return early if the list is not safe
                is_safe=0
                break
            fi

            if [ $((prev_num - num)) -gt 3 ]; then
                is_safe=0
                break
            fi
        fi

        prev_num=$num
    done

    return $is_safe
}

process_line() {
    # Try without fudging
    check_line "$1"
    if [ $? -eq 1 ]; then
        return 1
    fi

    # Fudge one number and try again, for any number in the list
    nums=($1)
    for i in "${!nums[@]}"; do
        modified_line="${nums[@]:0:$i} ${nums[@]:$((i + 1))}"
        check_line "$modified_line"
        if [ $? -eq 1 ]; then
            return 1
        fi
    done

    return 0
}

sum=0
while IFS= read -r line; do
    process_line "$line"
    if [ $? -eq 1 ]; then
        sum=$((sum + 1))
    fi    
done

echo "The number of safe records: $sum"
