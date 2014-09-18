# statsd + graphite to go

Provision a virtual machine with vagrant and puppet to play around with statsd and graphite

## Details:

 * port forwardings enabled
 * graphite: http://localhost:8080/
 * statsd: 8125:udp

## Installation

```
git clone https://github.com/Jimdo/vagrant-statsd-graphite-puppet.git
cd vagrant-statsd-graphite-puppet
vagrant up
open http://localhost:8080/
```

The default account is admin/admin
