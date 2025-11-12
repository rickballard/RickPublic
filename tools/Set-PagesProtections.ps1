Param(
  [string]$RepoSlug = 'rickballard/RickPublic'
)
$ErrorActionPreference='Stop'
# Require 'deploy' check
@'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["deploy"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null
}
'@ | gh api --method PUT "repos/$RepoSlug/branches/main/protection" -H "Accept: application/vnd.github+json" --input -

# Lock github-pages environment to protected branches
@'
{
  "wait_timer": 0,
  "deployment_branch_policy": {
    "protected_branches": true,
    "custom_branch_policies": false
  }
}
'@ | gh api --method PUT "repos/$RepoSlug/environments/github-pages" -H "Accept: application/vnd.github+json" --input -

Write-Host "Protections applied for $RepoSlug (main requires 'deploy'; github-pages locked)."
