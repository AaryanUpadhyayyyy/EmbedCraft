import re
import sys

file_path = r'c:\Users\AARYAN UPADHYAY\Downloads\EmbedCraft\test_app\lib\main.dart'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except Exception as e:
    print("Error reading:", e)
    sys.exit(1)

def replace_embed_wrapper(text):
    result = []
    i = 0
    while i < len(text):
        match = re.search(r'EmbedWidgetWrapper\s*\(', text[i:])
        if not match:
            result.append(text[i:])
            break
        
        start_idx = i + match.start()
        result.append(text[i:start_idx])
        
        parens = 0
        in_string = False
        string_char = ''
        j = start_idx + match.end() - 1 
        
        inner_start = j + 1
        inner_end = -1
        
        for k in range(j, len(text)):
            c = text[k]
            if c == '\\\\':
                k += 1
                continue
            if c in ["'", '"']:
                if not in_string:
                    in_string = True
                    string_char = c
                elif string_char == c:
                    in_string = False
            
            if not in_string:
                if c == '(':
                    parens += 1
                elif c == ')':
                    parens -= 1
                    if parens == 0:
                        inner_end = k
                        break
        
        if inner_end != -1:
            inner_content = text[inner_start:inner_end]
            
            # Using regex to find id: and child: regardless of comments
            # We just want the quoted string for ID
            id_match = re.search(r"id\s*:\s*('[^']+'|\"[^\"]+\"|[^,]+)", inner_content)
            child_match = re.search(r"\bchild\s*:", inner_content)
            
            if id_match and child_match:
                # get just the first quoted string on the line if there are comments
                id_val_raw = id_match.group(1).strip()
                id_val_clean = re.search(r"('[^']+'|\"[^\"]+\"|[^,]+)", id_val_raw).group(1)
                
                # sometimes child comes first, handle both
                if id_match.start() < child_match.start():
                    child_str = inner_content[child_match.end():]
                else:
                    # if child is before id, this regex is too simple. We'd have to parse better.
                    # In main.dart, id is always first.
                    child_str = inner_content[child_match.end():id_match.start()]
                    child_str = child_str.strip().rstrip(',')
                
                replacement = f"{child_str.strip()}.appNinjaIdentifier({id_val_clean})"
                result.append(replacement)
                i = inner_end + 1
            else:
                result.append(text[start_idx:inner_end+1])
                i = inner_end + 1
        else:
            result.append(text[start_idx:])
            break

    return ''.join(result)

# Run it multiple times in case of nested EmbedWidgetWrappers
new_content = content
for _ in range(5):
    new_content = replace_embed_wrapper(new_content)

try:
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Updated main.dart successfully.")
except Exception as e:
    print("Error writing:", e)
    sys.exit(1)
