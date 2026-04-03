# Instructions: Build Phase

Read this when implementing, testing, or shipping.

## How to Work During Build

Claude operates autonomously across the full build lifecycle. The user reviews and tests — Claude does everything else.

- Read all design docs and requirements before starting.
- Create a build plan, then execute it.
- Write code, create files, set up project structure — all autonomously.
- Write tests alongside the code.
- Run tests, read failures, fix issues, re-run — iterate until passing.
- Review your own code for quality, security, and consistency.
- Create build configuration, CI setup, and tooling as needed.
- Update `docs/roadmap.md` as you progress.
- Write to `docs/dev-journal.md` when something notable happens.

## During Test & Ship

- Run the full test suite and fix what's broken.
- Review for edge cases, error handling, and security.
- Update documentation to match the final implementation.
- Verify the setup flow works end-to-end.

**The principle:** The user reviews working software, not half-finished code. If something is broken, fix it. If code needs tests, write them. Minimize the need for human intervention — ask only when you genuinely need a judgment call.
