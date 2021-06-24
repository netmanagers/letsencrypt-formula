# This state is used to prepare environment for formula testing
# To KISS, testing only on Debian

# Download the LE test server (pebble) and configure it

# Download pebble binary
test-salt-states-install-letsencrypt-test-server-pebble-file-managed:
  file.managed:
    - name: /usr/local/bin/pebble
    - source: https://github.com/letsencrypt/pebble/releases/download/v2.3.1/pebble_linux-amd64
    - source_hash: sha256=60a401159d5132411c88e93ff03ba3322d4ecc7fdba78503da552018f3f98230
    - mode: 755

# Write pebble config based on
# https://github.com/letsencrypt/pebble/blob/master/test/config/pebble-config.json
test-salt-states-install-letsencrypt-test-server-pebble-config-file-managed:
  file.managed:
    - name: /usr/local/etc/pebble-config.json
    - contents: |
        {
          "pebble": {
            "listenAddress": "0.0.0.0:14000",
            "managementListenAddress": "0.0.0.0:15000",
            "certificate": "/etc/ssl/certs/pebble-cert.pem",
            "privateKey": "/etc/ssl/private/pebble-key.pem",
            "httpPort": 5002,
            "tlsPort": 5001,
            "ocspResponderURL": "",
             "externalAccountBindingRequired": false
          }
        }
    - mode: 644
    - require:
      - file: test-salt-states-install-letsencrypt-test-server-pebble-file-managed

test-salt-states-install-letsencrypt-test-server-dependencies-pkg-installed:
  pkg.installed:
    - pkgs:
      - cron
      - openssl
      - ca-certificates

# Download certs files required for pebble to work (unless we want to generate them)
# https://github.com/letsencrypt/pebble/blob/master/test/certs/pebble.minica.pem
test-salt-states-install-letsencrypt-test-server-pebble-minica-crt-file-managed:
  file.managed:
    - name: /usr/local/share/ca-certificates/pebble-minica-cert.crt
    - contents: |
        -----BEGIN CERTIFICATE-----
        MIIDCTCCAfGgAwIBAgIIJOLbes8sTr4wDQYJKoZIhvcNAQELBQAwIDEeMBwGA1UE
        AxMVbWluaWNhIHJvb3QgY2EgMjRlMmRiMCAXDTE3MTIwNjE5NDIxMFoYDzIxMTcx
        MjA2MTk0MjEwWjAgMR4wHAYDVQQDExVtaW5pY2Egcm9vdCBjYSAyNGUyZGIwggEi
        MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC5WgZNoVJandj43kkLyU50vzCZ
        alozvdRo3OFiKoDtmqKPNWRNO2hC9AUNxTDJco51Yc42u/WV3fPbbhSznTiOOVtn
        Ajm6iq4I5nZYltGGZetGDOQWr78y2gWY+SG078MuOO2hyDIiKtVc3xiXYA+8Hluu
        9F8KbqSS1h55yxZ9b87eKR+B0zu2ahzBCIHKmKWgc6N13l7aDxxY3D6uq8gtJRU0
        toumyLbdzGcupVvjbjDP11nl07RESDWBLG1/g3ktJvqIa4BWgU2HMh4rND6y8OD3
        Hy3H8MY6CElL+MOCbFJjWqhtOxeFyZZV9q3kYnk9CAuQJKMEGuN4GU6tzhW1AgMB
        AAGjRTBDMA4GA1UdDwEB/wQEAwIChDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYB
        BQUHAwIwEgYDVR0TAQH/BAgwBgEB/wIBADANBgkqhkiG9w0BAQsFAAOCAQEAF85v
        d40HK1ouDAtWeO1PbnWfGEmC5Xa478s9ddOd9Clvp2McYzNlAFfM7kdcj6xeiNhF
        WPIfaGAi/QdURSL/6C1KsVDqlFBlTs9zYfh2g0UXGvJtj1maeih7zxFLvet+fqll
        xseM4P9EVJaQxwuK/F78YBt0tCNfivC6JNZMgxKF59h0FBpH70ytUSHXdz7FKwix
        Mfn3qEb9BXSk0Q3prNV5sOV3vgjEtB4THfDxSz9z3+DepVnW3vbbqwEbkXdk3j82
        2muVldgOUgTwK8eT+XdofVdntzU/kzygSAtAQwLJfn51fS1GvEcYGBc1bDryIqmF
        p9BI7gVKtWSZYegicA==
        -----END CERTIFICATE-----
    - require:
      - pkg: test-salt-states-install-letsencrypt-test-server-dependencies-pkg-installed

#test-salt-states-install-letsencrypt-test-server-pebble-minica-key-file-managed:
#  file.managed:

test-salt-states-install-letsencrypt-test-server-pebble-update-ca-certs-cmd-run:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - require:
      - file: test-salt-states-install-letsencrypt-test-server-pebble-minica-crt-file-managed
    - unless:
      - test -f /etc/ssl/certs/pebble-minica-cert.pem
    - require_in:
      - service: test-salt-states-install-letsencrypt-test-server-pebble-service-running

test-salt-states-install-letsencrypt-test-server-pebble-ca-crt-file-managed:
  file.managed:
    - name: /etc/ssl/certs/pebble-cert.pem
    - contents: |
        -----BEGIN CERTIFICATE-----
        MIIDGzCCAgOgAwIBAgIIbEfayDFsBtwwDQYJKoZIhvcNAQELBQAwIDEeMBwGA1UE
        AxMVbWluaWNhIHJvb3QgY2EgMjRlMmRiMCAXDTE3MTIwNjE5NDIxMFoYDzIxMDcx
        MjA2MTk0MjEwWjAUMRIwEAYDVQQDEwlsb2NhbGhvc3QwggEiMA0GCSqGSIb3DQEB
        AQUAA4IBDwAwggEKAoIBAQCbFMW3DXXdErvQf2lCZ0qz0DGEWadDoF0O2neM5mVa
        VQ7QGW0xc5Qwvn3Tl62C0JtwLpF0pG2BICIN+DHdVaIUwkf77iBS2doH1I3waE1I
        8GkV9JrYmFY+j0dA1SwBmqUZNXhLNwZGq1a91nFSI59DZNy/JciqxoPX2K++ojU2
        FPpuXe2t51NmXMsszpa+TDqF/IeskA9A/ws6UIh4Mzhghx7oay2/qqj2IIPjAmJj
        i73kdUvtEry3wmlkBvtVH50+FscS9WmPC5h3lDTk5nbzSAXKuFusotuqy3XTgY5B
        PiRAwkZbEY43JNfqenQPHo7mNTt29i+NVVrBsnAa5ovrAgMBAAGjYzBhMA4GA1Ud
        DwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwDAYDVR0T
        AQH/BAIwADAiBgNVHREEGzAZgglsb2NhbGhvc3SCBnBlYmJsZYcEfwAAATANBgkq
        hkiG9w0BAQsFAAOCAQEAYIkXff8H28KS0KyLHtbbSOGU4sujHHVwiVXSATACsNAE
        D0Qa8hdtTQ6AUqA6/n8/u1tk0O4rPE/cTpsM3IJFX9S3rZMRsguBP7BSr1Lq/XAB
        7JP/CNHt+Z9aKCKcg11wIX9/B9F7pyKM3TdKgOpqXGV6TMuLjg5PlYWI/07lVGFW
        /mSJDRs8bSCFmbRtEqc4lpwlrpz+kTTnX6G7JDLfLWYw/xXVqwFfdengcDTHCc8K
        wtgGq/Gu6vcoBxIO3jaca+OIkMfxxXmGrcNdseuUCa3RMZ8Qy03DqGu6Y6XQyK4B
        W8zIG6H9SVKkAznM2yfYhW8v2ktcaZ95/OBHY97ZIw==
        -----END CERTIFICATE-----

test-salt-states-install-letsencrypt-test-server-pebble-ca-key-file-managed:
  file.managed:
    - name: /etc/ssl/private/pebble-key.pem
    - contents: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAmxTFtw113RK70H9pQmdKs9AxhFmnQ6BdDtp3jOZlWlUO0Blt
        MXOUML5905etgtCbcC6RdKRtgSAiDfgx3VWiFMJH++4gUtnaB9SN8GhNSPBpFfSa
        2JhWPo9HQNUsAZqlGTV4SzcGRqtWvdZxUiOfQ2TcvyXIqsaD19ivvqI1NhT6bl3t
        redTZlzLLM6Wvkw6hfyHrJAPQP8LOlCIeDM4YIce6Gstv6qo9iCD4wJiY4u95HVL
        7RK8t8JpZAb7VR+dPhbHEvVpjwuYd5Q05OZ280gFyrhbrKLbqst104GOQT4kQMJG
        WxGONyTX6np0Dx6O5jU7dvYvjVVawbJwGuaL6wIDAQABAoIBAGW9W/S6lO+DIcoo
        PHL+9sg+tq2gb5ZzN3nOI45BfI6lrMEjXTqLG9ZasovFP2TJ3J/dPTnrwZdr8Et/
        357YViwORVFnKLeSCnMGpFPq6YEHj7mCrq+YSURjlRhYgbVPsi52oMOfhrOIJrEG
        ZXPAwPRi0Ftqu1omQEqz8qA7JHOkjB2p0i2Xc/uOSJccCmUDMlksRYz8zFe8wHuD
        XvUL2k23n2pBZ6wiez6Xjr0wUQ4ESI02x7PmYgA3aqF2Q6ECDwHhjVeQmAuypMF6
        IaTjIJkWdZCW96pPaK1t+5nTNZ+Mg7tpJ/PRE4BkJvqcfHEOOl6wAE8gSk5uVApY
        ZRKGmGkCgYEAzF9iRXYo7A/UphL11bR0gqxB6qnQl54iLhqS/E6CVNcmwJ2d9pF8
        5HTfSo1/lOXT3hGV8gizN2S5RmWBrc9HBZ+dNrVo7FYeeBiHu+opbX1X/C1HC0m1
        wJNsyoXeqD1OFc1WbDpHz5iv4IOXzYdOdKiYEcTv5JkqE7jomqBLQk8CgYEAwkG/
        rnwr4ThUo/DG5oH+l0LVnHkrJY+BUSI33g3eQ3eM0MSbfJXGT7snh5puJW0oXP7Z
        Gw88nK3Vnz2nTPesiwtO2OkUVgrIgWryIvKHaqrYnapZHuM+io30jbZOVaVTMR9c
        X/7/d5/evwXuP7p2DIdZKQKKFgROm1XnhNqVgaUCgYBD/ogHbCR5RVsOVciMbRlG
        UGEt3YmUp/vfMuAsKUKbT2mJM+dWHVlb+LZBa4pC06QFgfxNJi/aAhzSGvtmBEww
        xsXbaceauZwxgJfIIUPfNZCMSdQVIVTi2Smcx6UofBz6i/Jw14MEwlvhamaa7qVf
        kqflYYwelga1wRNCPopLaQKBgQCWsZqZKQqBNMm0Q9yIhN+TR+2d7QFjqeePoRPl
        1qxNejhq25ojE607vNv1ff9kWUGuoqSZMUC76r6FQba/JoNbefI4otd7x/GzM9uS
        8MHMJazU4okwROkHYwgLxxkNp6rZuJJYheB4VDTfyyH/ng5lubmY7rdgTQcNyZ5I
        majRYQKBgAMKJ3RlII0qvAfNFZr4Y2bNIq+60Z+Qu2W5xokIHCFNly3W1XDDKGFe
        CCPHSvQljinke3P9gPt2HVdXxcnku9VkTti+JygxuLkVg7E0/SWwrWfGsaMJs+84
        fK+mTZay2d3v24r9WKEKwLykngYPyZw5+BdWU0E+xx5lGUd3U4gG
        -----END RSA PRIVATE KEY-----

test-salt-states-install-letsencrypt-test-server-pebble-env-vars-service-file-managed:
  file.managed:
    - name: /etc/default/pebble
    - contents: |
        PEBBLE_VA_NOSLEEP=1
        PEBBLE_VA_ALWAYS_VALID=1

test-salt-states-install-letsencrypt-test-server-pebble-systemd-service-file-managed:
  file.managed:
    - name: /etc/systemd/system/pebble.service
    - contents: |
        [Unit]
        Description=Pebble Service

        [Service]
        ExecStart=/usr/local/bin/pebble -config /usr/local/etc/pebble-config.json
        User=root
        Group=root
        StandardInput=null
        StandardOutput=append:/var/log/pebble.log
        StandardError=append:/var/log/pebble.log
        EnvironmentFile=-/etc/default/pebble
    - require:
      - file: test-salt-states-install-letsencrypt-test-server-pebble-config-file-managed
      - file: test-salt-states-install-letsencrypt-test-server-pebble-env-vars-service-file-managed

test-salt-states-install-letsencrypt-test-server-systemd-service-cmd-wait:
  cmd.wait:
    - name: systemctl daemon-reload
    - runas: root
    - watch:
      - file: test-salt-states-install-letsencrypt-test-server-pebble-systemd-service-file-managed
    - require_in:
      - service: test-salt-states-install-letsencrypt-test-server-pebble-service-running

test-salt-states-install-letsencrypt-test-server-pebble-service-running:
  service.running:
    - name: pebble

# test-salt-states-install-letsencrypt-test-server-pebble-service-running:
#   cmd.run:
#     - env:
#       - PEBBLE_VA_NOSLEEP: 1
#       - PEBBLE_VA_ALWAYS_VALID: 1
#     - bg: true
#     - name: /usr/local/bin/pebble -config /usr/local/etc/pebble-config.json
#     - require:
#       - file: test-salt-states-install-letsencrypt-test-server-pebble-config-file-managed
#       - file: test-salt-states-install-letsencrypt-test-server-pebble-minica-crt-file-managed
#       - file: test-salt-states-install-letsencrypt-test-server-pebble-ca-crt-file-managed
#       - file: test-salt-states-install-letsencrypt-test-server-pebble-ca-key-file-managed
