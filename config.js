{
  graphitePort: 2003
, graphiteHost: "0.0.0.0"
, port: 8125
, backends: [ "./backends/graphite" ]
,  deleteCounters: true,
  flushInterval: 10 * 1000,
  graphite: {
    legacyNamespace: false,
  }
}