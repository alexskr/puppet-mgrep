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
class mgrep (
  Boolean $mgrep_enable           = false, # service disabled by default - since we do not want to have collusion with other mgrep instances
  String $mgrep_version           = '4.0.2',
  StdLib::Port $port              = 55555,
  Stdlib::Absolutepath $dict_path = "/var/lib/mgrep/${port}/dict",
  String $user                    = 'mgrep',
  String $group                   = 'mgrep',
) {
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

  file { ['/var/lib/mgrep', "/var/lib/mgrep/${port}"]:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0775',
  }

  file { "/opt/mgrep-${mgrep_version}/":
    ensure  => directory,
    recurse => true,
    mode    => '0644',
    source  => "puppet:///modules/mgrep/mgrep-${mgrep_version}",
  }
  -> file { "/opt/mgrep-${mgrep_version}/bin":
    ensure => directory,
    mode   => '0755',
  }

  file { "/opt/mgrep-${mgrep_version}/mgrep":
    mode   => '0755',
    source => "puppet:///modules/mgrep/mgrep-${mgrep_version}/mgrep",
  }
  file { '/opt/mgrep':
    ensure => link,
    target => "/opt/mgrep-${mgrep_version}",
  }

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

  # sample dict
  file { $dict_path:
    replace => false,
    source  => 'puppet:///modules/mgrep/sample_dictionary.txt',
    mode    => '0664',
    owner   => $user,
    group   => $group,
    before  => Service['mgrep'],
  }
}
