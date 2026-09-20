#!/bin/bash
# Cleanup script: remove // comments, /// comments, print statements from all .dart files

LIB_DIR="/home/ahmad/Public/Flutter Project/Job/nextstep_ai_app/lib"

find "$LIB_DIR" -name "*.dart" -type f | while IFS= read -r file; do
  echo "Processing: $file"
  
  # Create temp file
  tmpfile=$(mktemp)
  
  # Process the file:
  # 1. Remove lines that are ONLY a comment (with optional leading whitespace)
  # 2. Remove inline // comments (but NOT inside strings - simplified approach)
  # 3. Remove lines containing print( statements
  # 4. Remove lines containing debugPrint( statements
  # 5. Remove empty lines that result from removals (collapse multiple blank lines)
  
  python3 -c "
import re
import sys

with open(sys.argv[1], 'r') as f:
    lines = f.readlines()

result = []
in_multiline_print = False
paren_depth = 0

for line in lines:
    stripped = line.strip()
    
    # Skip lines that are purely comments (// or ///)
    if stripped.startswith('//') or stripped.startswith('///'):
        continue
    
    # Remove inline comments (after code), but be careful with URLs (://)
    # Only remove // that is not inside a string and not a URL
    # Simple approach: remove // comments that come after code
    # but keep http:// and similar
    new_line = line
    in_string_single = False
    in_string_double = False
    i = 0
    while i < len(new_line):
        c = new_line[i]
        if c == \"'\" and not in_string_double:
            in_string_single = not in_string_single
        elif c == '\"' and not in_string_single:
            in_string_double = not in_string_double
        elif c == '/' and i + 1 < len(new_line) and new_line[i+1] == '/' and not in_string_single and not in_string_double:
            # Check it's not :// (URL)
            if i > 0 and new_line[i-1] == ':':
                i += 1
                continue
            new_line = new_line[:i].rstrip() + '\n'
            break
        i += 1
    
    line = new_line
    stripped = line.strip()
    
    # Skip empty lines after stripping
    if stripped == '':
        result.append('\n')
        continue
    
    # Handle print statements (single line)
    if re.match(r'^\s*print\s*\(', stripped) or re.match(r'^\s*debugPrint\s*\(', stripped):
        # Count parens to handle multi-line prints
        open_p = stripped.count('(')
        close_p = stripped.count(')')
        if open_p <= close_p:
            continue  # Single line print, skip it
        else:
            in_multiline_print = True
            paren_depth = open_p - close_p
            continue
    
    if in_multiline_print:
        open_p = stripped.count('(')
        close_p = stripped.count(')')
        paren_depth += open_p - close_p
        if paren_depth <= 0:
            in_multiline_print = False
        continue
    
    result.append(line)

# Collapse multiple consecutive blank lines into one
final = []
prev_blank = False
for line in result:
    if line.strip() == '':
        if not prev_blank:
            final.append(line)
        prev_blank = True
    else:
        prev_blank = False
        final.append(line)

# Remove trailing blank lines
while final and final[-1].strip() == '':
    final.pop()

with open(sys.argv[1], 'w') as f:
    f.writelines(final)
    f.write('\n')
" "$file"

done

echo "Done! All comments and print statements removed."
