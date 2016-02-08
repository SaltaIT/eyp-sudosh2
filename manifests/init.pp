# == Class: sudosh2
#
class sudosh2 (
                $srcdir='/usr/local/src',
                $ensure='present',
                $defaultshell='/bin/bash',
                $logdir='/var/log/sudosh',
                $cleanup_mtime='60',
                $cleanup_hour='0',
                $cleanup_minute='0',
              ) inherits sudosh2::params {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($ensure=='present')
  {
    $ensure_pkg='installed'
  }
  elsif($ensure=='absent')
  {
    $ensure_pkg='purged'
  }
  else
  {
    fail("ensure => \"${ensure}\" UNSUPPORTED")
  }

  exec { "mkdir sudosh2 ${srcdir}":
    command => "mkdir -p ${srcdir}",
    creates => $srcdir,
  }

  file { "${srcdir}/sudosh2.rpm":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $sudosh2::params::source_file_rpm,
    require => Exec["mkdir sudosh2 ${srcdir}"],
  }

  #instalar rpm
  package { "sudosh2":
    ensure   => $ensure_pkg,
    source   => "${srcdir}/sudosh2.rpm",
    provider => 'rpm',
    require  => File["${srcdir}/sudosh2.rpm"],
  }

  #config sudosh
  file { '/etc/sudosh.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/etcsudosh.erb"),
    require => Package['sudosh2'],
  }

  #afegit a /etc/shells mitjancant moduls propi
  include ::etcshells

  etcshells::addshell { '/usr/bin/sudosh':
    require => Package['sudosh2'],
  }

  #netejar /var/log/sudosh
  cron { "netejar sudosh ${logdir}":
    command => "find ${logdir} -type f -mtime +${cleanup_mtime} -delete",
    user    => root,
    hour    => $cleanup_hour,
    minute  => $cleanup_minute,
  }
}
