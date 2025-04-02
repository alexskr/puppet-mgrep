class mgrep::dictrefresh {
  #script to restart mgrep if dictionary file was updated.
  #script to restart mgrep server if flag was set in redis

  ensure_packages(['python3-redis'])

  file { '/opt/mgrep/bin/mgrepdictrefresh':
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/mgrep/mgrepdictrefresh',
  }
  file { '/etc/cron.d/mgrepdictupdate':
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => "*/5 * * * * root /opt/mgrep/bin/mgrepdictrefresh > /dev/null 2>&1\n",
  }
}
