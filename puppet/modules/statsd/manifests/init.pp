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

   file { "/etc/init/statsd.conf":
    require => File['localConfig'],
   	ensure => file,
   	content => "
#!upstart
description \"Statsd node.js server\"
author      \"Nicolas\"

start on startup
stop on shutdown

script
    export HOME=\"/root\"

    echo $$ > /var/run/statsd.pid
    exec sudo -u www-data /usr/bin/node ${statsd_fullpath}/stats.js ${statsd_fullpath}/localConfig.js  >> /var/log/statsd.log 2> /var/log/statsd.error.log
end script

pre-start script
    # Date format same as (new Date()).toISOString() for consistency
    echo \"[`date -u +%Y-%m-%dT%T.%3NZ`] (sys) Starting\" >> /var/log/statsd.log
end script

pre-stop script
    rm /var/run/statsd.pid
    echo \"[`date -u +%Y-%m-%dT%T.%3NZ`] (sys) Stopping\" >> /var/log/statsd.log
end script
   	",
   	alias => "statsd_init",
   }

   service { "statsd":
    enable => true,
   	ensure => running,
   	require => [Package['nodejs'],Exec['unpack-statsd'],File['statsd_init']]
   }


}