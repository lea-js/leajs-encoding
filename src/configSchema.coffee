isProd = process.env?.NODE_ENV == "production"
module.exports =
  encode:
    type: Boolean
    default: isProd
    _default: "inProduction"
    desc: "Should responses get encoded"
  
  encodeSave: 
    type: Boolean
    default: isProd
    _default: "inProduction"
    desc: "Should save encoded file besides existing plain file"
  
  encodeOptions: 
    type: Object
    default: {}
    desc: "Options used for zlib encoder"
  
  encodedTable: 
    type: Object
    default: {gzip: "gz", br: "br"}
    desc: "Lookup table to translate encoding to file extension"

  files$_item$encoded: 
    types: Array
    desc: "Encoded versions available besides plain file"

  folders$_item$encoded: 
    types: Array
    desc: "Encoded versions available besides plain file"
