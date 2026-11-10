# Read-only scope collector for a code review (Windows PowerShell).
# Usage: .\scripts\scope.ps1 [-Repo <path>] [-Base <ref>]
# Makes no changes to the working tree. The only network call is `git fetch`.
param(
  [string]$Repo = ".",
  [string]$Base = ""
)

Set-Location $Repo
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Write-Error "not a git repository: $Repo"; exit 2 }

function Section($t) { Write-Output ""; Write-Output "== $t" }

Section "Repository"
Write-Output ("path:    " + (Get-Location).Path)
$remote = (git remote get-url origin 2>$null) -replace '//[^/@]*@', '//'
Write-Output "remote:  $remote"
Write-Output ("branch:  " + (git branch --show-current))
Write-Output ("dirty:   " + @(git status --porcelain).Count + " changed file(s)")

Section "Fetching remote (read-only)"
$env:GIT_TERMINAL_PROMPT = "0"
git fetch --all --prune -q

if (-not $Base) {
  $Base = git symbolic-ref -q --short refs/remotes/origin/HEAD 2>$null
  if (-not $Base) {
    foreach ($c in "origin/main", "origin/master") {
      git rev-parse --verify -q $c *> $null
      if ($LASTEXITCODE -eq 0) { $Base = $c; break }
    }
  }
}
if (-not $Base) { Write-Error "no base ref found; pass -Base <ref>"; exit 2 }

Section "Base: $Base"
Write-Output ("ahead of base:  " + (git rev-list --count "$Base..HEAD"))
Write-Output ("behind base:    " + (git rev-list --count "HEAD..$Base"))

Section "Commits on this branch (not on base)"
git log --format='%h %ad %an  %s' --date=short "$Base..HEAD" | Select-Object -First 30

Section "Changed files vs base (three-dot)"
git diff --stat "$Base...HEAD" | Select-Object -Last 40

Section "Other promotion branches on the remote"
git branch -r | Select-String -Pattern 'origin/(main|master|develop|test|staging|prod|production)$'

Section "Test layout (names only)"
git ls-files | Select-String -Pattern '(^|/)(tests?|__tests__|spec)(/|$)|(^|/)(test_.*|.*_test|.*\.test|.*\.spec)\.[a-z]+$' | Select-Object -First 40

Section "Test runner config present"
git ls-files | Select-String -Pattern '(^|/)(pytest\.ini|tox\.ini|setup\.cfg|pyproject\.toml|jest\.config\.[a-z]+|package\.json|conftest\.py|Makefile)$' | Select-Object -First 20

Section "Dependency manifests and lock files"
git ls-files | Select-String -Pattern '(^|/)(requirements[^/]*\.txt|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Pipfile\.lock|poetry\.lock|go\.sum|Cargo\.lock|pom\.xml|build\.gradle)$' | Select-Object -First 20

Section "Per-environment config files (candidates for drift checks)"
git ls-files | Select-String -Pattern '(^|/)(dev|test|staging|stage|prod|production|sandbox|sbx[a-z-]*)\.(json|ya?ml|toml|env)$' | Select-Object -First 40

Section "Done. Nothing was modified."
