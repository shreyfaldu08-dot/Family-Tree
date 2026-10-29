import json

with open(r'C:\Users\BAPS\.gemini\antigravity-ide\brain\090b5fa4-eb0b-4e22-96fa-466f6c771f98\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        if '_buildBentoHeritageSection' in line and 'ReplacementContent' in line:
            obj = json.loads(line)
            tool_calls = obj.get('tool_calls', [])
            for tc in tool_calls:
                args = tc.get('args', {})
                rc = args.get('ReplacementContent')
                if rc and '_buildBentoHeritageSection' in rc:
                    with open('scratch/prev_bento.dart', 'w', encoding='utf-8') as out:
                        out.write(rc)
                    print("Wrote replacement chunk to scratch/prev_bento.dart! Length:", len(rc))
