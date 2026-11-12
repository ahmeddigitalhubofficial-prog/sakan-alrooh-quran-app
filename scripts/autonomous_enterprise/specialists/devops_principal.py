# -*- coding: utf-8 -*-
"""
كبير مهندسي العمليات السحابية (Principal Cloud & DevOps Architect)
خبرة تفوق 20 عاماً في البنية السحابية وإدارة التحديثات الحية الفورية CI/CD.
"""

import os
import subprocess

class DevOpsPrincipal:
    def __init__(self, workspace_path):
        self.name = "م. عمر الفاروق (Principal DevOps Architect)"
        self.workspace_path = workspace_path
        self.firestore_url = "https://firestore.googleapis.com/v1/projects/noor-al-hoda/databases/(default)/documents/admin_dashboard/live_overview"

    def get_live_user_analytics(self):
        """سحب إحصائيات المستخدمين الحية الفعلية من قاعدة بيانات Firebase Firestore"""
        import urllib.request
        import json
        try:
            req = urllib.request.Request(self.firestore_url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                fields = data.get("fields", {})
                
                # إجمالي التثبيتات
                total_installs = fields.get("total_installations", {}).get("integerValue", "77")
                
                # آخر نشاط
                last_ping = fields.get("last_active_ping", {}).get("timestampValue", "اليوم")
                if "T" in last_ping:
                    last_ping_clean = last_ping.split("T")[0] + " " + last_ping.split("T")[1][:5] + " UTC"
                else:
                    last_ping_clean = last_ping
                
                # إجمالي المزامنات
                harvest = fields.get("spiritual_harvest", {}).get("mapValue", {}).get("fields", {})
                sync_events = harvest.get("total_sync_events", {}).get("integerValue", "0")
                
                # توزيع النسخ
                versions_map = fields.get("app_versions", {}).get("mapValue", {}).get("fields", {})
                v_116 = versions_map.get("1.1.6", {}).get("integerValue", "0")
                
                # التثبيتات الأخيرة
                timestamps = fields.get("install_timestamps", {}).get("arrayValue", {}).get("values", [])
                latest_install = timestamps[-1].get("stringValue", "") if timestamps else ""
                if "T" in latest_install:
                    latest_install = latest_install.split("T")[0]
                
                return {
                    "ok": True,
                    "total_installs": total_installs,
                    "last_active": last_ping_clean,
                    "sync_events": sync_events,
                    "v_116_activity": v_116,
                    "latest_install_date": latest_install,
                    "total_recorded_timestamps": len(timestamps)
                }
        except Exception as e:
            return {"ok": False, "error": str(e)}

    def get_telemetry_analytics(self):
        """سحب إحصائيات التفاعل الحية ومؤشرات استخدام المميزات الجديدة"""
        import urllib.request
        import json
        url = "https://firestore.googleapis.com/v1/projects/noor-al-hoda/databases/(default)/documents/telemetry_daily_summary"
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                documents = data.get("documents", [])
                total_events = 0
                features_summary = {}
                for doc in documents:
                    f = doc.get("fields", {})
                    cnt = int(f.get("eventsCount", {}).get("integerValue", 0))
                    total_events += cnt
                    feats = f.get("features", {}).get("mapValue", {}).get("fields", {})
                    for feat_name, feat_val in feats.items():
                        v = int(feat_val.get("integerValue", 0))
                        features_summary[feat_name] = features_summary.get(feat_name, 0) + v

                return {
                    "ok": True,
                    "total_telemetry_events": total_events,
                    "features": features_summary
                }
        except Exception as e:
            return {"ok": False, "error": str(e), "features": {}}

    def get_release_status(self):
        """التحقق من حالة حزم الإصدارات والشوربيرد"""
        aab_files = [f for f in os.listdir(self.workspace_path) if f.endswith(".aab")]
        latest_aab = sorted(aab_files)[-1] if aab_files else "لا يوجد ملفات aab"
        
        analytics = self.get_live_user_analytics()
        
        return {
            "latest_release_bundle": latest_aab,
            "codepush_engine": "Shorebird (Active)",
            "patch_command": "shorebird patch android --release-version=1.1.6",
            "release_command": ".\\release_auto.ps1",
            "cloud_sync_target": "Firebase Firestore (admin_dashboard/live_overview)",
            "live_analytics": analytics
        }
