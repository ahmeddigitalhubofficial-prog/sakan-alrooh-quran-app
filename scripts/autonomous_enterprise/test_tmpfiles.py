import requests
import json

# Upload a video to tmpfiles.org
res = requests.post(
    "https://tmpfiles.org/api/v1/upload",
    files={"file": open("output/reel_day_3.mp4", "rb")}
)
print("tmpfiles response:", res.text)
if res.ok:
    data = res.json()
    url = data["data"]["url"]
    # Convert http://tmpfiles.org/1234/file.mp4 to http://tmpfiles.org/dl/1234/file.mp4 for direct stream
    dl_url = url.replace("tmpfiles.org/", "tmpfiles.org/dl/")
    print("Direct Stream URL:", dl_url)
    
    # Test with Buffer
    from specialists.buffer_publisher import BufferPublisher
    cfg = json.load(open("config.json", "r", encoding="utf-8"))["buffer"]
    bp = BufferPublisher(cfg["api_key"], cfg["organization_id"])
    channels = bp.get_connected_channels()
    fb = [c for c in channels if c["service"] == "facebook"][0]
    
    b_res = bp.publish_post(
        "تجربة فيديو من tmpfiles",
        channel_ids=[fb["id"]],
        media_path=dl_url,
        mode="shareNow"
    )
    print("Buffer Result:", json.dumps(b_res, indent=2, ensure_ascii=False))
