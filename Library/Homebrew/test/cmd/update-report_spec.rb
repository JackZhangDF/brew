require "cmd/update-report"

describe "brew update-report" do
  describe "::migrate_cache_entries_to_double_dashes" do
    let(:formula_name) { "foo" }
    let(:f) {
      formula formula_name do
        url "https://example.com/foo-1.2.3.tar.gz"
        version "1.2.3"
      end
    }
    let(:old_cache_file) { HOMEBREW_CACHE/"#{formula_name}-1.2.3.tar.gz" }
    let(:new_cache_file) { HOMEBREW_CACHE/"#{formula_name}--1.2.3.tar.gz" }

    before(:each) do
      FileUtils.touch old_cache_file
      allow(Formula).to receive(:each).and_yield(f)
    end

    it "moves old files to use double dashes when upgrading from <= 1.7.1" do
      Homebrew.migrate_cache_entries_to_double_dashes(Version.new("1.7.1"))

      expect(old_cache_file).not_to exist
      expect(new_cache_file).to exist
    end

    context "when the formula name contains dashes" do
      let(:formula_name) { "foo-bar" }

      it "does not introduce extra double dashes when called multiple times" do
        Homebrew.migrate_cache_entries_to_double_dashes(Version.new("1.7.1"))
        Homebrew.migrate_cache_entries_to_double_dashes(Version.new("1.7.1"))

        expect(old_cache_file).not_to exist
        expect(new_cache_file).to exist
      end
    end

    it "does not move files if upgrading from > 1.7.1" do
      Homebrew.migrate_cache_entries_to_double_dashes(Version.new("1.7.2"))

      expect(old_cache_file).to exist
      expect(new_cache_file).not_to exist
    end
  end
end
