# -*- coding: utf-8 -*-
# vim: ft=yaml
---
## Pebble does not work correctly with certbot < 0.30,
## so don't test it with stretch-backports
letsencrypt:
  config:
    server: https://localhost:14000/dir
    agree-tos: true
    renew-by-default: true
    email: saltstack-letsencrypt-formula@example.com
  authenticators:
    default: standalone
  domainsets:
    www:
      - letsencrypt-formula.example.com
