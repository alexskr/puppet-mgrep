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


class mgrep (
  $mgrep_enable             = false, # service disabled by default - since we do not want to have collusion with other mgrep instances
  $mgrep_version            = $mgrep::params::mgrep_version,
  Integer $port             = $mgrep::params::mgrep_port,
  $dict_dir                 = $mgrep::params::dict_dir,
  $dict_path                = '/var/lib/mgrep/dict',
  $dict_symlink             = $mgrep::params::dict_symlink,
  String $user              = $mgrep::params::user,
  String $group             = $mgrep::params::group,
  Boolean $simpledictupdate = $mgrep::params::simpledictupdate,
  $dictupdate               = $mgrep::params::dictupdate,
  $redishost                = $mgrep::params::redishost,
  $redisport                = $mgrep::params::redisport,
) inherits mgrep::params {

  user { 'mgrep':
    ensure     => 'present',
    system     => true,
    comment    => 'Mgrep daemon',
    home       => '/usr/local',
    password   => '!!',
    shell      => '/sbin/nologin',
    managehome => false,
  }

  File {
    owner => root,
    group => root,
  }

  file { '/var/lib/mgrep':
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0775',
  }

  file { "/usr/local/mgrep-${mgrep_version}/":
    ensure  => directory,
    recurse => true,
    mode    => '0644',
    source  => "puppet:///modules/mgrep/mgrep-${mgrep_version}",
  }
  -> file { "/usr/local/mgrep-${mgrep_version}/bin":
    ensure => directory,
    mode   => '0755',
  }

  file {"/usr/local/mgrep-${mgrep_version}/mgrep":
    mode   => '0755',
    source => "puppet:///modules/mgrep/mgrep-${mgrep_version}/mgrep",
  }
  file {'/usr/local/mgrep':
    ensure => link,
    target => "/usr/local/mgrep-${mgrep_version}",
  }

  if ($facts['os']['family'] != 'RedHat') { fail ('unsupported OS') }
  case  $facts['os']['release']['major']  {
    '7' : {
      systemd::unit_file { 'mgrep.service':
        ensure  => 'present',
        content => epp ('mgrep/mgrep.service.epp', {
          'user'       => $user,
          'group'      => $group,
          'port'       => $port,
          'mgrep_dict' => $dict_path,
        }),
      }
      ~> service { 'mgrep':
        enable    => $mgrep_enable,
        hasstatus => true,
      }
    }
    '6' : {
      file { '/var/run/mgrep':
        ensure  => directory,
        owner   => 'mgrep',
        group   => 'mgrep',
        mode    => '0775',
        require => File["/usr/local/mgrep-${mgrep_version}"],
      }
      file { '/etc/init.d/mgrep':
        ensure  => present,
        mode    => '0755',
        content => template("mgrep/init.d.mgrep-${mgrep_version}.erb"),
        require => File["/usr/local/mgrep-${mgrep_version}"],
        notify  => Service['mgrep'],
      }
      ~> service { 'mgrep':
        enable  => $mgrep_enable,
        require => File['/etc/init.d/mgrep']
      }
    }
    default: { fail ('unsupported OS')}
  }

  if ($dict_symlink != undef) {
    file { [ "/var/lib/mgrep/${port}/dict" ]:
      ensure => link,
      target => $dict_symlink,
      before => Service['mgrep'],
    }
  } else {
    file { $dict_path:
      ensure  => present,
      replace => no,
      source  => 'puppet:///modules/mgrep/sample_dictionary.txt',
      mode    => '0664',
      owner   => $user,
      group   => $group,
      before  => Service['mgrep'],
    }
  }
}

