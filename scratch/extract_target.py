import json

with open(r'C:\Users\BAPS\.gemini\antigravity-ide\brain\090b5fa4-eb0b-4e22-96fa-466f6c771f98\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        if 'Replace AI-trope dark gradient overlays' in line:
            obj = json.loads(line)
            tool_calls = obj.get('tool_calls', [])
            for tc in tool_calls:
                args = tc.get('args', {})
                tc_content = args.get('TargetContent')
                if tc_content:
                    with open('scratch/original_bento_target.dart', 'w', encoding='utf-8') as out:
                        out.write(tc_content)
                    print("Found TargetContent! Length:", len(tc_content))
