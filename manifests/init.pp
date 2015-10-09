# == Class: uwsgi
#
# Manage uwsgi configurations
#
# === Examples
#
# include ::uwsgi
#
# === Authors
#
# Nicolas Dandrimont <nicolas@dandrimont.eu>
#
# === Copyright
#
# Copyright 2015 The Software Heritage developers
#
class uwsgi {
  $uwsgi_packages = ['uwsgi', 'uwsgi-plugin-python3']

  $systemd_service_dir = '/etc/systemd/system/uwsgi.service.d'
  $systemd_service_file = "${systemd_service_dir}/setrlimit.conf"
  $uwsgi_filelimit = 65536

  include ::systemd

  package {$uwsgi_packages:
    ensure => installed,
  }

  service {'uwsgi':
    ensure  => running,
    enable  => true,
    require => [
      Package[$uwsgi_packages],
      File[$systemd_service_file],
      Exec['systemd-daemon-reload'],
    ]
  }

  file {$systemd_service_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file {$systemd_service_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('uwsgi/systemd-setrlimit.conf.erb'),
    require => File[$systemd_service_dir],
    notify  => [
      Service['uwsgi'],
      Exec['systemd-daemon-reload'],
    ]
  }
}
