#
# Class: mgrep::rrestart
#
# Description: rolling restart of mgrep servers
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:


class mgrep::rrestart (
  $mgrep_initdscript = $mgrep::params::mgrep_initdscript,
  $mgrep_redishost   = $mgrep::params::mgrep_redishost,
  $mgrep_redisport   = $mgrep::params::mgrep_redisport,
  Boolean $mgrep_master = false,
  $mgrep_version     = $mgrep::params::mgrep_version,
  $mgrep_cronfreq    = $mgrep::params::mgrep_cronfreq,
  Boolean $verbose   = true,
) inherits mgrep::params {

  if ! defined(Package['python-pip'])  { package { 'python-pip':  ensure => installed } }
  package { 'redis':
    ensure   => installed,
    provider => 'pip',
    require  => Package['python-pip']
  }

  file { "/usr/local/mgrep-${mgrep_version}/bin/rrestart":
    ensure => present,
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/mgrep/rrestart',
  }
  if $verbose {
    $verbose_flag = '-v'
    $verbose_log  = '>> /var/log/mgreprestart 2>&1'
  } else {
    $verbose_flag = ''
    $verbose_log = '>> /dev/null 2>&2'
  }
  if ( $mgrep_master == true) {
    $cron_content = "${mgrep_cronfreq} root /usr/local/mgrep-${mgrep_version}/bin/rrestart ${verbose_flag} -m -r ${mgrep_redishost} -p ${mgrep_redisport} ${verbose_log} \n"
  } else {
    $cron_content = "${mgrep_cronfreq} root /usr/local/mgrep-${mgrep_version}/bin/rrestart ${verbose_flag} -r ${mgrep_redishost} -p ${mgrep_redisport} ${verbose_log} \n"
  }

  file { '/etc/cron.d/mgrep-rrestart':
    ensure  => present,
    mode    => '0644',
    content => $cron_content,
  }
}

