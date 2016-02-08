class sudosh2::params {
  case $::osfamily
  {
    'redhat':
    {
      case $::operatingsystemrelease
      {
        /^6.*$/:
        {
          $source_file_rpm="puppet:///modules/${module_name}/centos/sudosh2-1.0.6-1.el6.x86_64.rpm"
        }
        default: { fail("Unsupported RHEL/CentOS version!")  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }
}
