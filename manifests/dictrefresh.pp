#this is a broken module, don't use it.
class mgrep::dictrefresh {
  #script to restart mgrep if dictionary file was updated.
  #script to restart mgrep server if flag was set in redis
  ensure_packages(['python-redis'])

  file { '/usr/local/bin/mgrepdictrefresh':
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/mgrep/mgrepdictrefresh',
  }
  file { '/etc/cron.d/mgrepdictupdate':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => '*/5 * * * * root /usr/local/bin/mgrepdictrefresh > /dev/null 2>&1'
  }
}
