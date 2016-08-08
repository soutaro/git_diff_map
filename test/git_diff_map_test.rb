require_relative 'test_helper'

describe GitDiffMap do
  describe '#translate_original_to_new' do
    it "handles addition" do
      patch = GitDiffMap::Patch.new(GitDiffParser::Patch.new(<<-DIFF))
diff --git a/foo.rb b/bar.rb
index 51aec3b..ae23ea2 100644
--- a/foo.rb
+++ b/bar.rb
@@ -1,5 +1,5 @@
 class A
   attr_reader :foo
+  attr_reader :bar
   attr_reader :x
+  attr_reader :y
+  attr_reader :z
 end
      DIFF
      map = GitDiffMap.new(patch: patch)

      assert_equal 1, map.translate_original_to_new(1)
      assert_equal 2, map.translate_original_to_new(2)
      assert_equal 4, map.translate_original_to_new(3)
      assert_equal 7, map.translate_original_to_new(4)
    end

    it "handles deletion" do
      patch = GitDiffMap::Patch.new(GitDiffParser::Patch.new(<<-DIFF))
diff --git a/sample/sample1.rb b/sample/sample1.rb
index ff8419b..f913c3b 100644
--- a/sample/sample1.rb
+++ b/sample/sample1.rb
@@ -1,7 +1,4 @@
 class A
   attr_reader :foo
-  attr_reader :bar
   attr_reader :x
-  attr_reader :y
-  attr_reader :z
 end
      DIFF
      map = GitDiffMap.new(patch: patch)

      assert_equal 1, map.translate_original_to_new(1)
      assert_equal 2, map.translate_original_to_new(2)
      assert_equal nil, map.translate_original_to_new(3)
      assert_equal 3, map.translate_original_to_new(4)
      assert_equal nil, map.translate_original_to_new(5)
      assert_equal nil, map.translate_original_to_new(6)
      assert_equal 4, map.translate_original_to_new(7)
    end

    it "handles both" do
      patch = GitDiffMap::Patch.new(GitDiffParser::Patch.new(<<-DIFF))
diff --git a/sample/sample1.rb b/sample/sample1.rb
index ff8419b..f913c3b 100644
--- a/sample/sample1.rb
+++ b/sample/sample1.rb
@@ -1,7 +1,4 @@
 class A
   attr_reader :foo
-  attr_reader :bar
+  attr_reader :baz
   attr_reader :x
+  attr_reader :y
-  attr_reader :z
 end
      DIFF
      map = GitDiffMap.new(patch: patch)

      assert_equal 1, map.translate_original_to_new(1)
      assert_equal 2, map.translate_original_to_new(2)
      assert_equal nil, map.translate_original_to_new(3)
      assert_equal 4, map.translate_original_to_new(4)
      assert_equal nil, map.translate_original_to_new(5)
      assert_equal 6, map.translate_original_to_new(6)
    end
  end

  describe '#translate_new_to_original' do
    it "handles addition" do
      patch = GitDiffMap::Patch.new(GitDiffParser::Patch.new(<<-DIFF))
diff --git a/foo.rb b/bar.rb
index 51aec3b..ae23ea2 100644
--- a/foo.rb
+++ b/bar.rb
@@ -1,5 +1,5 @@
 class A
   attr_reader :foo
+  attr_reader :bar
   attr_reader :x
+  attr_reader :y
+  attr_reader :z
 end
      DIFF
      map = GitDiffMap.new(patch: patch)

      assert_equal 1, map.translate_new_to_original(1)
      assert_equal 2, map.translate_new_to_original(2)
      assert_equal nil, map.translate_new_to_original(3)
      assert_equal 3, map.translate_new_to_original(4)
      assert_equal nil, map.translate_new_to_original(5)
      assert_equal nil, map.translate_new_to_original(6)
      assert_equal 4, map.translate_new_to_original(7)
    end

    it "handles deletion" do
      patch = GitDiffMap::Patch.new(GitDiffParser::Patch.new(<<-DIFF))
diff --git a/sample/sample1.rb b/sample/sample1.rb
index ff8419b..f913c3b 100644
--- a/sample/sample1.rb
+++ b/sample/sample1.rb
@@ -1,7 +1,4 @@
 class A
   attr_reader :foo
-  attr_reader :bar
   attr_reader :x
-  attr_reader :y
-  attr_reader :z
 end
      DIFF
      map = GitDiffMap.new(patch: patch)

      assert_equal 1, map.translate_new_to_original(1)
      assert_equal 2, map.translate_new_to_original(2)
      assert_equal 4, map.translate_new_to_original(3)
      assert_equal 7, map.translate_new_to_original(4)
    end

    it "handles both" do
      patch = GitDiffMap::Patch.new(GitDiffParser::Patch.new(<<-DIFF))
diff --git a/sample/sample1.rb b/sample/sample1.rb
index ff8419b..f913c3b 100644
--- a/sample/sample1.rb
+++ b/sample/sample1.rb
@@ -1,7 +1,4 @@
 class A
   attr_reader :foo
-  attr_reader :bar
+  attr_reader :baz
   attr_reader :x
+  attr_reader :y
-  attr_reader :z
 end
      DIFF
      map = GitDiffMap.new(patch: patch)

      assert_equal 1, map.translate_new_to_original(1)
      assert_equal 2, map.translate_new_to_original(2)
      assert_equal nil, map.translate_new_to_original(3)
      assert_equal 4, map.translate_new_to_original(4)
      assert_equal nil, map.translate_new_to_original(5)
      assert_equal 6, map.translate_new_to_original(6)
    end
  end

  it "handles multiple hunks" do
    patch = GitDiffMap::Patch.new(GitDiffParser::Patch.new(<<-'EOS'))
@@ -2,6 +2,7 @@ module Saddler
   module Reporter
     module Github
       class CommitComment
+        include Support
         include Helper

         # https://developer.github.com/v3/repos/comments/#create-a-commit-comment
@@ -11,7 +12,7 @@ def report(messages, options)
           data = parse(messages)

           # build comment
-          body = build_body(data)
+          body = concat_body(data)
           return if body.empty?
           comment = Comment.new(sha1, body, nil, nil)

@@ -25,20 +26,6 @@ def report(messages, options)
           # create commit_comment
           client.create_commit_comment(comment)
         end
-
-        def build_body(data)
-          buffer = []
-          files = data['checkstyle']['file'] ||= []
-          files.each do |file|
-            errors = file['error'] ||= []
-            errors.each do |error|
-              severity = error['@severity'] && error['@severity'].upcase
-              message = error['@message']
-              buffer << [severity, message].compact.join(': ')
-            end
-          end
-          buffer.join("\n")
-        end
       end
     end
   end
    EOS
    map = GitDiffMap.new(patch: patch)

    # First hunk
    assert_equal nil, map.translate_new_to_original(5)
    assert_equal 5, map.translate_new_to_original(6)
    assert_equal 6, map.translate_new_to_original(7)

    # Second hunk
    assert_equal 13, map.translate_new_to_original(14)
    assert_equal nil, map.translate_new_to_original(15)
    assert_equal 15, map.translate_new_to_original(16)

    # Third hunk
    assert_equal 27, map.translate_new_to_original(28)
    assert_equal 42, map.translate_new_to_original(29)

    # First hunk
    assert_equal 6, map.translate_original_to_new(5)

    # Second hunk
    assert_equal nil, map.translate_original_to_new(14)
    assert_equal 16, map.translate_original_to_new(15)

    # Third hunk
    assert_equal nil, map.translate_original_to_new(28)
    assert_equal nil, map.translate_original_to_new(41)
    assert_equal 29, map.translate_original_to_new(42)
  end
end
