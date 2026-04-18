import os
import re

lib_dir = "/Users/vivekverma/Documents/Flutter_Projects/invoice_generator/lib"
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r') as file:
                content = file.read()
            
            new_content = re.sub(r'BorderRadius\.circular\(', r'kRadius(', content)
            new_content = re.sub(r'shape:\s*BoxShape\.circle', r'shape: BoxShape.rectangle', new_content)
            
            if new_content != content:
                print(f"Updated {path}")
                with open(path, 'w') as file:
                    file.write(new_content)
