# README And Environment Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Improve repository documentation, add reproducible Python environment config, prepare the environment locally, and verify the project can start through Jupyter.

**Architecture:** Keep the repo notebook-first and non-intrusive. Add lightweight dependency manifests (`requirements.txt`, optional `environment.yml`) at repo root and document one canonical startup path. Validate by creating a local virtual environment and launching JupyterLab.

**Tech Stack:** Python 3.10+, pip, virtualenv, JupyterLab, common deep-learning libraries (PyTorch ecosystem + transformers stack).

### Task 1: Inspect Existing Project Inputs

**Files:**
- Read: `README.md`
- Read: `01_动手学习深度学习/*.ipynb`
- Read: `02_动手学BERT_T5_GPT/**/*.ipynb`
- Read: `03_LLMs实践/*.ipynb`
- Read: `04_llama-alpaca实践/*.ipynb`
- Read: `05_GLM_p-tuning/*.ipynb`
- Read: `06_Langchain实战/*.ipynb`

**Step 1: Gather import statements from notebooks and Python scripts**
Run: `rg -n "^(import|from) " -g "*.py"`
Run: `jq`/notebook JSON scan command to extract code cell imports.
Expected: Candidate dependency list with duplicates.

**Step 2: Normalize dependency names and choose conservative pinned ranges**
Output: curated package list suitable for macOS CPU-friendly baseline.

### Task 2: Improve Project README

**Files:**
- Modify: `README.md`

**Step 1: Rewrite README structure**
Include:
- Project overview and module map
- Prerequisites and Python version
- Quick start (create env, install deps, launch Jupyter)
- Suggested notebook learning order
- Common troubleshooting notes

**Step 2: Verify links and commands are copy-paste ready**
Run: `rg -n "\]\(" README.md`
Expected: all module links valid relative paths.

### Task 3: Add Environment Configuration

**Files:**
- Create: `requirements.txt`
- Create: `environment.yml`

**Step 1: Add pip requirements for notebook + DL workflow**
Include core scientific stack, Jupyter stack, transformer/LLM tooling, and utility packages used by notebooks.

**Step 2: Add conda environment file mirroring pip baseline**
Expected: users can bootstrap with either pip or conda.

### Task 4: Prepare Local Environment

**Files:**
- Create (local only, ignored by git if needed): `.venv/`

**Step 1: Create venv**
Run: `python3 -m venv .venv`
Expected: `.venv` created.

**Step 2: Install dependencies**
Run: `.venv/bin/pip install -U pip`
Run: `.venv/bin/pip install -r requirements.txt`
Expected: successful install or actionable failure list.

### Task 5: Verify Startup

**Files:**
- No source changes expected

**Step 1: Start JupyterLab with the new environment**
Run: `.venv/bin/jupyter lab --no-browser --port 8889`
Expected: server startup log with local URL.

**Step 2: Validate key imports non-interactively**
Run: `.venv/bin/python -c "import torch, transformers, datasets, peft, langchain; print('ok')"`
Expected: prints `ok`.

### Task 6: Report Outcomes

**Files:**
- Summarize changed files and verification outputs

**Step 1: Provide concise runbook and next actions**
Include exact commands used for startup and how to stop Jupyter.
