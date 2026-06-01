class GithubConfig {
  final String owner;
  final String repo;
  final String branch;
  final String? token;

  GithubConfig({
    required this.owner,
    required this.repo,
    this.branch = 'main',
    this.token,
  });

  /// ── EDIT HERE ──
  /// Change owner, repo, and token to match your GitHub repository.
  static final GithubConfig defaultConfig = GithubConfig(
    owner: 'YOUR_GITHUB_USERNAME',   // ← Replace with your GitHub username or org
    repo: 'YOUR_REPO_NAME',          // ← Replace with your repository name
    branch: 'main',                  // ← Branch to read from
    token: null,                     // ← Optional: personal access token for private repos
  );

  String get baseUrl => 'https://api.github.com/repos/$owner/$repo';
  String get rawContentUrl => 'https://raw.githubusercontent.com/$owner/$repo/$branch';
  String get releasesUrl => '$baseUrl/releases';
  String get releasesLatestUrl => '$baseUrl/releases/latest';

  /// Get releases filtered by tag prefix (e.g., "appstore-v" or "whatsapp-v")
  String releasesTagUrl(String tag) => '$baseUrl/releases/tags/$tag';

  Map<String, String> get headers => {
        'Accept': 'application/vnd.github.v3+json',
        if (token != null && token!.isNotEmpty) 'Authorization': 'token $token',
      };
}
