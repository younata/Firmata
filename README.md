## Firmata - Firmata for Swift


This is simply a Swift-ish wrapper for [CFirmata](https://github.com/younata/CFirmata/).

Building instructions:

```bash
swift build
# If it fails because it couldn't find libfirmata.so, otherwise you're done!
cd Packages/CFirmata-*
sudo make install
cd -
swift build
```
