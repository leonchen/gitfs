var exec = require('child_process').exec;

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

  function sha(ref, cb) {
    exec('git show-ref '+ref, { cwd: this.repo }, function (error, stdout, stderr) {
      if (error || stderr) return cb(error || stderr);
      cb(null, stdout.split(/\s+/)[0]);
    });
  }

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
      } else {
        self.readObj(sha, target, cb);
      }
    });
  };

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
      cb(stderr, treeSHA);
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
      var finish = function (err) {
        count--;
        if (err) cb(err);
        if (count <= 0) cb(null, tree);
      };
      tree.forEach(function (t, idx, tree) {
        if (t[1] == 'blob') {
          count++;
          self.readBlob(t, function (err, data) {
            tree[idx].push(data);
            finish(err);
          });
        }
      });
      if (count == 0) cb(null, tree);
    });
  }

  function readBlob(blob, cb) {
    var sha = blob[2];
    this.debugLog("read blob - sha:"+sha+", obj:"+blob[3]);
    exec('git cat-file -p '+sha, { cwd: this.repo }, function (error, stdout, stderr) {
      if (error || stderr) return cb(error || stderr);
      cb(stderr, stdout);
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
      if (tree[0][3] == target) return self.listObj(tree[0][2], '', cb);
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

  function parseTreeOut(out) {
    out = out.trim();
    if (!out) return [];
    return out.split(/\n/).map(#{
      return $1.split(/\s+/);
    });
  }

}
