# statsd + graphite to go

Provision a virtual machine with vagrant and puppet to play around with statsd and graphite

## Details:

 * port forwardings enabled
 * graphite: http://localhost:8080/
 * statsd: 8125:udp

## Installation

```
git clone https://github.com/johnyzed/graphite-statsd-whisper.git
cd graphite-statsd-whisper
vagrant up
open http://localhost:8080/
```

The default account is admin/admin
