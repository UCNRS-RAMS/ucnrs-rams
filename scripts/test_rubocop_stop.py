"""Exercise the hook in disposable repositories with a fake Bundler executable."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).with_name("rubocop-stop.rb")
RUBY = shutil.which("ruby")


class StopHookTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="rams hook ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "scripts").mkdir()
        shutil.copy(SOURCE, self.root / "scripts/rubocop-stop.rb")
        self.git("init", "-q")
        self.git("config", "user.email", "hook@example.test")
        self.git("config", "user.name", "Hook Test")
        for name in ["changed.rb", "deleted.rb", "renamed.rb", "untouched.rb"]:
            (self.root / name).write_text("original\n")
        self.git("add", ".")
        self.git("commit", "-qm", "fixture")
        fake_bin = self.root / "fake-bin"
        fake_bin.mkdir()
        bundle = fake_bin / "bundle"
        bundle.write_text(
            f"#!{RUBY}\nrequire 'json'\n"
            "File.write(ENV.fetch('CAPTURE'), JSON.generate(ARGV))\n"
            "puts 'fixture diagnostic'\nexit ENV.fetch('LINT_STATUS', '0').to_i\n"
        )
        bundle.chmod(0o755)
        self.env = dict(os.environ, PATH=f"{fake_bin}:{os.environ['PATH']}",
                        CAPTURE=str(self.root / "arguments.json"))

    def git(self, *args):
        return subprocess.run(["git", *args], cwd=self.root, check=True,
                              capture_output=True)

    def run_hook(self, status=0, retry=False, payload=None):
        return subprocess.run(
            [RUBY, "rubocop-stop.rb"], cwd=self.root / "scripts",
            env=dict(self.env, LINT_STATUS=str(status)),
            input=payload if payload is not None else json.dumps({"stop_hook_active": retry}),
            text=True, capture_output=True,
        )

    def test_no_ruby_changes_skips_bundler(self):
        (self.root / "notes.md").write_text("documentation")
        result = self.run_hook()
        self.assertEqual(result.returncode, 0)
        self.assertEqual(json.loads(result.stdout), {})
        self.assertFalse((self.root / "arguments.json").exists())

    def test_selection_and_safe_arguments(self):
        (self.root / "changed.rb").write_text("changed")
        (self.root / "deleted.rb").unlink()
        self.git("mv", "renamed.rb", "new name.rb")
        names = ["space name.rb", "line\nbreak.rake", "-option.rb", "Gemfile", "Rakefile"]
        for name in names:
            (self.root / name).write_text("new")
        (self.root / ".gitignore").write_text("ignored.rb\n")
        (self.root / "ignored.rb").write_text("ignore")
        result = self.run_hook()
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads((self.root / "arguments.json").read_text())
        self.assertEqual(args[:7], ["exec", "rubocop", "--force-exclusion", "--format", "simple", "--", "changed.rb"])
        self.assertEqual(set(args[6:]), set(names + ["changed.rb", "new name.rb"]))
        self.assertEqual((self.root / "changed.rb").read_text(), "changed")

    def test_first_failure_requests_correction(self):
        (self.root / "changed.rb").write_text("changed")
        result = self.run_hook(status=1)
        self.assertEqual(result.returncode, 2)
        self.assertIn("fixture diagnostic", result.stderr)
        self.assertIn("pre-existing", result.stderr)

    def test_retry_surfaces_remaining_failures(self):
        (self.root / "changed.rb").write_text("changed")
        result = self.run_hook(status=1, retry=True)
        self.assertEqual(result.returncode, 0)
        self.assertIn("fixture diagnostic", json.loads(result.stdout)["systemMessage"])

    def test_tool_error_is_not_a_lint_failure(self):
        (self.root / "changed.rb").write_text("changed")
        result = self.run_hook(status=2)
        self.assertEqual(result.returncode, 0)
        self.assertIn("could not complete", json.loads(result.stdout)["systemMessage"])

    def test_invalid_input_is_visible(self):
        result = self.run_hook(payload="not json")
        self.assertEqual(result.returncode, 0)
        self.assertIn("could not run", json.loads(result.stdout)["systemMessage"])


if __name__ == "__main__":
    unittest.main()
