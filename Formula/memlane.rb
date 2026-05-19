class Memlane < Formula
  desc "MCP memory server for AI agents"
  homepage "https://github.com/c4rb0nx1/memlane"
  url "https://github.com/c4rb0nx1/memlane/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "c373cff3a7eeb1bb3ed34bf524afc2c560cb6de9b87dd01fd060e992ac47c9ab"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args(prefix: false)
    system "npm", "run", "build"
    system "npm", "prune", "--omit=dev"

    libexec.install "dist", "node_modules", "package.json", "package-lock.json", "templates"

    (bin/"memlane").write <<~SH
      #!/bin/bash
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/dist/index.js" "$@"
    SH
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/memlane --version")

    (testpath/"workstream").mkpath
    cd testpath/"workstream" do
      output = shell_output(
        "#{bin}/memlane init --name brew-test --gist \"Homebrew formula test\" --only claude --json",
      )
      assert_match "\"ok\": true", output
      assert_path_exists "knowledge/_index.json"
      assert_path_exists "knowledge/brew-test.md"
      assert_path_exists "knowledge/states/current-state.md"
      assert_path_exists ".mcp.json"
    end
  end
end
