import json
from datetime import datetime, timedelta, timezone
from specialists.buffer_publisher import BufferPublisher

cfg = json.load(open('config.json', 'r', encoding='utf-8'))['buffer']
bp = BufferPublisher(cfg['api_key'], cfg['organization_id'])
channels = bp.get_connected_channels()

cloudinary_video_url = 'https://res.cloudinary.com/bmp3hs5g/video/upload/v1792355916/test_reel_day_3.mp4'

due_at = (datetime.now(timezone.utc) + timedelta(days=1)).replace(hour=17, minute=30, second=0).strftime('%Y-%m-%dT%H:%M:%SZ')
print('Scheduling for:', due_at)

mutation = """
mutation CreatePost($input: CreatePostInput!) {
  createPost(input: $input) {
    ... on PostActionSuccess {
      post {
        id
        status
      }
    }
    ... on InvalidInputError {
      message
    }
    ... on LimitReachedError {
      message
    }
    ... on UnexpectedError {
      message
    }
  }
}
"""

for ch in channels:
    input_data = {
        'channelId': ch['id'],
        'text': 'سكن الروح 🌙 - إن مع العسر يسراً | تلاوة خاشعة للشيخ مشاري العفاسي',
        'mode': 'customScheduled',
        'dueAt': due_at,
        'schedulingType': 'automatic',
        'needsApproval': False,
        'assets': [{'video': {'url': cloudinary_video_url}}]
    }
    if ch['service'] == 'facebook':
        input_data['metadata'] = {'facebook': {'type': 'reel'}}
    elif ch['service'] == 'instagram':
        input_data['metadata'] = {'instagram': {'type': 'reel', 'shouldShareToFeed': True}}
    elif ch['service'] == 'tiktok':
        input_data['metadata'] = {'tiktok': {'isAiGenerated': False}}
    
    res = bp._query(mutation, {'input': input_data})
    print(ch['service'], ':', json.dumps(res, ensure_ascii=False))
