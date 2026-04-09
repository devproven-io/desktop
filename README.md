# DevProven

Developer skill verification from real code. Analyze your repositories and build a verified developer profile.

## Install

### Option 1: Desktop App (GUI)

Download the latest release from the [Releases](https://github.com/devproven-io/desktop/releases) page.

| Platform | Format |
|----------|--------|
| **Windows** | `.exe` installer (recommended) or `.msi` |
| **macOS** | `.dmg` (Apple Silicon) |
| **Linux** | `.AppImage` (portable) or `.deb` (Debian/Ubuntu) |

### Option 2: CLI Tool

Requires [.NET 10 SDK](https://dotnet.microsoft.com/download).

```bash
dotnet tool install -g DevProven
```

Then analyze any project:

```bash
devproven analyze ./my-project
```

Results are uploaded automatically to your DevProven profile.

## Getting started

1. Install DevProven (Desktop or CLI)
2. Sign in with your DevProven account
3. Add a repository and run analysis
4. View your Developer DNA at [devproven.com](https://devproven.com)

## Requirements

- Internet connection (analysis results upload to DevProven API)
- DevProven account ([sign up free](https://devproven.com))

## Links

- [DevProven](https://devproven.com)
- [NuGet Package](https://www.nuget.org/packages/DevProven)
- [Pricing](https://devproven.com/pricing)
