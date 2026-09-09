# Notes

Should the whole program set a RUN_ID? Currently we generate two artefacts:
- log
- manifest

We need to be able to associate log runs with manifests.

## Manifest logic
Closely tied with resume.
On resume, the user should be able to select:
- Populate environment variables from the previous run's manifest, or
- Start fresh

In the first case, variables from the previous run should be copied to the
current run's manifest, _not_ sourced directly.

## Start, stop, resume
Setup should check for previous runs
"Stage" scripts should be small, and should return meaningful exit codes
User should have two options - either
- Start a fresh run, or
- Resume from the last zero exit code in the previous run
