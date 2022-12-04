
```bash
# fetch which processes listen or have a conn established on a port
lsof -i | grep -E "(LISTEN|ESTABLISHED)"

# check which process specifically listens/established a conn on port 8000.
# You can use any port number as input
lsof -i :8000

# kill process based on process ID
kill -9 <PID>
```
