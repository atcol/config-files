# Shared MCP server definitions for Claude Code and GitHub Copilot CLI
#
# Both tools use the same MCP protocol, so we define servers once here.
# Each tool imports this file and maps to its expected format.
#
# Environment variables required:
#   GITHUB_PERSONAL_ACCESS_TOKEN - GitHub PAT (https://github.com/settings/tokens)
#   SLACK_BOT_TOKEN              - Slack bot token (xoxb-...)
#   SLACK_TEAM_ID                - Slack team ID (T...)
#   SUPABASE_ACCESS_TOKEN        - Supabase PAT (https://supabase.com/dashboard/account/tokens)
{
  # GitHub - repos, issues, PRs, code search
  github = {
    command = "npx";
    args = ["-y" "@modelcontextprotocol/server-github"];
    env = {
      GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
    };
  };

  # Linear - issue tracking and project management
  # Uses official remote MCP server (SSE transport)
  # Authenticates via browser OAuth flow
  linear = {
    type = "sse";
    url = "https://mcp.linear.app/sse";
  };

  # Slack - channels, messages, threads, reactions
  slack = {
    command = "npx";
    args = ["-y" "@modelcontextprotocol/server-slack"];
    env = {
      SLACK_BOT_TOKEN = "\${SLACK_BOT_TOKEN}";
      SLACK_TEAM_ID = "\${SLACK_TEAM_ID}";
    };
  };

  # Supabase - database, auth, storage, edge functions
  supabase = {
    command = "npx";
    args = ["-y" "@supabase/mcp-server-supabase@latest" "--access-token" "\${SUPABASE_ACCESS_TOKEN}"];
  };
}
