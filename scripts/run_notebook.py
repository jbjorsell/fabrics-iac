#!/usr/bin/env python3
# pyright: reportMissingTypeStubs=false
"""Run a Fabric notebook via the REST API."""

from __future__ import annotations

import re
import subprocess
import sys
import time
from typing import Any, Dict, Optional, Tuple, cast

import json
import urllib.error
import urllib.request


def _http_post(
    url: str, headers: Dict[str, str], body: Optional[Dict[str, Any]]
) -> Tuple[int, Dict[str, str], str]:
    data: Optional[bytes] = None
    if body is not None:
        data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url=url, data=data, method="POST")
    for k, v in headers.items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req) as resp:
            status = resp.getcode()
            text = resp.read().decode("utf-8")
            # headers: email.message.Message -> map-like
            hdrs = {k: v for k, v in resp.headers.items()}
            return status, hdrs, text
    except urllib.error.HTTPError as e:
        status = e.code
        text = e.read().decode("utf-8") if e.fp else ""
        hdrs = {k: v for k, v in e.headers.items()} if e.headers else {}
        return status, hdrs, text


def _http_get(url: str, headers: Dict[str, str]) -> Tuple[int, Dict[str, str], str]:
    req = urllib.request.Request(url=url, method="GET")
    for k, v in headers.items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req) as resp:
            status = resp.getcode()
            text = resp.read().decode("utf-8")
            hdrs = {k: v for k, v in resp.headers.items()}
            return status, hdrs, text
    except urllib.error.HTTPError as e:
        status = e.code
        text = e.read().decode("utf-8") if e.fp else ""
        hdrs = {k: v for k, v in e.headers.items()} if e.headers else {}
        return status, hdrs, text


def get_token() -> str:
    """Get Azure access token for Fabric API."""
    result = subprocess.run(
        [
            "az",
            "account",
            "get-access-token",
            "--resource",
            "https://api.fabric.microsoft.com",
            "--query",
            "accessToken",
            "-o",
            "tsv",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def run_notebook(workspace_id: str, notebook_id: str, language: str = "python") -> None:
    """Trigger notebook execution and wait for completion."""
    token = get_token()
    headers: Dict[str, str] = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

    # Trigger notebook run with specified language
    run_url = f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/notebooks/{notebook_id}/jobs/instances?jobType=RunNotebook"

    print(f"Starting notebook execution (language: {language})...")
    status_code, resp_headers, resp_text = _http_post(run_url, headers, {})

    print(f"Response status: {status_code}")

    if status_code not in [200, 202]:
        print(f"Error: {status_code} - {resp_text}")
        sys.exit(1)

    # For 202, job might be in Location header or response might be empty during provisioning
    job_id: Optional[str] = None
    if status_code == 202:
        # Try to get job ID from header first
        job_id = resp_headers.get("x-ms-job-id")
        if not job_id:
            location = resp_headers.get("Location")
            if location:
                print(f"Job queued. Location: {location}")
                # Extract job ID from location if present
                match = re.search(r"/jobs/instances/([^/?]+)", location)
                if match:
                    job_id = match.group(1)
                else:
                    print("Could not extract job ID from Location header")
                    sys.exit(1)
            elif resp_text:
                try:
                    job = cast(Dict[str, Any], json.loads(resp_text))
                    job_id = cast(Optional[str], job.get("id"))
                except json.JSONDecodeError:
                    job_id = None
            else:
                print(
                    "Note: Capacity may be starting up. Job accepted but no immediate response."
                )
                print("Check the notebook manually in the Fabric portal.")
                sys.exit(0)
    else:
        # Handle empty response for 200
        if not resp_text:
            print("Error: Empty response from API")
            sys.exit(1)
        job = cast(Dict[str, Any], json.loads(resp_text))
        job_id = cast(Optional[str], job.get("id"))

    if not job_id:
        print("Error: Missing job id in response")
        sys.exit(1)

    print(f"Job started: {job_id}")

    # Poll for completion
    status_url = f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/notebooks/{notebook_id}/jobs/instances/{job_id}"

    while True:
        time.sleep(5)
        s_code, _s_headers, s_text = _http_get(status_url, headers)

        if s_code != 200:
            print(f"Error checking status: {s_text}")
            sys.exit(1)

        status = cast(Dict[str, Any], json.loads(s_text))
        state = cast(Optional[str], status.get("status"))
        if state is None:
            print("Error: Missing job status in response")
            sys.exit(1)

        print(f"Status: {state}")

        if state in ["Completed", "Failed", "Cancelled"]:
            if state == "Completed":
                print("✓ Notebook execution completed successfully")
                sys.exit(0)
            else:
                print(f"✗ Notebook execution {state.lower()}")
                if state == "Failed":
                    failure_reason = cast(str, status.get("failureReason", "Unknown"))
                    print(f"Failure reason: {failure_reason}")
                sys.exit(1)


def _main() -> None:
    if len(sys.argv) < 3:
        print("Usage: run_notebook.py <workspace_id> <notebook_id> [language]")
        print("  language: python (default) or pyspark")
        sys.exit(1)

    workspace_id = sys.argv[1]
    notebook_id = sys.argv[2]
    language = sys.argv[3] if len(sys.argv) > 3 else "python"

    run_notebook(workspace_id, notebook_id, language)


if __name__ == "__main__":
    _main()
