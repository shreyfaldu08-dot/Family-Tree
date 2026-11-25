import json

path = r"C:\Users\BAPS\.gemini\antigravity\brain\0f85ee77-9b07-4def-8188-f53272f7ca46\.system_generated\logs\transcript.jsonl"
with open(path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if 2195 <= i <= 2210:
            obj = json.loads(line)
            source = obj.get("source")
            typ = obj.get("type")
            content = obj.get("content", "")
            print(f"--- Step {i} ({source} / {typ}) ---")
            print(content[:500])
