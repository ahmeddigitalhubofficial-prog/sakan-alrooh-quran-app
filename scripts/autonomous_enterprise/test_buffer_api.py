import json
from specialists.buffer_publisher import BufferPublisher

cfg = json.load(open('config.json', 'r', encoding='utf-8'))['buffer']
bp = BufferPublisher(cfg['api_key'], cfg['organization_id'])
channels = bp.get_connected_channels()

for ch in channels:
    q = f'{{ channel(id: "{ch["id"]}") {{ name service allowedActions }} }}'
    res = bp._query(q)
    print(ch['service'], ":", res.get('data', {}).get('channel', {}).get('allowedActions'))
