import os

directory = 'library/ix-dev/community/gitlab'

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith(('.yaml', '.yml', '.tpl', '.json', '.md')):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Replace cases
            new_content = content.replace('gitea', 'gitlab').replace('Gitea', 'GitLab').replace('GITEA', 'GITLAB')
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
