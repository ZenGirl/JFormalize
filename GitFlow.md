# Git

My `git` process is as follows:

There is a `master` branch. 
From that a `develop` branch is created.
For each "feature" a new numbered branch is created:

```
kim@tinka ~/RubymineProjects/JFormalize (develop)$ git checkout -b features/001_ExtendReadme
Switched to a new branch 'features/001_ExtendReadme'
kim@tinka ~/RubymineProjects/JFormalize (features/001_ExtendReadme)$
```

The name and machine is irrelevant, but the current branch is shown in brackets.
Note that the numbering is somewhat arbitrary and once main line development is completed, it would switch to issue numbers.

> The *bash* scripts to provide this functionality is added to the base of this doc.

Once a feature branch is created, changes are made to the code base.
Once these reach a reasonable point, a commit is made:

```bash
git commit -a -m 'Extended Readme'
```

And a push occurs:

```
kim@tinka ~/RubymineProjects/JFormalize (features/001_ExtendReadme)$ git push
fatal: The current branch features/001_ExtendReadme has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin features/001_ExtendReadme

kim@tinka ~/RubymineProjects/JFormalize (features/001_ExtendReadme)$ git push --set-upstream origin features/001_ExtendReadme
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 749 bytes | 749.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
remote:
remote: Create a pull request for 'features/001_ExtendReadme' on GitHub by visiting:
remote:      https://github.com/ZenGirl/JFormalize/pull/new/features/001_ExtendReadme
remote:
To github.com:ZenGirl/JFormalize.git
 * [new branch]      features/001_ExtendReadme -> features/001_ExtendReadme
Branch 'features/001_ExtendReadme' set up to track remote branch 'features/001_ExtendReadme' from 'origin'.
```

The first notice only shows once if no upstream branch exists. 
Once done, only a `git push` is required.

After the branch is complete and accepted, it can be merged back into `develop`:

```bash
git checkout develop
git merge features/001_ExtendReadme
git push
```

Once a set of features are complete, `develop` can be merged into `master`, the version updated and pushed.
That done, the gem can be released.

An example process for an example set of features is shown below:

```
git checkout develop

# Some feature:
git checkout -b features/123_SomeFeature
git commit -a -m 'Meaningful message'
git commit -a -m 'Meaningful message'
git commit -a -m 'Meaningful message'
git push
git checkout develop
git merge features/123_Feature123
git push

# Another feature:
git checkout -b features/124_AnotherFeature
git commit -a -m 'Meaningful message'
git commit -a -m 'Meaningful message'
git commit -a -m 'Meaningful message'
git push
git checkout develop
git merge features/124_AnotherFeature
git push

# Release
git checkout master
git merge develop
[update version.rb]
git commit -a -m 'Update to N.N.N'
git push
```

