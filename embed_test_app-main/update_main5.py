import re

file_path = r'c:\Users\AARYAN UPADHYAY\Downloads\EmbedCraft\test_app\lib\main.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

def process(text):
    out = []
    i = 0
    replacements = 0
    while i < len(text):
        match = re.search(r'EmbedWidgetWrapper\s*\(', text[i:])
        if not match:
            out.append(text[i:])
            break
            
        start_idx = i + match.start()
        out.append(text[i:start_idx])
        
        parens = 1
        in_string = False
        string_char = ''
        j = i + match.end() # Points to the character right after '('
        
        inner_start = j
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
            
            id_match = re.search(r"id\s*:\s*('[^']+'|\"[^\"]+\"|[^,]+)", inner_content)
            child_match = re.search(r"\bchild\s*:", inner_content)
            
            if id_match and child_match:
                id_raw = id_match.group(1).strip()
                id_val_clean_match = re.search(r"('[^']+'|\"[^\"]+\"|[^,]+)", id_raw)
                id_val = id_val_clean_match.group(1) if id_val_clean_match else id_raw
                
                child_start = child_match.end()
                child_content = inner_content[child_start:].strip()
                if child_content.endswith(','):
                    child_content = child_content[:-1].strip()
                    
                replacement = f"{child_content}.appNinjaIdentifier({id_val})"
                out.append(replacement)
                replacements += 1
                i = inner_end + 1
            else:
                out.append(text[start_idx:inner_end+1])
                i = inner_end + 1
        else:
            out.append(text[start_idx:])
            break
            
    return ''.join(out), replacements

new_content, count = process(content)

total_count = count
while count > 0:
    new_content, count = process(new_content)
    total_count += count

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print(f"Updated main.dart successfully! Replaced {total_count} occurrences.")
