# Jujutsu Command Reference

## Core Philosophy

Jujutsu operates on a **working-copy-as-a-commit** model where every working directory state is automatically tracked. There is no staging area - changes are immediately visible in the working copy commit.

## Repository Detection

Check for `.jj/` directory to determine if a repository uses jujutsu:

```bash
if [ -d .jj ]; then
  # Use jj commands
else
  # Fall back to git
fi
```

## Command Mappings: Git → Jujutsu

### Repository Setup

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git init` | `jj init` | Creates `.jj/` directory |
| `git init` (in git repo) | `jj git init --colocate` | Creates `.jj/` alongside `.git/`, enables interop |
| `git clone <url>` | `jj git clone <url>` | Clones git repo with jj |

### Daily Workflow

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git status` | `jj st` or `jj status` | Shows working copy status |
| `git add .` + `git commit -m "msg"` | `jj describe -m "msg"` | No staging; adds message to current change |
| `git commit -m "msg"` (start new) | `jj new` | Creates new change on top of current |
| `git diff` | `jj diff` | Shows diff of working copy |
| `git diff <file>` | `jj diff <file>` | Shows diff of specific file |
| `git log` | `jj log` | Shows change history |
| `git log -p` | `jj log -p` | Shows log with diffs |
| `git show <commit>` | `jj show <revision>` | Shows specific revision |

### Branching and Navigation

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git branch` | `jj bookmark list` | Lists bookmarks (jj term for branches) |
| `git branch <name>` | `jj bookmark create <name>` | Creates bookmark at current revision |
| `git checkout <branch>` | `jj edit <revision>` | Edits specific revision |
| `git checkout -b <name>` | `jj new` + `jj bookmark create <name>` | New change + bookmark |
| `git reset --hard HEAD^` | `jj abandon` | Abandons current change |

### Remote Operations

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git fetch` | `jj git fetch` | Fetches from git remotes |
| `git pull` | `jj git fetch` + `jj rebase` | Fetch then rebase |
| `git push` | `jj git push` | Pushes to git remote |
| `git push origin <branch>` | `jj git push --bookmark <name>` | Pushes specific bookmark |
| `git push -f` | `jj git push --force` | Force push (use carefully) |

### History Modification

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git commit --amend` | `jj describe` (edit in place) | No separate amend - just edit |
| `git rebase -i` | `jj rebase -d <dest>` | Interactive rebasing |
| `git rebase --continue` | `jj rebase --continue` | Continue after conflict resolution |
| `git cherry-pick` | `jj rebase -d <dest> -r <source>` | Move specific change |
| `git squash` | `jj squash` | Squash into parent |
| N/A | `jj split` | Split change into multiple (unique to jj) |
| N/A | `jj move --from <src> --to <dst>` | Move changes between revisions |

### Undo/Redo Operations (Unique to Jujutsu)

| Operation | Command | Notes |
|-----------|---------|-------|
| View operation history | `jj op log` | Shows all operations performed |
| Undo last operation | `jj op undo` | Reverts last operation (very safe!) |
| Undo specific operation | `jj op undo <operation-id>` | Reverts specific operation |
| Restore to operation | `jj op restore <operation-id>` | Restores to specific state |

### Conflict Resolution

| Git | Jujutsu | Notes |
|-----|---------|-------|
| `git merge` (manual resolve) | `jj resolve` | Conflicts are first-class citizens |
| `git rebase --continue` | `jj rebase --continue` | Continue after resolution |
| `git merge --abort` | `jj op undo` | Undo the merge/rebase operation |

## Revision Selection (Revsets)

Jujutsu uses a powerful revset language for selecting revisions:

```
@              # Current working copy
@-             # Parent of working copy
@--            # Grandparent
@^             # Alternative parent syntax
<change-id>    # Specific change (use first 12+ chars)
<bookmark>     # Named bookmark (branch)
<bookmark>@origin  # Remote bookmark
main@origin    # Remote main bookmark
description(text)  # Changes matching description
author(name)   # Changes by author
mine()         # Changes authored by current user
```

## Colocated Repository Workflow

When using `jj git init --colocate`, both `.git/` and `.jj/` coexist:

1. Can use both `git` and `jj` commands on same repository
2. `jj git push` and `jj git fetch` sync with git remotes
3. Git branches appear as jj bookmarks
4. Commits made with `git` appear in `jj log`
5. Commits made with `jj` appear in `git log`

## Common Patterns

### Start Feature Work
```bash
jj new                              # Create new change
jj describe -m "Start feature X"   # Add description
# ... edit files (automatically tracked) ...
jj diff                             # Review changes
```

### Update Commit Message
```bash
jj describe -m "Better description

With multiple lines"
```

### Create Another Change on Top
```bash
jj new                              # Start next change
jj describe -m "Add tests"         # Describe it
```

### Sync with Upstream
```bash
jj git fetch                        # Fetch latest
jj rebase -d main@origin            # Rebase on remote main
```

### Push Changes for Review
```bash
jj bookmark create my-feature       # Create bookmark
jj git push                         # Push to remote
```

### Fix Mistake Safely
```bash
jj op log                           # See operation history
jj op undo                          # Undo last operation
```

### Edit Past Change
```bash
jj edit <change-id>                 # Edit specific change
# ... make modifications ...
jj describe -m "Updated"            # Update description
jj new                              # Return to new change on top
```

### Squash Changes Together
```bash
jj squash                           # Squash into parent
# or
jj squash -r <source> -d <dest>    # Squash specific changes
```

## Safety Features

1. **Operation Log**: Every operation is logged and can be undone
2. **No Data Loss**: Even "destructive" operations can be reversed
3. **Conflict Tracking**: Conflicts are tracked explicitly in history
4. **Working Copy Commit**: Every state is saved automatically

## Git Compatibility Notes

- Jujutsu is fully compatible with git repositories
- Use `--colocate` to enable seamless git/jj interop
- Remote operations always use git protocols
- Team members can use git while you use jj
- All git remotes work normally with `jj git push/fetch`
