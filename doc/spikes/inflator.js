Inflater = require('../../vendor/inflater')

inflater = new Inflater();
zlib = require('zlib');
inf = zlib.createInflateRaw()
inf.on('data', function(data) {
  console.log('node inflate', data.toString().length)
})
def = zlib.createDeflateRaw()
def._flush = zlib.Z_SYNC_FLUSH
def.on('data', function(data) {
  d = inflater.append(new Uint8Array(data))
  console.log('coolio inflate', String.fromCharCode.apply(null, d))
  inf.write(data)
})
def.write('MY LITTLE INPUT')
def.write('ANOTHER INPUT')
i = ""
n = 1000
while(n--)
  i+= "REALLY BIG INPUTREALLY BIG INPUTREALLY BIG INPUTREALLY BIG INPUTREALLY BIG INPUTREALLY BIG INPUT"
console.log("should: "+i.length)
def.write(i)
def.end()