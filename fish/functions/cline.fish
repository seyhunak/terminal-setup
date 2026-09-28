function cline --wraps cline --description 'Cline CLI (re-signs the binary if macOS code signing killed it)'
    # cline's macOS binaries ship with an invalid embedded ad-hoc signature;
    # Apple Silicon macOS SIGKILLs them (CODESIGNING / Invalid Page).
    # Re-apply a valid signature before launching. No-op when already valid.
    if test -x "$HOME/.cline/fix-code-signature.sh"
        "$HOME/.cline/fix-code-signature.sh" >/dev/null 2>&1
    end
    command cline $argv
end
