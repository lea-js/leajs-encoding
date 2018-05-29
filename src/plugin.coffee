

module.exports = ({init}) => init.hookIn ({
  config:{encode, encodeSave, encodedTable, encodeOptions}, 
  cache: {save, select}
  fs:{stat,createWriteStream}, 
  util: {isArray,capitalize},
  Promise,
  respond, 
  position}) =>

  available = ["gzip", "deflate"]

  if encodedTable or encode
    save.isEncoded = perm: false
    select.push (arr, req) =>
      encoding = req.encoding ?= req.getAccepted "accept-encoding"
      result = []
      for enc in encoding
        for el in arr
          result.push el if enc == el.isEncoded
      for el in arr
        unless el.isEncoded
          result.push el
      return result



  if encodedTable
    respond.hookIn position.after-1, (req) =>
      if not req.body? and 
          ((restricted = req.encoded)? or (encode and encodeSave)) and 
          (filename = req.file)? and 
          (stats = req.stats)? and
          not req.isEncoded
        encoding = req.encoding ?= req.getAccepted "accept-encoding"
        restricted ?= available
        if isArray(restricted)
          encoding = encoding.filter (enc) => ~restricted.indexOf(enc)
        for enc in encoding
          if ext = encodedTable[enc]
            newFilename = filename+"."+ext
            try
              newStats = await stat newFilename
            if newStats? and newStats.mtime > stats.mtime
              req.file = newFilename
              req.stats = newStats
              req.isEncoded = enc
              req.head.contentEncoding = enc
              return 
              
  if encode
    zlib = require "zlib"
    Stream = require "stream"
    respond.hookIn position.after+2, (req) =>
      if (body = req.body) and req.encode != false and not req.isEncoded
        encoding = req.encoding ?= req.getAccepted "accept-encoding"
        for enc in encoding
          if (encoder = zlib[enc])?
            req.isEncoded = enc
            req.head.contentEncoding = enc
            delete req.head.etag
            if (filename = req.plainFile = req.file) and 
                encodeSave and 
                (ext = encodedTable[enc])
              encodedOut = createWriteStream filename+"."+ext
              req.chunk.hookIn req.position.end, ({chunk}) => new Promise (resolve) =>
                encodedOut.write chunk, resolve
              req.end.hookIn req.position.end, => encodedOut.end()
            
            if body instanceof Stream
              encoder = zlib["create"+capitalize(enc)](encodeOptions)
              req.body = body.pipe(encoder)
              return
            else
              return new Promise (resolve, reject) =>
                encoder body, encodeOptions, (err, encoded) =>
                  return reject(err) if err?
                  req.body = encoded
                  resolve()

module.exports.configSchema = require("./configSchema")