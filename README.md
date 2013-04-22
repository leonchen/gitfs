gitfs
=======

fast git data fetcher

Usage for bin/gitfs:
1. get sha 
  DEBUG=true gitfs sha (HEAD|<branch>|<tag>)
2. list tree
  gitfs ls <sha> .
  gitfs ls <sha> dir
  gitfs ls <sha> dir/**/*.format
3. read blob
  gitfs read <sha> file
  gitfs read <sha> dir/file
  gitfs read <sha> dir/**/file
4. raw
  gitfs raw "<git command>"
