var GF = require('../');

var debug = true;

var gf = new GF({
  repo: '/Volumes/RamDisk/sr',
  debug: debug
});

var show = function () {
  if (debug) console.log.apply(console, arguments);
};

gf.list('HEAD', '', function (err, tree) {
  if (err) return show(err);
  show('<empty>', tree.map(function (t) { return t[3]; }));
}); 

gf.list('HEAD', 'packages/poi.us', function (err, tree) {
  if (err) return show(err);
  show('packages/poi.us', tree.map(function (t) { return t[3]; }));
}); 

gf.list('HEAD', 'packages/poi.us/', function (err, tree) {
  if (err) return show(err);
  show('packages/poi.us/', tree.map(function (t) { return t[3]; }));
}); 

gf.list('HEAD', 'packages/poi.us/*.js', function (err, tree) {
  if (err) return show(err);
  show('packages/poi.us/*.js', tree.map(function (t) { return t[3]; }));
}); 

gf.list('HEAD', 'packages/poi.us/Address.js', function (err, tree) {
  if (err) return show(err);
  show('packages/poi.us/Address.js', tree.map(function (t) { return t[3]; }));
}); 
