# free-workflow

10-tool free workflow replication (Kaggle, Simular Box, Cloady, Sakupa,
GitHub Actions, Supabase, Cloudflare Workers, Cloudflare R2, OpenRouter,
Google Colab) for LI MINGEN.

## What this repo does

`.github/workflows/health-check.yml` runs a daily health check
(01:00 UTC = 09:00 Asia/Singapore, plus manual "Run workflow" button):

- **Required:** Cloady hello-world service
  `https://hello-world-mw4vpn58-workspace-md7wee.cloady.io` must return HTTP 200.
- **Optional (warn only):** Orca `/v1/models` and the Supabase project URL.
  These are expected to be unreachable at times (the Kaggle session that
  serves Orca stops after ~40 min idle and its tunnel URL changes on restart).

Each run takes ~1 minute, so ~30 minutes/month — well within the GitHub
Actions free tier (2,000 min/month on a private repo; unlimited on a
public repo). Logs are kept as a workflow artifact for 30 days.

## Current 10-tool status (2026-11-09)

Done: Kaggle (dual T4, Orca 27B + DeepSeek), Simular Box "main",
Cloady (registered + hello-world deployed), Supabase (project
`free-workflow`, Singapore ap-southeast-1), OpenRouter (account + free
models + Default key), Cloudflare (Workers + R2 free tiers verified).
Paused by the user: Google Colab. Blocked: Sakupa (its device-registration
endpoint hangs server-side; retry later — see `~/workspace/sakupa-site/`).

## How to publish this repo (needs the user — no GitHub account exists yet)

1. Create / sign in to a GitHub account (github.com) — use
   `shinku.nikaidou.07210@gmail.com` if creating a new one.
   Do **not** create it from this machine without the user confirming.
2. Create a **public** repo named `free-workflow` (public = unlimited
   free Actions minutes).
3. On this machine, authenticate the CLI once: `gh auth login`
   (browser / token flow — the user completes it).
4. Push this folder:
   ```bash
   cd ~/workspace/free-workflow
   git init && git add . && git commit -m "Add daily health-check workflow"
   git branch -M main
   git remote add origin https://github.com/<your-username>/free-workflow.git
   git push -u origin main
   ```
5. Verify: repo page → Actions tab → "Daily health check" →
   "Run workflow". The first run should show Cloady 200 and
   "RESULT: OK". If the Cloady URL ever changes, update
   `scripts/health-check.sh`; if the Orca tunnel restarts, update
   `ORCA_BASE_URL` (or set it as a repo secret/variable).
