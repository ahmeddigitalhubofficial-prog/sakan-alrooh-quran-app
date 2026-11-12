# -*- coding: utf-8 -*-
"""
محرك النشر الآلي الموحد عبر Buffer (Buffer Multi-Platform Publishing Engine)
يتيح نشر الحملات التسويقية والبوسترات دفعة واحدة على فيسبوك، إنستغرام، إكس، ولينكد إن وتيك توك
باستخدام Buffer GraphQL API.
"""

import json
import urllib.request
import os
import time

class BufferPublisher:
    def __init__(self, api_key, organization_id):
        self.api_key = api_key
        self.organization_id = organization_id
        self.endpoint = "https://api.buffer.com/graphql"
        self.headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

    def _query(self, query_str, variables=None):
        payload = {"query": query_str}
        if variables:
            payload["variables"] = variables
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(self.endpoint, data=data, headers=self.headers)
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except Exception as e:
            return {"errors": [{"message": str(e)}]}

    def get_connected_channels(self):
        """استرجاع كافة قنوات وحسابات السوشيال ميديا المربوطة بحساب Buffer"""
        query = """
        query GetChannels($orgId: OrganizationId!) {
          channels(input: { organizationId: $orgId }) {
            id
            name
            service
          }
        }
        """
        res = self._query(query, {"orgId": self.organization_id})
        if res and "data" in res and res["data"] and "channels" in res["data"]:
            return res["data"]["channels"]
        return []

    def upload_media(self, file_path):
        """رفع ملف الميديا (صورة أو فيديو) والحصول على رابط عام مباشر لـ Buffer عبر Cloudinary"""
        if not file_path or not os.path.exists(file_path):
            return None
        
        # 1. استخدام Cloudinary (الخدمة السحابية المعتمدة رسمياً من Buffer)
        try:
            cfg_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "config.json")
            if os.path.exists(cfg_path):
                with open(cfg_path, "r", encoding="utf-8") as f:
                    cdata = json.load(f)
                    c_cfg = cdata.get("cloudinary")
                    if c_cfg and c_cfg.get("cloud_name") and c_cfg.get("api_secret"):
                        import cloudinary
                        import cloudinary.uploader
                        cloudinary.config(
                            cloud_name=c_cfg["cloud_name"],
                            api_key=c_cfg["api_key"],
                            api_secret=c_cfg["api_secret"],
                            secure=True
                        )
                        is_vid = file_path.lower().endswith(".mp4")
                        res_type = "video" if is_vid else "image"
                        pub_id = f"sakan_{int(time.time())}_{os.path.basename(file_path).split('.')[0]}"
                        up_res = cloudinary.uploader.upload(file_path, resource_type=res_type, public_id=pub_id)
                        sec_url = up_res.get("secure_url")
                        if sec_url:
                            print(f"Cloudinary upload success: {sec_url}")
                            return sec_url
        except Exception as e:
            print("Cloudinary upload failed, falling back:", e)

        # 2. خطة بديلة: Catbox
        import mimetypes
        url = "https://catbox.moe/user/api.php"
        boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        filename = os.path.basename(file_path)
        mime_type = mimetypes.guess_type(file_path)[0] or "application/octet-stream"

        try:
            with open(file_path, "rb") as f:
                file_bytes = f.read()

            body = (
                f"--{boundary}\r\n"
                f'Content-Disposition: form-data; name="reqtype"\r\n\r\n'
                f"fileupload\r\n"
                f"--{boundary}\r\n"
                f'Content-Disposition: form-data; name="fileToUpload"; filename="{filename}"\r\n'
                f"Content-Type: {mime_type}\r\n\r\n"
            ).encode("utf-8") + file_bytes + f"\r\n--{boundary}--\r\n".encode("utf-8")

            req = urllib.request.Request(
                url,
                data=body,
                headers={
                    "Content-Type": f"multipart/form-data; boundary={boundary}",
                    "User-Agent": "Mozilla/5.0"
                }
            )
            with urllib.request.urlopen(req, timeout=30) as resp:
                res_url = resp.read().decode("utf-8").strip()
                if res_url.startswith("http"):
                    return res_url
        except Exception as e:
            print("Media upload error:", e)
        return None

    def publish_post(self, text, channel_ids=None, media_path=None, due_at=None, mode="shareNow", first_comment=None):
        """نشر منشور بصري فوري أو مجدول (صورة أو فيديو) على القنوات المربوطة مع تعليق أول تلقائي"""
        channels = self.get_connected_channels()
        if not channels:
            return {
                "success": False,
                "message": "لم يتم العثور على أي قنوات مربوطة في Buffer حتى الآن. يرجى ربط صفحة فيسبوك أو إنستغرام عبر publish.buffer.com أولاً."
            }

        # Resolve media URL
        media_url = None
        if media_path:
            if media_path.startswith("http"):
                media_url = media_path
            else:
                media_url = self.upload_media(media_path)

        target_channel_ids = channel_ids or [c["id"] for c in channels]
        results = []

        # تجهيز نص التعليق الأول التلقائي بالروابط الحية في حال لم يُحدد
        if first_comment is None:
            first_comment = (
                "📲 روابط التحميل المباشرة والمجانية لتطبيق «سكن الروح» (لوجه الله تعالى بدون أي إعلانات):\n\n"
                "🔗 الرابط الشامل لجميع الأجهزة (في بايو الصفحة ☝️):\n"
                "https://linktr.ee/sakan.alrooh.app\n\n"
                "🟢 متجر Google Play (أندرويد):\n"
                "https://play.google.com/store/apps/details?id=com.nooralhoda.official.app\n\n"
                "🔴 متجر AppGallery (هواوي):\n"
                "https://appgallery.huawei.com/app/C118816285\n\n"
                "🔍 أو ابحث في متجر هاتفك عن: «سكن الروح»\n\n"
                "🌿 نسألكم الدعاء لوالدينا ولكل من ساهم في نشر الخير 🤍"
            )

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
            ... on UnauthorizedError {
              message
            }
            ... on NotFoundError {
              message
            }
            ... on UnexpectedError {
              message
            }
          }
        }
        """

        is_video = media_url and (".mp4" in media_url or "/video/" in media_url)

        for ch_id in target_channel_ids:
            ch_info = next((c for c in channels if c["id"] == ch_id), {"name": ch_id, "service": "unknown"})
            svc = ch_info.get("service", "").lower()

            # TikTok and Instagram require media assets
            if svc in ["tiktok", "instagram"] and not media_url:
                results.append({
                    "channel": ch_info["name"],
                    "service": ch_info["service"],
                    "status": "skipped",
                    "error": f"منصة {ch_info['service'].capitalize()} تتطلب ملف ميديا (فيديو أو صورة) للنشر ولا تقبل المنشورات النصية المجردة."
                })
                continue

            input_data = {
                "channelId": ch_id,
                "text": text,
                "mode": "customScheduled" if due_at else mode,
                "schedulingType": "automatic",
                "needsApproval": False
            }
            if due_at:
                input_data["dueAt"] = due_at

            # Service-specific metadata
            if svc == "facebook":
                fb_meta = {"type": "reel" if is_video else "post"}
                if first_comment:
                    fb_meta["firstComment"] = first_comment
                input_data["metadata"] = {"facebook": fb_meta}
            elif svc == "instagram":
                ig_meta = {"type": "reel" if is_video else "post", "shouldShareToFeed": True}
                if first_comment:
                    ig_meta["firstComment"] = first_comment
                input_data["metadata"] = {"instagram": ig_meta}
            elif svc == "tiktok":
                input_data["metadata"] = {"tiktok": {"isAiGenerated": False}}
            elif svc == "youtube":
                if not is_video:
                    results.append({
                        "channel": ch_info["name"],
                        "service": ch_info["service"],
                        "status": "skipped",
                        "error": "منصة YouTube تقبل مقاطع الفيديو (Shorts) فقط ولا تقبل الصور أو المنشورات النصية المجردة."
                    })
                    continue

                # YouTube requires a title in metadata (max 100 chars)
                raw_title = text.split("\n")[0].strip() if text else "سكن الروح 🌙"
                yt_title = raw_title[:85]
                if not any(h in yt_title.lower() for h in ["#shorts", "#short"]):
                    yt_title += " #Shorts"

                input_data["metadata"] = {
                    "youtube": {
                        "title": yt_title,
                        "madeForKids": False,
                        "notifySubscribers": True
                    }
                }

            # Attach media if available
            if media_url:
                if is_video:
                    input_data["assets"] = [{"video": {"url": media_url}}]
                else:
                    input_data["assets"] = [{"image": {"url": media_url}}]

            res = self._query(mutation, {"input": input_data})
            cp = res.get("data", {}).get("createPost", {})
            err = cp.get("message") or (res.get("errors", [{}])[0].get("message", "") if res.get("errors") else "")

            # في حال كانت باقة Buffer مجانية وترفض التعليق الأول، نقوم بإعادة النشر فوراً بدون firstComment
            if not (cp and "post" in cp and cp.get("post")) and "First comment requires a paid plan" in err:
                if svc == "facebook" and "facebook" in input_data.get("metadata", {}):
                    input_data["metadata"]["facebook"].pop("firstComment", None)
                elif svc == "instagram" and "instagram" in input_data.get("metadata", {}):
                    input_data["metadata"]["instagram"].pop("firstComment", None)
                res = self._query(mutation, {"input": input_data})
                cp = res.get("data", {}).get("createPost", {})
                err = cp.get("message") or (res.get("errors", [{}])[0].get("message", "فشل غير معروف") if res.get("errors") else "")

            if cp and "post" in cp and cp.get("post"):
                results.append({
                    "channel": ch_info["name"],
                    "service": ch_info["service"],
                    "status": "success",
                    "post_id": cp["post"]["id"]
                })
            else:
                results.append({
                    "channel": ch_info["name"],
                    "service": ch_info["service"],
                    "status": "failed",
                    "error": err
                })

        return {
            "success": any(r["status"] == "success" for r in results),
            "results": results
        }

    def get_scheduled_posts(self):
        """استرجاع كافة المنشورات المجدولة حالياً في طابور Buffer عبر جميع الصفحات والقنوات"""
        query = """
        query GetScheduledPosts($orgId: OrganizationId!, $after: String) {
          posts(input: { organizationId: $orgId, filter: { status: [scheduled] } }, first: 100, after: $after) {
            pageInfo {
              hasNextPage
              endCursor
            }
            edges {
              node {
                id
                status
                channelId
                dueAt
                text
              }
            }
          }
        }
        """
        channels = self.get_connected_channels()
        ch_map = {c["id"]: c for c in channels}

        posts = []
        after_cursor = None
        has_next = True

        while has_next:
            variables = {"orgId": self.organization_id}
            if after_cursor:
                variables["after"] = after_cursor
            res = self._query(query, variables)
            posts_data = res.get("data", {}).get("posts", {})
            edges = posts_data.get("edges", [])
            for e in edges:
                node = e.get("node", {})
                if node.get("status") == "scheduled":
                    ch_id = node.get("channelId")
                    ch_info = ch_map.get(ch_id, {"name": ch_id, "service": "unknown"})
                    posts.append({
                        "id": node.get("id"),
                        "status": node.get("status"),
                        "channelId": ch_id,
                        "channel_name": ch_info.get("name"),
                        "service": ch_info.get("service"),
                        "dueAt": node.get("dueAt"),
                        "text": node.get("text", "")
                    })
            page_info = posts_data.get("pageInfo", {})
            has_next = page_info.get("hasNextPage", False)
            after_cursor = page_info.get("endCursor")

        return posts

    def get_occupied_dates(self):
        """استخراج مجموعة التواريخ (YYYY-MM-DD) المحجوزة بالفعل بمنشور مجدول (بتوقيت القاهرة/مكة UTC+3)"""
        from datetime import datetime, timezone, timedelta
        posts = self.get_scheduled_posts()
        occupied = set()
        for p in posts:
            due_at = p.get("dueAt")
            if due_at:
                try:
                    dt = datetime.fromisoformat(due_at.replace("Z", "+00:00"))
                    local_dt = dt.astimezone(timezone(timedelta(hours=3)))
                    occupied.add(local_dt.strftime("%Y-%m-%d"))
                except Exception:
                    pass
        return occupied

    def get_next_available_slots(self, count=1, start_from_days_ahead=0):
        """
        البحث الذكي عن الأيام الخالية تماماً من أي جدولة سابقة:
        يقوم بفحص التواريخ يوماً بيوم، وتخطي أي يوم يحتوي على فيديو مجدول بالفعل،
        وحجز موعد الساعة الذهبية (8:30 م = 17:30 UTC) في أول يوم فارغ.
        """
        from datetime import datetime, timezone, timedelta
        occupied = self.get_occupied_dates()
        slots = []

        now = datetime.now(timezone.utc)
        today_golden = datetime(now.year, now.month, now.day, 17, 30, 0, tzinfo=timezone.utc)
        
        base_offset = 1 if now >= today_golden else 0
        current_offset = base_offset + start_from_days_ahead

        while len(slots) < count:
            candidate_dt = today_golden + timedelta(days=current_offset)
            local_candidate = candidate_dt.astimezone(timezone(timedelta(hours=3)))
            date_str = local_candidate.strftime("%Y-%m-%d")

            if date_str not in occupied:
                slots.append({
                    "due_at": candidate_dt.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "date_str": date_str,
                    "date_display": local_candidate.strftime("%a %d-%m-%Y")
                })
                occupied.add(date_str)
            current_offset += 1

        return slots

    def delete_post(self, post_id):
        """حذف منشور محدد من Buffer باستخدام المعرف post_id"""
        mutation = """
        mutation DeletePost($input: DeletePostInput!) {
          deletePost(input: $input) {
            ... on DeletePostSuccess {
              id
            }
            ... on VoidMutationError {
              message
            }
          }
        }
        """
        res = self._query(mutation, {"input": {"id": post_id}})
        dp = res.get("data", {}).get("deletePost", {})
        if dp and "id" in dp:
            return {"success": True, "id": dp["id"]}
        err = dp.get("message") or res.get("errors", [{}])[0].get("message", "فشل الحذف")
        return {"success": False, "error": err}

    def clear_all_scheduled(self):
        """مسح وإلغاء جميع المنشورات المجدولة في Buffer للبدء من جديد بلا تداخل"""
        posts = self.get_scheduled_posts()
        deleted_count = 0
        for p in posts:
            res = self.delete_post(p["id"])
            if res.get("success"):
                deleted_count += 1
        return {"total_found": len(posts), "deleted_count": deleted_count}

    def clean_duplicate_slots(self):
        """
        تنظيف التداخل:
        إذا وجد أكثر من فيديو مختلف في نفس اليوم، يتم الإبقاء على فيديو واحد فقط
        وحذف المنشورات المتضاربة الزائدة في ذلك اليوم.
        """
        from datetime import datetime, timezone, timedelta
        posts = self.get_scheduled_posts()
        dates_map = {}
        for p in posts:
            due_at = p.get("dueAt")
            if due_at:
                try:
                    dt = datetime.fromisoformat(due_at.replace("Z", "+00:00"))
                    local_dt = dt.astimezone(timezone(timedelta(hours=3)))
                    d_str = local_dt.strftime("%Y-%m-%d")
                    dates_map.setdefault(d_str, []).append(p)
                except Exception:
                    pass

        removed_count = 0
        details = []
        for d_str, day_posts in sorted(dates_map.items()):
            reels_in_day = {}
            for p in day_posts:
                first_line = p.get("text", "").split("\n")[0].strip()
                reels_in_day.setdefault(first_line, []).append(p)

            if len(reels_in_day) > 1:
                reels_keys = list(reels_in_day.keys())
                keep_reel = reels_keys[0]
                day_removed = 0
                for extra_reel in reels_keys[1:]:
                    for extra_post in reels_in_day[extra_reel]:
                        res = self.delete_post(extra_post["id"])
                        if res.get("success"):
                            removed_count += 1
                            day_removed += 1
                details.append(f"• **يوم {d_str}**: تم الإبقاء على «{keep_reel[:35]}...» وحذف {day_removed} منشورات مكررة.")

        return {"conflicts_resolved": removed_count, "details": details}

    def get_sent_posts_with_metrics(self, count=30):
        """استرجاع المنشورات السابقة التي تم نشرها بالفعل مع مقاييس التفاعل الحية (Reactions, Views, Shares)"""
        query = """
        query GetSentPosts($orgId: OrganizationId!, $count: Int!) {
          posts(input: { organizationId: $orgId, filter: { status: [sent] } }, first: $count) {
            edges {
              node {
                id
                sentAt
                dueAt
                channelService
                text
                metrics {
                  name
                  value
                }
              }
            }
          }
        }
        """
        res = self._query(query, {"orgId": self.organization_id, "count": count})
        if res and "data" in res and res["data"] and "posts" in res["data"]:
            edges = res["data"]["posts"].get("edges", [])
            return [e["node"] for e in edges if "node" in e]
        return []




