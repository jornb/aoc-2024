process_line() {
    echo "Processing report: $1"

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
                echo "The list is decreasing"
                is_increasing=0
            else
                echo "The list is increasing"
                is_increasing=1
            fi
        fi

        # If list is increasing, check if the numbers are safe        
        if [ $is_increasing -eq 1 ]; then
            if [ "$num" -le "$prev_num" ]; then
                echo "The list is not safe, $num < $prev_num"
                # Return early if the list is not safe
                is_safe=0
                break
            fi

            if [ $((num - prev_num)) -gt 3 ]; then
                echo "The difference between $prev_num and $num is greater than 3"
                is_safe=0
                break
            fi
        else
            if [ "$num" -ge "$prev_num" ]; then
                echo "The list is not safe, $num > $prev_num"
                # Return early if the list is not safe
                is_safe=0
                break
            fi

            if [ $((prev_num - num)) -gt 3 ]; then
                echo "The difference between $prev_num and $num is greater than 3"
                is_safe=0
                break
            fi
        fi

        prev_num=$num
    done

    if [ $is_safe -eq 1 ]; then
        echo "The list is safe"
    else
        echo "The list is not safe"
    fi

    return $is_safe
}

sum=0

while IFS= read -r line; do
    process_line "$line"
    if [ $? -eq 1 ]; then
        sum=$((sum + 1))
    fi    
    echo ""
done

echo "The number of safe records: $sum"
