import os
import re

lib_dir = "/Users/vivekverma/Documents/Flutter_Projects/invoice_generator/lib/Pages"
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r') as file:
                content = file.read()
            
            # Replace fixed width of sidebars inside Align -> Material -> Container
            # This handles width: 500 or width: 600
            new_content = re.sub(
                r'width:\s*([456]00)\s*,', 
                r'width: Responsive.isMobile(context) ? MediaQuery.sizeOf(context).width : \1,', 
                content
            )
            
            if new_content != content:
                print(f"Updated {path}")
                with open(path, 'w') as file:
                    file.write(new_content)
