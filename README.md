# EPITA — Masters course notes

This repository holds notes, notebooks, course materials and small project files for my Master's courses at EPITA. It is organized by course and lecture so you can quickly find notes, Jupyter notebooks, and any accompanying data.

## 🌟 Portfolio Website

A modern, responsive portfolio website is now available in this repository! Open `index.html` to view your portfolio showcasing your education, skills, projects, and contact information.

**Quick Start:**
- View locally: Open `index.html` in your browser
- Customize: See `PORTFOLIO.md` for detailed customization guide
- Features: Dark/light theme, responsive design, smooth animations

[View Portfolio Customization Guide →](PORTFOLIO.md)

## Quick facts
- Location: this repository root (you are here)
- Primary use: store and version class notes and small project artifacts
- OS / shell used: macOS, zsh

## Top-level structure
The main folder is `masters_computer_science/` which contains subfolders for each course. Typical layout:

- `masters_computer_science/<course>/lecture X/notes.md` — lecture notes in Markdown
- `masters_computer_science/<course>/lecture X/*.ipynb` — Jupyter notebooks and exercises
- `masters_computer_science/<course>/project/` — course projects and datasets

Example (partial):

- `masters_computer_science/advanced_algorithms/lecture 1/TP1-complexity.ipynb`
- `masters_computer_science/data_privacy_by_design/project/fitlife-anonymized.csv`

## How I use this repo

- Open the repository in VS Code: `code /Users/arihant/Documents/epita`
- Use the integrated terminal (zsh) to run git commands or launch Jupyter.
- To view notebooks locally, run a Jupyter server from the repo root:

```bash
# (optional) create and activate a virtualenv first
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip jupyterlab
jupyter lab
```

Or open notebooks directly in VS Code (the Python extension will handle kernels).

## .gitignore
This repo includes a `.gitignore` tailored for macOS and note-taking projects. It ignores macOS system files, editor folders, temporary swap files, Python virtualenvs, and Jupyter checkpoint folders. The file is at `/.gitignore`.

Notes about data and notebooks:
- Some course folders include CSVs and small datasets (for example in `data_privacy_by_design/project/`). If you want these tracked, keep them committed. If you prefer to avoid committing large CSVs or sensitive exports, uncomment or add patterns to the `.gitignore` (for example `*.csv` or `data/`).
- By default `.ipynb_checkpoints/` is ignored but `.ipynb` files are tracked so notebooks are versioned.

## Contributing / Personal workflow

- I commit notes and notebooks after a lecture or when assignments are completed.
- Keep personal secrets (API keys, private datasets) out of the repo — use local `.env` files which are already ignored by `.gitignore`.
- If you need per-repo Git configuration (different email/name), run inside the repo:

```bash
git config --local user.name "Your Name"
git config --local user.email "you@example.com"
```

## Small checklist for new machines

1. Clone the repo: `git clone <your-remote> /path/to/epita`
2. Configure Git (global):

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global core.editor "code --wait"
git config --global credential.helper osxkeychain
```

3. (Optional) Create and activate a Python virtualenv for notebooks.

## Next steps you might want
- Add a `LICENSE` if you plan to share materials publicly.
- Add a short CONTRIBUTING.md if others will collaborate.
- If you have large datasets, consider Git LFS or an external storage link and keep a small sample in-repo for examples.

---

If you'd like, I can:
- add a `CONTRIBUTING.md` template,
- create a small script to set up the Python environment and open Jupyter, or
- customize `.gitignore` to ignore or track the CSV files under `data_privacy_by_design/project/`.
