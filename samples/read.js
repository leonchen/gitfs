var GF = require('../');

var debug = true;

var gf = new GF({
  repo: '/Volumes/RamDisk/sr',
  debug: debug 
});

var show = function () {
  if (debug) console.log.apply(console, arguments);
};

gf.read('HEAD', 'packages/poi.us/Address.js', function (err, tree) {
  if (err) return console.log(err);
  show('packages/poi.us/Address.js', tree.map(function (t) { 
    return t[1] == 'blob' ? [t[3], t[4].length] : [t[3], null];
  }));
}); 

gf.read('HEAD', 'packages/poi.us/*.js', function (err, tree) {
  if (err) return console.log(err);
  show('packages/poi.us/*.js', tree.map(function (t) { 
    return t[1] == 'blob' ? [t[3], t[4].length] : [t[3], null];
  }));
}); 

gf.read('HEAD', 'packages/**/*.yml', function (err, tree) {
  if (err) return console.log(err);
  show('packages/poi.us/*.js', tree.map(function (t) { 
    return t[1] == 'blob' ? [t[3], t[4].length] : [t[3], null];
  }));
}); 

gf.read('HEAD', 'packages/poi.us', function (err, tree) {
  if (err) return console.log(err);
  show('packages/poi.us', tree.map(function (t) { 
    return t[1] == 'blob' ? [t[3], t[4].length] : [t[3], null];
  }));
}); 

gf.read('HEAD', 'packages/poi.us/', function (err, tree) {
  if (err) return console.log(err);
  show('packages/poi.us/', tree.map(function (t) { 
    return t[1] == 'blob' ? [t[3], t[4].length] : [t[3], null];
  }));
}); 
