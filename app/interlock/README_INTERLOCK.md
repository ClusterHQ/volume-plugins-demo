
# Using interlock for app routing

```
docker-compose -f interlock-compose.yml up -d
```

> Note: username: stats, password: interlock

visit http://172.16.78.250/haproxy?stats 

Run an app with INTERLOCK_DATA for hostname and domain

```
docker run -d -P \
  -e INTERLOCK_DATA='{"hostname":"cli","domain":"ucp-ha.demo"}' \
  --name hello-world-ha-cli \
  muellermich/nodejs-hello
```

Check your HA proxy for the update http://172.16.78.250/haproxy?stats

You will still need to create DNS records upstream and point them to the HAProxy instance, such as `172.16.78.250   cli.ucp-ha.demo` in `/etc/hosts` or with your DNS provider.

Then visit http://cli.ucp-ha.demo/ and you should see  "Hello World" in the example above.
