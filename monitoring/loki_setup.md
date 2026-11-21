## 1. Starting the Stack
Start Loki, Promtail, and Grafana using Docker Compose from the repository root:
```bash
sudo docker compose -f monitoring/docker-compose.yaml up -d
curl -s http://localhost:3100/ready
```
- **Loki**: `http://localhost:3100`
- **Grafana**: `http://localhost:3000`

## 2. Labels Applied by Promtail
`monitoring/promtail-config.yaml` discovers Docker containers via `/var/run/docker.sock` and applies the following labels:
- `job`: `docker-logs`
- `container`: Container name without the leading `/`
- `service`: Nomad task name (`com_hashicorp_nomad_task_name`) or `standalone-container`
- `nomad_alloc_id`: Nomad allocation ID (`com_hashicorp_nomad_alloc_id`)

## 3. LogQL Queries and Results
After requesting a missing path against the Nomad-allocated port (`curl -i http://127.0.0.1:30500/nonexistent-test-page`), run these queries in Grafana Explore (`loki` data source):
- Isolate NGINX logs:
logql
{container=~".nginx."}
- Filter for non-200 status codes:
logql
{container=~".nginx."} |= " 404 "
**Result**: The request returned `HTTP/1.1 404 Not Found` (`nginx/1.27.5`), and matching `404` access log entries appeared in Grafana Explore with container and Nomad labels attached.

## 4. Issues Encountered and Resolutions
- **Connection refused on port 8080**: The `nginx-app` Nomad allocation was mapped to host port `30500` (`127.0.0.1:30500->8080/tcp`), so testing `http://127.0.0.1:30500/nonexistent-test-page` generated the `404` response.
- **LogQL parse error in Explore**: Entering a raw URL (`http://localhost:3100`) into the Explore query box caused a syntax error; replacing it with `{container=~".*nginx.*"} |= " 404 "` queried the log stream cleanly.
- **Ingester startup delay**: Loki briefly reported `Ingester not ready` immediately after startup before returning `ready` on `http://localhost:3100/ready`.
