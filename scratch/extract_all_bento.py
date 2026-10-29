import json

matches = []
with open(r'C:\Users\BAPS\.gemini\antigravity-ide\brain\090b5fa4-eb0b-4e22-96fa-466f6c771f98\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line_idx, line in enumerate(f):
        if '_buildBentoHeritageSection' in line and 'ReplacementContent' in line:
            obj = json.loads(line)
            tool_calls = obj.get('tool_calls', [])
            for tc in tool_calls:
                args = tc.get('args', {})
                rc = args.get('ReplacementContent')
                desc = args.get('Description', '')
                if rc and '_buildBentoHeritageSection' in rc:
                    matches.append((obj.get('step_index'), desc, len(rc), rc))

print(f"Total matching tool calls: {len(matches)}")
for idx, (step, desc, length, rc) in enumerate(matches):
    print(f"Index {idx}: step {step}, length {length}, desc: {desc}")
    with open(f"scratch/bento_version_{idx}.dart", "w", encoding="utf-8") as out:
        out.write(rc)
