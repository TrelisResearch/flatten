#!/bin/bash

# Function to check if a file/folder should be ignored
should_ignore() {
    local item=$1
    local relative_path=${item#./}  # Remove leading ./ if present
    
    # Check if the file is fr.sh itself
    if [ "$(basename "$item")" = "fr.sh" ]; then
        return 0
    fi
    
    # Function to check if a path matches an ignore pattern
    matches_ignore_pattern() {
        local pattern=$1
        local path=$2
        
        # Remove trailing slash from pattern and path
        pattern=${pattern%/}
        path=${path%/}
        
        # If pattern starts with /, anchor it to the base directory
        if [[ $pattern == /* ]]; then
            pattern=${pattern#/}
            if [[ $path == $pattern || $path == $pattern/* ]]; then
                return 0
            fi
        else
            # For relative patterns, match any part of the path
            if [[ $path == */$pattern || $path == $pattern || $path == $pattern/* ]]; then
                return 0
            fi
        fi
        
        return 1
    }
    
    # Check .gitignore
    if [ -f ".gitignore" ]; then
        while IFS= read -r pattern || [[ -n "$pattern" ]]; do
            pattern=$(echo "$pattern" | sed 's/#.*//' | xargs)  # Remove comments and trim
            if [ -n "$pattern" ] && matches_ignore_pattern "$pattern" "$relative_path"; then
                return 0
            fi
        done < .gitignore
    fi
    
    # Check .flattenignore
    if [ -f ".flattenignore" ]; then
        while IFS= read -r pattern || [[ -n "$pattern" ]]; do
            pattern=$(echo "$pattern" | sed 's/#.*//' | xargs)  # Remove comments and trim
            if [ -n "$pattern" ] && matches_ignore_pattern "$pattern" "$relative_path"; then
                return 0
            fi
        done < .flattenignore
    fi
    
    return 1
}

# Function to generate YAML representation of the file structure
generate_yaml() {
    local folder=$1
    local indent=$2
    local parent_path=$3
    find "$folder" -mindepth 1 -maxdepth 1 ! -path '*/\.*' | while read -r item; do
        local base_item=$(basename "$item")
        local relative_path="$parent_path/$base_item"
        if should_ignore "$item"; then
            continue
        fi
        if [ -d "$item" ]; then
            echo "${indent}- path: $relative_path" >> "$output_file"
            echo "${indent}  type: directory" >> "$output_file"
            echo "${indent}  contents:" >> "$output_file"
            generate_yaml "$item" "  $indent" "$relative_path"
        else
            echo "${indent}- path: $relative_path" >> "$output_file"
            echo "${indent}  type: file" >> "$output_file"
        fi
    done
}

# Function to print file contents
print_file_contents() {
    local file_path=$1
    # Remove leading space if present
    file_path="${file_path#"${file_path%%[![:space:]]*}"}"
    # Remove leading slash
    file_path="${file_path#/}"
    if [ -d "$file_path" ]; then
        echo "Skipping directory: $file_path"
        return
    fi
    if [ ! -f "$file_path" ]; then
        echo "File does not exist: $file_path"
        return
    fi
    if [ "$(basename "$file_path")" = "fr.sh" ]; then
        echo "Skipping fr.sh script"
        return
    fi
    if [[ "$file_path" =~ \.(py|js|ts|jsx|tsx|vue|rb|php|java|go|rs|c|cpp|h|hpp|cs|swift|kt|scala|html|css|scss|less|md|txt|sh|bash|zsh|json|yaml|yml|xml|sql|graphql|r|m|f|f90|jl|lua|pl|pm|t|ps1|bat|asm|s|nim|ex|exs|clj|lisp|hs|erl|elm)$ ]]; then
        echo "<$file_path>" >> "$flattened_file"
        if cat "$file_path" >> "$flattened_file"; then
            echo "Successfully wrote contents of $file_path"
        else
            echo "Failed to write contents of $file_path"
        fi
        echo "" >> "$flattened_file"
        echo "</$file_path>" >> "$flattened_file"
        echo "" >> "$flattened_file"
    else
        echo "Skipping non-text file: $file_path"
    fi
}

# Ensure we are in the correct directory
cd "$(dirname "$0")"

# Set file names
output_file="repo_structure.yaml"
flattened_file="flattened_repo.txt"

# Delete existing files if they exist
rm -f "$output_file" "$flattened_file"

# Generate YAML structure
generate_yaml . "  " ""
echo "YAML file with folder/file structure has been created as $output_file."

# Check if --ffc flag is provided
if [[ "$1" == "--ffc" ]]; then
    echo "Flattening repository..."
    > "$flattened_file"
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*path:[[:space:]]*(.*) ]]; then
            file_path="${BASH_REMATCH[1]}"
            if [[ ! "$line" =~ type:[[:space:]]*directory ]]; then
                print_file_contents "$file_path"
            else
                echo "Skipping directory: $file_path"
            fi
        fi
    done < "$output_file"
    echo "Flattened repository content has been created as $flattened_file."
else
    echo "Repository structure created. Use --ffc flag to also flatten the file contents to $flattened_file."
fi
