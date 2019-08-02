#
# Class: mgrep
#
# Description: This class manages mgrep server.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
# if dict_symlink is specified, it creates a symlink from dict to the location specified by dict_symlink


define mgrep::instance (
  Boolean $mgrep_enable = true,
  $mgrep_version        = $mgrep::params::mgrep_version,
  Integer $port         = 55556,
  $dict_path            = "/var/lib/mgrep/${port}/dictionary",
  $dict_symlink         = undef,
  String $user          = $mgrep::params::user,
  String $group         = $mgrep::params::group,
  String $redishost     = $mgrep::params::redishost
) {

  if ($facts['os']['family'] != 'RedHat') { fail ('unsupported OS') }

  File {
    owner => root,
    group => root,
  }

  file { "/var/lib/mgrep/${port}":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0775',
    #    require => File['/srv/mgrep' ]
  }

  if ($dict_symlink != undef) {
    file { [ "/var/lib/mgrep/${port}/dict" ]:
      ensure => link,
      target => $dict_symlink
    }
  }
  systemd::unit_file { "mgrep-${port}.service":
    ensure  => 'present',
    content => epp ('mgrep/mgrep.service.epp', {
      'user'       => $user,
      'group'      => $group,
      'port'       => $port,
      'mgrep_dict' => $dict_path,
    }),
  }
  service { "mgrep-${port}":
    enable    => $mgrep_enable,
    hasstatus => true,
  }

}

