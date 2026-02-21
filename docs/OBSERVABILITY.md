# Observability

## Endpoints
- Uptime Kuma: `https://status.livraone.com`
- Grafana: `http://127.0.0.1:3002` (SSH tunnel recommended)

## Monitored Targets
- Hub health: `https://hub.livraone.com/api/health`
- Invoice service: `https://invoice.livraone.com` (basic HTTP check)
- Node exporter (host metrics)
- cAdvisor (container metrics)

## Alert Policy
- HTTP uptime monitor: alert on 3 consecutive failures
- CPU usage: alert if >90% for 10 minutes
- Memory usage: alert if >90% for 10 minutes
- Disk usage: alert if >85% for 10 minutes

## Adding Monitors
In Uptime Kuma, add HTTP(s) monitors for:
- Hub health: `https://hub.livraone.com/api/health`
- Hub root: `https://hub.livraone.com/`
- Invoice root: `https://invoice.livraone.com/`
