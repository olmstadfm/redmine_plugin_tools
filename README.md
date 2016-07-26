## Merge updated Redmine views into your plugins

So, you redefined some redmine views in your plugins and want to merge these views
with updated versions from a new redmine release.

You've got three versions of each view: one in your plugin, one in updated redmine directory, 
and one in current redmine directory, which is also a common ancestor of the perevious two. Therefore you can do [three-way merge](https://stackoverflow.com/questions/9122948/run-git-merge-algorithm-on-two-individual-files).

Invocation:

```
[teksisto@localhost vhod]$ tree -L 1
.
├── mergeviews.sh
├── redmine-2.3.1
└── redmine-3.3.0

[teksisto@localhost]$ ./mergeviews.sh --old=redmine-2.3.1 --new=redmine-3.3.0                                   

./redmine-2.3.1/plugins/redmine_some_plugin/app/views/repositories/_revisions.html.erb:1: (success)
./redmine-2.3.1/plugins/redmine_other_plugin/app/views/projects/settings/_members.html.erb:1: (conflict 11)

Following plugins were affected:
 - redmine_some_plugin
 - redmine_other_plugin

Merge stats:

  - successful  1
  - conflicts 11
  
[teksisto@localhost]$ ./mergeviews.sh --reset=redmine-2.3.1
HEAD now at d0eb76d commit message
HEAD now at a76fd22 another commit message
```
### Todo

* for/find loop works only with paths without spaces, [rewrite using while/find](https://stackoverflow.com/questions/8677546/bash-for-in-looping-on-null-delimited-string-variable/8677566#8677566)
* absolute paths doesn't work
* merge inside [proper redmine git repository](https://github.com/redmine/redmine),
  by checking out revision from branch
  
