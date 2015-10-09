# == Defined Type: uwsgi::site
#
# uwsgi::site defines a site for uwsgi.
#
# === Parameters
#
# [*ensure*]
#   Whether the site should be enabled, present (but disabled) or absent.
#
# [*settings*]
#   a hash of settings for the given site. Keys with dashes in the
#   config are added with underscores.
#
# === Examples
#
#  uwsgi::site {'foo':
#    ensure => enabled,
#    settings => {
#      plugin              => 'python3',
#      protocol            => $uwsgi_protocol,
#      socket              => $uwsgi_listen_address,
#      workers             => $uwsgi_workers,
#      max_requests        => $uwsgi_max_requests,
#      max_requests_delta  => $uwsgi_max_requests_delta,
#      worker_reload_mercy => $uwsgi_reload_mercy,
#      reload_mercy        => $uwsgi_reload_mercy,
#      uid                 => $user,
#      gid                 => $user,
#      module              => 'swh.storage.api.server',
#      callable            => 'run_from_webserver',
#    }
#  }
#
# === Authors
#
# Nicolas Dandrimont <nicolas@dandrimont.eu>
#
# === Copyright
#
# Copyright 2015 The Software Heritage developers
#
define uwsgi::site (
  $ensure = 'enabled',
  $settings = {}
  ){

  $uwsgi_config = "/etc/uwsgi/apps-available/${name}.ini"
  $uwsgi_link = "/etc/uwsgi/apps-enabled/${name}.ini"

  case $ensure {
    default: { err("Unknown value ensure => ${ensure}.") }
    'enabled', 'present': {
      file {$uwsgi_config:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('uwsgi/uwsgi.ini.erb'),
        require => Package['uwsgi'],
      }
    }
    'absent': {
      file {$uwsgi_config:
        ensure  => absent,
      }
    }
  }

  case $ensure {
    default: { err("Unknown value ensure => ${ensure}.") }
    'enabled': {
      file {$uwsgi_link:
        ensure  => link,
        target  => $uwsgi_config,
        require => File[$uwsgi_config],
        notify  => Service['uwsgi'],
      }
      File[$uwsgi_config] ~> Service['uwsgi']
    }
    'present', 'absent': {
      file {$uwsgi_link:
        ensure => absent,
        notify  => Service['uwsgi'],
      }
    }
  }
}
