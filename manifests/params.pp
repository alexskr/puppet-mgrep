class mgrep::params {
  $mgrep_port        = 55555
  $mgrep_version     = '4.0.2'
  $dict_dir          = '/srv/mgrep/dictionary'
  $dict_symlink      = undef
  $user              = 'mgrep'
  $group             = 'mgrep'
  $simpledictupdate  = false
  $dictupdate        = false
  $redishost         = 'localhost'
  $redisport         = '6379'
  $mgrep_initdscript = 'mgrep'
  $mgrep_cronfreq    = '*/5 * * * *'
}
