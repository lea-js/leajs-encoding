# leajs-encoding

Plugin of [leajs](https://github.com/lea-js/leajs-server).

handles the encoding.

## leajs.config

```js
module.exports = {

  // Should responses get encoded
  // Default: inProduction
  encode: null, // Boolean

  // Options used for zlib encoder
  encodeOptions: {}, // Object

  // Should save encoded file besides existing plain file
  // Default: inProduction
  encodeSave: null, // Boolean

  // Lookup table to translate encoding to file extension
  // type: Object
  encodedTable: {"gzip":"gz","br":"br"},

  // Encoded versions available besides plain file
  files.$item.encoded: null, // Array

  // Encoded versions available besides plain file
  folders.$item.encoded: null, // Array

  // …

}
```

## License
Copyright (c) 2018 Paul Pflugradt
Licensed under the MIT license.
