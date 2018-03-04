# DO NOT EDIT THIS FILE DIRECTLY
# This is a file generated from a literate programing source file located at
# https://github.com/zzamboni/elvish-modules/blob/master/alias.org.
# You should make any changes there and regenerate it from Emacs org-mode using C-c C-v t

use re

dir = ~/.elvish/aliases

aliases = [&]

fn _load_alias [name file]{
  -alias = [&]
  -source $file
  -tmpfile = (mktemp)
  echo '-alias['$name'] = $'$name'~' > $-tmpfile
  -source $-tmpfile
  rm -f $-tmpfile
  aliases[$name] = $-alias[$name]
}

fn def [&verbose=false name @cmd]{
  file = $dir/$name.elv
  echo "#alias:new" $name $@cmd > $file
  echo 'fn '$name' [@_args]{' $@cmd '$@_args }' >> $file
  if (not-eq $verbose false) {
    echo (edit:styled "Defining alias "$name green)
  }
  _load_alias $name $file
}

fn new [@arg]{ def $@arg }

fn bash-alias [@args]{
  line = $@args
  name cmd = (splits &max=2 '=' $line)
  def $name $cmd
}

fn export {
  result = [&]
  keys $aliases | each [k]{
    result[$k"~"] = $aliases[$k]
  }
  put $result
}

fn list {
  _ = ?(grep -h '^#alias:new ' $dir/*.elv | sed 's/^#//')
}

fn ls { list } # Alias for list

fn undef [name]{
  file = $dir/$name.elv
  if ?(test -f $file) {
    # Remove the definition file
    rm $file
    echo (edit:styled "Alias "$name" removed (will take effect on new sessions, or when you run 'del "$name"~')." green)
  } else {
    echo (edit:styled "Alias "$name" does not exist." red)
  }
}

fn rm [@arg]{ undef $@arg }

fn init {
  if (not ?(test -d $dir)) {
    mkdir -p $dir
  }

  for file [(_ = ?(put $dir/*.elv))] {
    content = (cat $file | slurp)
    if (or (re:match '^#alias:def ' $content) (re:match '\nalias\[' $content)) {
      m = (re:find '^#alias:(def|new) (\S+)\s+(.*)\n' $content)[groups]
      new $m[2][text] $m[3][text]
    } elif (re:match '^#alias:new ' $content) {
      name = (re:find '^#alias:new (\S+)\s+(.*)\n' $content)[groups][1][text]
      _load_alias $name $file
    }
  }
}

init
