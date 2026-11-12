# -*- coding: utf-8 -*-
"""
جسر الربط السحابي مع منصة Sim.ai (Sim.ai Cloud Orchestrator Bridge)
يتيح للمكتب التنفيذي والمنظومة المحلية تشغيل ومراقبة وإرسال البيانات للـ Workflows السحابية في Sim.ai
التي تدير عمليات النشر والتواصل 24/7.
"""

import json
import urllib.request
import urllib.error
import os
import time

class SimAIBridge:
    def __init__(self, api_key=None, workspace_id=None, config_path=None):
        if not api_key or not workspace_id:
            # Load from config.json if not explicitly provided
            if not config_path:
                base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
                config_path = os.path.join(base_dir, "config.json")
            
            if os.path.exists(config_path):
                with open(config_path, "r", encoding="utf-8") as f:
                    cfg = json.load(f)
                    sim_cfg = cfg.get("sim_ai", {})
                    self.api_key = api_key or sim_cfg.get("api_key")
                    self.workspace_id = workspace_id or sim_cfg.get("workspace_id")
                    self.default_workflow_id = sim_cfg.get("workflow_id")
            else:
                self.api_key = api_key
                self.workspace_id = workspace_id
                self.default_workflow_id = None
        else:
            self.api_key = api_key
            self.workspace_id = workspace_id
            self.default_workflow_id = None

        self.base_url = "https://www.sim.ai/api/v2"
        self.headers = {
            "X-API-Key": self.api_key,
            "Content-Type": "application/json"
        }

    def _request(self, endpoint, method="GET", payload=None):
        url = f"{self.base_url}{endpoint}"
        data = json.dumps(payload).encode("utf-8") if payload is not None else None
        req = urllib.request.Request(url, data=data, headers=self.headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8")
            try:
                return json.loads(err_body)
            except Exception:
                return {"error": {"code": e.code, "message": err_body}}
        except Exception as e:
            return {"error": {"code": 500, "message": str(e)}}

    def get_workspace_info(self):
        """إرجاع بيانات مساحات العمل المرتبطة بالحساب"""
        return self._request("/workspaces")

    def list_workflows(self):
        """جلب قائمة مسارات العمل داخل مساحة العمل الحالية"""
        return self._request(f"/workflows?workspaceId={self.workspace_id}")

    def get_workflow(self, workflow_id=None):
        """جلب تفاصيل مسار عمل محدد"""
        wf_id = workflow_id or self.default_workflow_id
        if not wf_id:
            return {"error": "workflow_id is required"}
        return self._request(f"/workflows/{wf_id}")

    def execute_workflow(self, workflow_id=None, input_data=None):
        """
        تشغيل مسار العمل في سحابة Sim.ai فورياً مع تمرير مدخلات مخصصة
        input_data: dictionary يحتوي على المحتوى الإيماني، الآيات، الأذكار، إلخ
        """
        wf_id = workflow_id or self.default_workflow_id
        if not wf_id:
            return {"error": "workflow_id is required"}
        payload = {"input": input_data or {}}
        return self._request(f"/workflows/{wf_id}/execute", method="POST", payload=payload)

    def get_runs(self, workflow_id=None):
        """استعلام عن سجل التشغيل الخاص بمسار العمل"""
        wf_id = workflow_id or self.default_workflow_id
        if not wf_id:
            return {"error": "workflow_id is required"}
        return self._request(f"/workflows/{wf_id}/runs")

    def get_run_status(self, run_id, workflow_id=None):
        """فحص حالة عملية تشغيل معينة"""
        wf_id = workflow_id or self.default_workflow_id
        return self._request(f"/workflows/{wf_id}/runs/{run_id}")

if __name__ == "__main__":
    print("Connecting to Sim.ai...")
    bridge = SimAIBridge()
    ws = bridge.get_workspace_info()
    print("Workspaces:", ws)
    wfs = bridge.list_workflows()
    print("Workflows count:", len(wfs.get("data", [])))
    for wf in wfs.get("data", []):
        print(f"- {wf.get('name')} (ID: {wf.get('id')}) | Deployed: {wf.get('isDeployed')}")

