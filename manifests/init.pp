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
  $systemd_service_snippet = "${systemd_service_dir}/setrlimit.conf"
  $uwsgi_filelimit = 65536

  $systemd_service_files = ['uwsgi.service', 'uwsgi@.service']
  $systemd_generator = '/lib/systemd/system-generators/uwsgi-generator'

  include ::systemd

  package {$uwsgi_packages:
    ensure => installed,
  }

  service {'uwsgi':
    ensure  => running,
    enable  => true,
    require => [
      Package[$uwsgi_packages],
      File[$systemd_service_snippet],
      Exec['systemd-daemon-reload'],
    ]
  }

  each($systemd_service_files) |$file| {
    file {"/etc/systemd/system/${file}":
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "puppet:///modules/uwsgi/${file}",
      notify => Exec['systemd-daemon-reload'],
    }
  }

  file {$systemd_generator:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/uwsgi/uwsgi-generator',
    notify => Exec['systemd-daemon-reload'],
  }

  file {$systemd_service_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file {$systemd_service_snippet:
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
