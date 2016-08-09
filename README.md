# GitDiffMap

Line number mapping through `git diff` output.

## What is *mapping*?

If the line is not changed in diff, there should be pair of numbers of:

* A number to identify where the line was located in *original* file
* A number to identify where the line is located in *new* file

This library is to compute the relation.

This is an example from GitDiffParser.

```
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
```

We can find some relations between lines:

* Line 4 `class CommitComment` in *new* file was at line 4 in *original* file too
* Line 5 `include Support` in *new* file is newly inserted
* Line 6 `include Helper` in *new* file was at line 5 in *original* file
* Line 14 `body = build_body(data)` in *original* file is not included in *new* file
* Line 15 `body = concat_body(data)` in *new* file is not included in *original* file

These relations can be calculated by this library as:

```rb
diff = "..."
map = GitDiffMap.parse(diff)

map.translate_new_to_original(4)   # => 4
map.translate_new_to_original(5)   # => nil
map.translate_new_to_original(6)   # => 6
map.translate_original_to_new(14)  # => nil
map.translate_new_to_original(15)  # => nil
```

## API

* `GitDiffMap#translate_new_to_original(line)`
* `GitDiffMap#translate_original_to_new(line)`
* `GitDiffMap#translate_new_lines_to_original_lines([lines])` `lines` must be sorted in ascending order
* `GitDiffMap#translate_original_lines_to_new_lines([lines])` `lines` must be sorted in ascending order

# Install

```
$ gem install git_diff_map
```
