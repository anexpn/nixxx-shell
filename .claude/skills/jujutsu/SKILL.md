---
name: jujutsu
description: Guide for using Jujutsu (jj) version control system as an alternative to Git. Use this skill when working in repositories with a .jj directory, which indicates the repository uses Jujutsu VCS. Provides command mappings, workflows, and best practices for jj operations including commits, branching, rebasing, and git interoperability.
---

# Jujutsu Version Control

## Overview

Enable seamless use of Jujutsu (jj), a modern version control system that is fully compatible with Git. Jujutsu provides a more intuitive interface with automatic change tracking, safe history rewriting, and powerful undo capabilities.

## When to Use This Skill

Use jujutsu commands automatically when:
- The working directory contains a `.jj/` directory (indicates a jujutsu repository)

Otherwise, continue using git commands as normal.

**Detection pattern:**
```bash
if [ -d .jj ]; then
  # Use jj commands from this skill
else
  # Use standard git commands
fi
```

## Core Concepts

### Working-Copy-as-a-Commit Model
- Every file change is automatically part of the working copy commit
- No staging area - changes are immediately tracked
- Use `jj describe` to add/update commit messages (not `jj commit`)
- Use `jj new` to create a new change on top of current

### Change-Centric History
- Each "change" has a unique ID that persists across rewrites
- Revisions can be modified in place without losing history
- Conflicts are tracked explicitly as first-class citizens

### Safe Operations with Undo
- Every operation is logged in the operation log (`jj op log`)
- Any operation can be undone with `jj op undo`
- Even "destructive" operations never lose data permanently

## Daily Workflow

### Starting Work

Check repository type and status:
```bash
# Check if jujutsu repo
if [ -d .jj ]; then
  jj status
else
  git status
fi
```

### Making Changes

There are two workflows depending on whether you have existing changes:

**Workflow 1: Commit existing changes** (when `jj status` shows changes)
```bash
# 1. Edit files (automatically tracked - no `add` needed)
# 2. Review changes
jj diff              # See all changes
jj status            # Check status

# 3. Commit the changes
jj commit -m "Implement feature X"   # Describe and create new change on top
```

**Workflow 2: Start new change first** (when `jj status` shows no changes)
```bash
jj new                              # Start new empty change
# ... edit files ...
jj describe -m "Implement feature"  # Add description as you work
jj new                              # When done, create next change
```

**When user says "commit":**
- If `jj status` shows changes: use `jj commit -m "message"`
- If current change is already described: use `jj new` to start next change

**Note**: `jj commit` = `jj describe` + `jj new` in one command.

### Viewing History

```bash
jj log               # View change history
jj log -p            # View history with diffs
jj log <file>        # View history for specific file
jj show <revision>   # Show specific revision
```

## Git Interoperability

### Working with Git Remotes

Jujutsu works seamlessly with git remotes using `jj git` commands:

```bash
# Fetch from remote
jj git fetch

# Push to remote
jj git push

# Push specific bookmark (branch)
jj git push --bookmark <name>

# Push with force (use carefully)
jj git push --force
```

### Colocated Repositories

When a repository has both `.git/` and `.jj/` directories:
- Both git and jj commands work on the same repository
- Changes made with git appear in jj log and vice versa
- Git branches appear as jj bookmarks
- Use `jj git init --colocate` to set this up initially

### Syncing with Upstream

```bash
# Fetch latest changes
jj git fetch

# Rebase current work on remote main
jj rebase -d main@origin

# If conflicts occur, resolve and continue
jj resolve
jj rebase --continue
```

## Branching and Bookmarks

Jujutsu uses "bookmarks" (similar to git branches):

```bash
# List bookmarks
jj bookmark list

# Create bookmark at current revision
jj bookmark create <name>

# Move bookmark to current revision
jj bookmark set <name>

# Track remote bookmark
jj bookmark track <name>@origin

# Delete bookmark
jj bookmark delete <name>
```

**Common pattern for feature work:**
```bash
jj new                           # Start new change
jj describe -m "Add feature"     # Describe work
jj bookmark create my-feature    # Create bookmark
jj git push                      # Push to remote
```

## History Modification

### Editing Past Changes

```bash
# Edit a specific revision
jj edit <change-id>
# ... make changes ...
jj describe -m "Updated message"
jj new                           # Return to tip
```

### Squashing Changes

```bash
# Squash current change into parent
jj squash

# Squash specific changes
jj squash -r <source> -d <destination>
```

### Rebasing

```bash
# Rebase current change onto destination
jj rebase -d <destination>

# Rebase specific change
jj rebase -r <revision> -d <destination>

# Continue after conflict resolution
jj rebase --continue
```

### Splitting Changes

```bash
# Split current change into multiple
jj split
# Interactive prompt will guide through the split
```

### Moving Changes Between Revisions

```bash
# Move specific changes between revisions
jj move --from <source> --to <destination>
```

## Safe Undo and Recovery

### Operation History

View all operations performed:
```bash
jj op log            # Show operation history
```

### Undoing Operations

```bash
# Undo the last operation
jj op undo

# Undo specific operation
jj op undo <operation-id>

# Restore to specific state
jj op restore <operation-id>
```

**When to use undo:**
- Accidentally abandoned a change
- Rebased to wrong destination
- Made any mistake that needs reversal
- Want to explore alternative approaches

## Revision Selection (Revsets)

Use these patterns to reference revisions:

```
@                    # Current working copy
@-                   # Parent of working copy
@--                  # Grandparent
<change-id>          # Specific change (first 12+ chars)
<bookmark>           # Named bookmark
main@origin          # Remote bookmark
description(text)    # Changes matching description text
author(name)         # Changes by specific author
mine()               # Changes authored by current user
```

**Examples:**
```bash
jj diff -r @-                    # Diff of parent change
jj show main@origin              # Show remote main
jj log -r 'author(alice)'        # Log of Alice's changes
jj rebase -d main@origin         # Rebase onto remote main
```

## Conflict Resolution

Jujutsu tracks conflicts explicitly in history:

```bash
# When conflicts occur during rebase/merge
jj status                        # Shows conflicted files

# Resolve conflicts in your editor
# Edit conflicted files to resolve

# Mark as resolved and continue
jj resolve
jj rebase --continue

# Or undo the operation entirely
jj op undo
```

## Common Command Patterns

### Feature Development

```bash
# Option 1: Commit existing work
# ... edit files ...
jj commit -m "Start feature X"
# ... work more ...
jj commit -m "Add tests for X"

# Option 2: Start new changes first
jj new
jj describe -m "Start feature X"
# ... work on feature ...
jj new
jj describe -m "Add tests for X"
# ... add tests ...

# Create bookmark and push
jj bookmark create feature-x
jj git push
```

### Code Review Workflow

```bash
# Push changes for review
jj bookmark create my-feature
jj git push

# Address review feedback (edit in place)
jj edit <change-id>
# ... make changes ...
jj describe -m "Address review feedback"
jj git push --force

# Squash review fixups if desired
jj squash
```

### Syncing Work

```bash
# Sync with remote regularly
jj git fetch
jj rebase -d main@origin

# Push your work
jj git push
```

### Exploring History

```bash
# View detailed history
jj log -p

# Search for specific changes
jj log -r 'description(bug fix)'

# Show what changed in a file
jj log <file>
```

## Reference Material

For detailed command mappings between git and jujutsu, including all supported operations and syntax, refer to `references/command_reference.md`.

The reference includes:
- Complete git → jj command mappings
- Revset syntax and examples
- Colocated repository workflows
- Advanced patterns and use cases

Load the reference when:
- Unsure of the jj equivalent for a git command
- Need to understand revset syntax
- Working with complex history modifications
- Debugging workflow issues

## Best Practices

1. **Use descriptive commit messages**: Run `jj describe` frequently to document work
2. **Create new changes regularly**: Use `jj new` to logically separate work
3. **Leverage safe undo**: Don't fear mistakes - `jj op undo` is always available
4. **Sync frequently**: Regular `jj git fetch` keeps work up-to-date
5. **Use bookmarks for features**: Create bookmarks for feature branches
6. **Review before pushing**: Use `jj log` and `jj diff` to review before `jj git push`

## Error Handling

### If jj Command Not Found

Jujutsu should be available via the `shell.tools.development.enable` configuration. If not available:
```bash
# Verify installation
command -v jj || echo "jujutsu not installed"
```

Inform the user to enable development tools in their Nix configuration.

### When .jj Directory Missing

If user wants to use jujutsu in an existing git repository:
```bash
# Initialize colocated repository (keeps .git)
jj git init --colocate
```

This creates `.jj/` alongside existing `.git/`, enabling jj commands while maintaining git compatibility.
