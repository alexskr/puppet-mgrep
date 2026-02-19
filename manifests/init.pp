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
  Boolean $mgrep_enable           = true, # disable if using multiple instances
  Boolean $create_init_dict       = true,
  String $mgrep_version           = '4.0.2',
  StdLib::Port $port              = 55555,
  Stdlib::Absolutepath $dict_path = "/opt/mgrep/share/sample_dictionary.txt",
  String $user                    = 'mgrep',
  String $group                   = 'mgrep',
) {
  user { 'mgrep':
    ensure     => 'present',
    system     => true,
    comment    => 'Mgrep daemon',
    home       => '/opt/mgrep',
    password   => '!!',
    shell      => '/sbin/nologin',
    managehome => false,
  }

  file { ['/var/lib/mgrep', "/var/lib/mgrep/${port}"]:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0775',
  }

   file { ["/opt/mgrep-${mgrep_version}/", "/opt/mgrep-${mgrep_version}/bin"]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file { "/opt/mgrep-${mgrep_version}/bin/mgrep":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode   => '0755',
    source  => "puppet:///modules/mgrep/mgrep-${mgrep_version}/bin/mgrep",
  }
  -> file { "/opt/mgrep-${mgrep_version}/share/":
    ensure  => directory,
    recurse => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/mgrep/mgrep-${mgrep_version}/share",
  }
  -> file { '/opt/mgrep':
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
    require  => File[ "/opt/mgrep" ],
  }
  ~> service { 'mgrep':
    enable    => $mgrep_enable,
    hasstatus => true,
  }

  # sample dictionary file
  if $create_init_dict {
    exec { 'create_init_dict_file':
      command => "/usr/bin/env bash -c 'echo -e \"00009\\tsample entry\" > ${dict_path} && chown ${user}:${group} ${dict_path} && chmod 0664 ${dict_path}'",
      creates => $dict_path,
      before  => Service['mgrep'],
    }
  }
}
