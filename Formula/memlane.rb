class Memlane < Formula
  desc "MCP memory server for AI agents"
  homepage "https://github.com/AmazingCarbon/memlane"
  url "https://github.com/AmazingCarbon/memlane/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "dc38229200cf7a3aed2a4f8e6a9db40abe64ad6a1f8210e5e3155c5a772b5d54"
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
