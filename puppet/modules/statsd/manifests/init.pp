class statsd (

$version="0.7.2",
$build_dir = "/opt/statsd",

	){
$webapp_url="https://github.com/etsy/statsd/archive/v${version}.tar.gz"
$webapp_loc = "$build_dir/graphite-web.tar.gz"
$statsd_fullpath= "${build_dir}/statsd-${version}"

   package { "nodejs" :
     ensure => "present"
   }

   file { $build_dir:
   	ensure => directory,
   }

  exec { "download-statsd":
        command => "wget -O $webapp_loc $webapp_url",
        creates => "$webapp_loc",
        require => File[$build_dir],
        path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
   }

   exec { "unpack-statsd":
     command => "tar -zxvf $webapp_loc",
     cwd => $build_dir,
     subscribe=> Exec[download-statsd],
     refreshonly => true,
     path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
     creates => $statsd_fullpath
   }

   file { "localConfig":
   	path=> "$statsd_fullpath/localConfig.js",
   	ensure => file,
   	source => "puppet:///modules/statsd/localConfig.js"
   }

   file { "/etc/init.d/statsd":
    require => File['localConfig'],
   	ensure => present,
   	content => template('statsd/statsd.erb'),
    alias => "statsd_init",
    mode => 'o=rwx,ug=rx',
   }

   service { "statsd":
    enable => true,
   	ensure => running,
   	require => [Package['nodejs'],Exec['unpack-statsd'],File['statsd_init']]
   }


}