for path in ['web/index.html', 'build/web/index.html']:
    with open(path, 'r', encoding='utf-8') as f:
        s = f.read()
    if 'name="viewport"' not in s:
        s = s.replace('<meta charset="UTF-8">', '<meta charset="UTF-8">\n  <meta name="viewport" content="width=device-width, initial-scale=1.0">')
        with open(path, 'w', encoding='utf-8') as f:
            f.write(s)
        print('Updated:', path)
    else:
        print('Already had viewport:', path)

