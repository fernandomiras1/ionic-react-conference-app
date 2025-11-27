#!/bin/bash

# Script to regenerate Gemfile.lock files with modern Bundler
# This fixes the "undefined method `untaint'" error in GitHub Actions

set -e  # Exit on error

echo "🔄 Regenerating Gemfile.lock files with modern Bundler..."

# Find the correct Ruby version (from Homebrew or rbenv)
if command -v brew &> /dev/null && [ -d "$(brew --prefix)/opt/ruby/bin" ]; then
    export PATH="$(brew --prefix)/opt/ruby/bin:$PATH"
    echo "📦 Using Homebrew Ruby: $(ruby --version)"
elif command -v rbenv &> /dev/null; then
    eval "$(rbenv init -)"
    echo "📦 Using rbenv Ruby: $(ruby --version)"
else
    echo "⚠️  Using system Ruby: $(ruby --version)"
fi

# Verify Ruby version
RUBY_VERSION=$(ruby -e 'puts RUBY_VERSION')
echo "Ruby version: $RUBY_VERSION"

# Update iOS Gemfile.lock
echo ""
echo "📱 Updating iOS Gemfile.lock..."
cd ios/App
rm -f Gemfile.lock
gem install bundler -v 2.4.22 --conservative || true
bundle install
echo "✅ iOS Gemfile.lock updated"

# Update Android Gemfile.lock  
echo ""
echo "🤖 Updating Android Gemfile.lock..."
cd ../../android
rm -f Gemfile.lock
bundle install
echo "✅ Android Gemfile.lock updated"

# Show Bundler version used
echo ""
echo "📦 Bundler version used:"
bundle --version

# Show the BUNDLED WITH version in both files
echo ""
echo "📄 iOS Gemfile.lock BUNDLED WITH:"
tail -2 ../ios/App/Gemfile.lock

echo ""
echo "📄 Android Gemfile.lock BUNDLED WITH:"
tail -2 Gemfile.lock

echo ""
echo "✨ Done! Now commit and push these changes:"
echo "   git add ios/App/Gemfile.lock android/Gemfile.lock"
echo "   git commit -m 'Update Gemfile.lock files to use modern Bundler'"
echo "   git push"
