# op-env — run a command with secrets from 1Password, without persisting them.
# Usage: op-env .env.opfs -- opencode
#        op-env .env -- claude
# The env file should contain `op://` references, e.g. GITHUB_TOKEN="op://dev/github/token".
function op-env --description 'Run command with 1Password-injected env (no exported secrets)'
    if test (count $argv) -lt 3
        echo "usage: op-env <env-file> -- <command...>" >&2
        return 1
    end
    if not command -q op
        echo "op-env: 1Password CLI (op) not installed: brew install --cask 1password-cli" >&2
        return 1
    end
    set -l envfile $argv[1]
    if test "$argv[2]" != "--"
        echo "usage: op-env <env-file> -- <command...>" >&2
        return 1
    end
    op run --env-file="$envfile" -- $argv[3..]
end
