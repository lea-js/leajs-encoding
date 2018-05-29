{test, prepare, Promise, getTestID} = require "snapy"
try
  Lea = require "leajs-server/src/lea"
catch
  Lea = require "leajs-server"

http = require "http"
{writeFile, unlink, createWriteStream} = require "fs-extra"
zlib = require "zlib"
require "../src/plugin"
port = => 8081 + getTestID()

request = (path = "/", enc, dec) =>
  filter: "
    headers
    statusCode
    -headers.date
    body
    -headers.last-modified
    "
  stream: "body"
  promise: new Promise (resolve, reject) =>
    http.get {
      hostname: "localhost"
      port: port()
      agent: false 
      path: path
      headers: 
        "accept-encoding": enc
      }, (res) =>
        res.body = res.pipe(zlib["create"+dec]())
        resolve(res)
    .on "error", reject
  plain: true

prepare (state, cleanUp) =>
  lea = await Lea
    config: Object.assign (state or {}), {
      listen:
        port:port()
      disablePlugins: ["leajs-encoding"]
      plugins: ["./src/plugin"]
      encode: true
      encodeSave: true
      }
  cleanUp => lea.close()
  return state.files

test {files:{"/":"./test/file1"}}, (snap, files, cleanUp) =>
  # simple gzip
  filename = files["/"]
  await writeFile filename, "file1"
  cleanUp =>
    unlink filename
    unlink filename+".gz"
    .catch =>
  snap request "/", "gzip", "Gunzip"
  .then =>
    # deliver saved file on second request
    snap request "/", "gzip", "Gunzip"

test {files:{"/":"./test/file2"}}, (snap, files, cleanUp) =>
  # simple inflate
  filename = files["/"]
  await writeFile filename, "file2"
  cleanUp => unlink filename
  snap request "/", "deflate", "Inflate"

test {files:{"/":"./test/file3"}}, (snap, files, cleanUp) =>
  # deliver prepared gzip file
  filename = files["/"]
  filenamePacked = filename+".gz"
  await writeFile filename, "wrong"
  write = zlib.createGzip()
  write.pipe(createWriteStream(filenamePacked))
  cleanUp => 
    unlink filename
    unlink filenamePacked
  write.end "file3", =>
    snap request "/", "gzip", "Gunzip"