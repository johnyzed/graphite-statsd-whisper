class carbon(

$version="0.9.10",
$build_dir = "/tmp"
 
  ) {

 $carbon_url = "http://launchpad.net/graphite/0.9/${version}/+download/carbon-${version}.tar.gz"
 $carbon_loc = "$build_dir/carbon.tar.gz"

 #include graphite

  package { "python-twisted" :
    ensure => latest
  }

 file { "/etc/init.d/carbon" :
   source => "puppet:///modules/carbon/carbon",
   ensure => present,
 }

 file { "/opt/graphite/conf/carbon.conf" :
   source => "puppet:///modules/carbon/carbon.conf",
   ensure => present,
   notify => Service[carbon],
   subscribe => Exec[install-carbon],
 }

 file { "/opt/graphite/conf/storage-schemas.conf" :
   source => "puppet:///modules/carbon/storage-schemas.conf",
   ensure => present,
   notify => Service[carbon],
   subscribe => Exec[install-carbon],
 }

 file { "/var/log/carbon" :
   ensure => directory,
   owner => www-data,
   group => www-data,
 }

 exec { "download-graphite-carbon":
   command => "wget -O $carbon_loc $carbon_url",
   creates => "$carbon_loc",
   path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
 }

 exec { "unpack-carbon":
   command => "tar -zxvf $carbon_loc",
   cwd => $build_dir,
   subscribe => Exec[download-graphite-carbon],
   refreshonly => true,
   path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
 }

 exec { "install-carbon" :
   command => "python setup.py install",
   cwd => "$build_dir/carbon-$version",
   require => Exec[unpack-carbon],
   creates => "/opt/graphite/bin/carbon-cache.py",
   path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
  }

  service { "carbon":
    enable => true,
    ensure => running,
    require=> Exec['install-carbon'],
    }

}