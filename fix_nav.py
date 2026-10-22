import os
import re

FIX_SCRIPT = '<script>document.addEventListener("click",function(e){var a=e.target.closest("a");if(a&&a.href&&!/#|tel:|mailto:|_next/.test(a.href)&&a.hostname===location.hostname){e.preventDefault();e.stopPropagation();window.location.href=a.href}})</script></body>'

base = r"D:\zgj\websites\zgx"
count = 0
for root, dirs, files in os.walk(base):
    # skip .git and node_modules
    dirs[:] = [d for d in dirs if d not in ('.git', 'node_modules')]
    for f in files:
        if f.endswith('.html'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as fh:
                content = fh.read()
            if '</body>' in content and 'window.location.href' not in content:
                content = content.replace('</body>', FIX_SCRIPT)
                with open(path, 'w', encoding='utf-8') as fh:
                    fh.write(content)
                count += 1

print(f"Fixed {count} files")