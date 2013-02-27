var exec = require('child_process').exec;
var mm = require('minimatch');

export class GitFileSystem {
  function initialize(options) {
    this.repo = options.repo;
    this.debug = options.debug;
  };

  function debugLog(info) {
    if (this.debug) console.log("DEBUG: ", info);
  };

  function setRepo(repo) {
    this.repo = repo;
  };

  // output sha string
  function sha(ref, cb) {
    exec('git show-ref '+ref, { cwd: this.repo }, function (error, stdout, stderr) {
      //if (error || stderr) return cb(error || stderr);
      if (!stdout) cb('no sha found for '+ref);
      cb(null, stdout.split(/\s+/)[0]);
    });
  }

  // output the raw output of the git command
  function raw(command, cb) {
    exec(command, { cwd: this.repo }, function (error, stdout, stderr) {
      if (error || stderr) return cb(error || stderr);
      cb(null, stdout);
    });
  }

  function readFiles(sha, files, cb) {
    this.read(sha, files, cb);
  }

  function readFile(sha, file, cb) {
    this.read(sha, file, cb);
  }

  // output lines with: mod type sha name data
  function read(sha, target, type, cb) {
    if (type instanceof Function) {
      cb = type;
      type = null;
    }
    this.debugLog("read - sha:"+sha+", target:"+target+" type:"+type);
    this.getType(sha, type, function (err, type) {
      if (err) return cb(err);
      if (type == 'tag') {
        self.getTagCommit(sha, function (error, commitSHA) {
          if (error) return cb(error);
          self.read(commitSHA, target, 'commit', cb);
        });
      } else if (type == 'commit') {
        self.getCommitTree(sha, function (error, treeSHA) {
          if (error) return cb(error);
          self.readObj(treeSHA, target, cb);
        });
      } else if (type == 'tree') {
        self.readObj(sha, target, cb);
      } else {
        if (target instanceof Function) cb = target;
        self.readBlob(sha, cb);
      }
    });
  };

  // output lines with: mod type sha length name
  function ls(sha, target, type, cb) {
    if (type instanceof Function) {
      cb = type;
      type = null;
    }
    this.debugLog("ls - sha:"+sha+", target:"+target+" type:"+type);
    this.getType(sha, type, function (err, type) {
      if (err) return cb(err);
      if (type == 'tag') {
        self.getTagCommit(sha, function (error, commitSHA) {
          if (error) return cb(error);
          self.ls(commitSHA, target, 'commit', cb);
        });
      } else if (type == 'commit') {
        self.getCommitTree(sha, function (error, treeSHA) {
          if (error) return cb(error);
          self.listObj(treeSHA, target, cb);
        });
      } else {
        self.listObj(sha, target, cb);
      }
    });
  };

  function getType(sha, type, cb) {
    this.debugLog("get type - sha:"+sha+", type:"+type);
    if (!type) {
      exec('git cat-file -t '+sha, { cwd:this.repo }, function (error, stdout, stderr) {
        if (error || stderr) return cb(error || stderr);
        cb(null, stdout.trim());
      });
    } else {
      cb(null, type);
    }
  };

  function getTagCommit(sha, cb) {
    this.debugLog("get tag commit - sha:"+sha);
    exec('git cat-file -p '+sha, { cwd: this.repo }, function (error, stdout, stderr) {
      if (error || stderr) return cb(error || stderr);
      var commitSHA = stdout.split(/\s+/)[1]; 
      cb(null, commitSHA);
    });
  }

  function getCommitTree(sha, cb) {
    this.debugLog("get commit tree - sha:"+sha);
    exec('git cat-file -p '+sha, { cwd: this.repo }, function (error, stdout, stderr) {
      if (error || stderr) return cb(error || stderr);
      var treeSHA = stdout.split(/\s+/)[1]; 
      cb(null, treeSHA);
    });
  }

  function readObj(sha, target, cb) {
    this.debugLog("read obj - sha:"+sha+", target:"+target);
    target = target.replace(/\/$/, '');
    this.listTree(sha, target, function (err, out) {
      if (err) return cb(err);
      var tree = self.parseTreeOut(out);
      if (tree.length < 1) return cb(null, []);

      var count = 0;
      var output = [];
      var finish = function (err) {
        count--;
        if (err) return cb(err);
        if (count <= 0) cb(null, output);
      };
      tree.forEach(function (t, idx, tree) {
        if (t[1] == 'blob' && mm(t[3], target)) {
          count++;
          self.readBlob(t[2], function (err, data) {
            output.push([t[3], data]);
            finish(err);
          });
        }
      });
      if (count == 0) cb(null, output);
    });
  }

  function readBlob(sha, cb) {
    this.debugLog("read blob - sha:"+sha);
    exec('git cat-file blob '+sha, { cwd: this.repo }, function (error, stdout, stderr) {
      if (error || stderr) return cb(error || stderr);
      cb(null, stdout);
    });
  }

  function listObj(sha, target, cb) {
    this.debugLog("list obj - sha:"+sha+", target:"+target);
    target = target.replace(/\/$/, '');
    this.listTree(sha, target, function (err, out) {
      if (err) return cb(err);
      var tree = self.parseTreeOut(out);
      if (tree.length == 0 || tree.length > 1) return cb(null, tree);
      if (tree[0][1] == 'blob') return cb(null, tree);
      if (tree[0][3] == target) return self.listTreeBySHA(tree[0][2], cb);
    });
  }

  function listTree(sha, target, cb) {
    this.debugLog("list tree - sha:"+sha+", target:"+target);
    exec('git ls-tree '+sha+" "+target, { cwd: this.repo }, function (error, stdout, stderr) {
      if (error || stderr) return cb(error || stderr);
      if (!stdout) cb('no object found for '+target);
      cb(null, stdout);
    });
  }

  function listTreeBySHA(sha, cb) {
    this.debugLog("list tree by sha - sha:"+sha);
    exec('git cat-file -p '+sha, { cwd: this.repo }, function (error, stdout, stderr) {
      if (error || stderr) return cb(error || stderr);
      cb(null, stdout);
    });
  }

  function parseTreeOut(out) {
    out = out.trim();
    if (!out) return [];
    return out.split(/\n/).map(#{
      return $1.split(/\s+/);
    });
  }

}
