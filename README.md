Patches
=======

Contains the motion detection patches for gst-plugins-bad, you can either either:

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
