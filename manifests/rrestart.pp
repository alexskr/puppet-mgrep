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
  Stdlib::Host $redis_host = 'localhost',
  StdLib::Port $redis_port = 6379,
  Boolean $mgrep_primary   = false,
  String $cron_string      = '*/5 * * * *',
  Boolean $verbose         = true,
) {

  ensure_packages(['python3-redis'])

  file { '/opt/mgrep/bin/rrestart':
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/mgrep/rrestart',
  }
  if $verbose {
    $verbose_flag = '-v >> /var/log/mgreprestart 2>&1'
  } else {
    $verbose_flag = '>> /dev/null 2>&2'
  }
  if ( $mgrep_primary == true) {
    $cron_content = "${cron_string} root /opt/mgrep/bin/rrestart -m -r ${redis_host} -p ${redis_port} ${verbose_flag} \n"
  } else {
    $cron_content = "${cron_string} root /opt/mgrep/bin/rrestart -r ${redis_host} -p ${redis_port} ${verbose_flag} \n"
  }

  file { '/etc/cron.d/mgrep-rrestart':
    mode    => '0644',
    content => $cron_content,
  }
}
