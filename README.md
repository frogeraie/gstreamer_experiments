Patches
=======

Contains the motioncells patches for gst-plugins-bad, for details, see:
https://bugzilla.gnome.org/show_bug.cgi?id=629244

Apply with:

```
patch -p1 < gst-plugins-bad-0.10.22-motioncells.patch
```

Or if you are using Homebrew, you can use the formula available in *ruby/brew*

```
cp gst-plugins-bad.rb /usr/local/Library/Formula/
brew remove gst-plugins-bad
brew install gst-plugins-bad
```
