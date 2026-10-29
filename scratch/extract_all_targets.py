import json

steps = [4592, 4600, 4604]
with open(r'C:\Users\BAPS\.gemini\antigravity-ide\brain\090b5fa4-eb0b-4e22-96fa-466f6c771f98\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        for s in steps:
            if f'"step_index":{s}' in line:
                obj = json.loads(line)
                tc_list = obj.get('tool_calls', [])
                for tc in tc_list:
                    args = tc.get('args', {})
                    tc_content = args.get('TargetContent')
                    if tc_content:
                        with open(f'scratch/original_step_{s}.dart', 'w', encoding='utf-8') as out:
                            out.write(tc_content)
                        print(f"Wrote TargetContent for step {s}! Length: {len(tc_content)}")
