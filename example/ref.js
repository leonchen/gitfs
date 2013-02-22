var GF = require('../');

var debug = true;

var gf = new GF({
  repo: '/Volumes/RamDisk/sr',
  debug: debug
});

var show = function () {
  if (debug) console.log.apply(console, arguments);
};

// version
gf.sha('HEAD', function (err, sha) {
  if (err) return show(err);
  show('HEAD', sha);
  gf.ls(sha, 'packages', function (err, tree) {
    if (err) return show(err);
    show('packages', tree.map(function (t) { return t[4]; }));
  }); 
}); 

// head
gf.sha('feature/crow', function (err, sha) {
  console.log("---------", sha);
  if (err) return show(err);
  gf.read(sha, 'packages/poi.us/Address.js', function (err, tree) {
    if (err) return console.log(err);
    show('packages/poi.us/Address.js', tree.map(function (t) { 
      return t[1] == 'blob' ? [t[4], t[5].length] : [t[4], null];
    }));
  }); 
}); 

// tag
gf.sha('aaa', function (err, sha) {
  if (err) return show(err);
  gf.read(sha, 'packages/poi.us/Address.js', function (err, tree) {
    if (err) return console.log(err);
    show('packages/poi.us/Address.js', tree.map(function (t) { 
      return t[1] == 'blob' ? [t[4], t[5].length] : [t[4], null];
    }));
  }); 
}); 
